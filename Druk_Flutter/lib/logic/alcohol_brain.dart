import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country_law.dart';
import '../models/persona.dart';
import '../models/quotes_db.dart';

enum Gender {
  male(0.68),
  female(0.55);

  final double rFactor;
  const Gender(this.rFactor);
}

enum MetabolicRate {
  slow(0.010),
  medium(0.015),
  fast(0.020);

  final double value;
  const MetabolicRate(this.value);
}

class DrinkEntryData {
  final DateTime timestamp;
  final double abv;
  final double volumeML;

  DrinkEntryData({
    required this.timestamp,
    required this.abv,
    required this.volumeML,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'abv': abv,
    'volumeML': volumeML,
  };

  factory DrinkEntryData.fromJson(Map<String, dynamic> json) => DrinkEntryData(
    timestamp: DateTime.parse(json['timestamp']),
    abv: json['abv'],
    volumeML: json['volumeML'],
  );
}

class DrinkSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime; // Fix: Declare the field
  double peakBAC;
  List<DrinkEntryData> entries;
  String? occasion;
  String? location;
  int? hangoverScore;
  String? customQuote;

  DrinkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.peakBAC,
    required this.entries,
    this.occasion,
    this.location,
    this.hangoverScore,
    this.customQuote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'peakBAC': peakBAC,
    'entries': entries.map((e) => e.toJson()).toList(),
    'occasion': occasion,
    'location': location,
    'hangoverScore': hangoverScore,
    'customQuote': customQuote,
  };

  factory DrinkSession.fromJson(Map<String, dynamic> json) => DrinkSession(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    peakBAC: json['peakBAC'],
    entries: (json['entries'] as List).map((e) => DrinkEntryData.fromJson(e)).toList(),
    occasion: json['occasion'],
    location: json['location'],
    hangoverScore: json['hangoverScore'],
    customQuote: json['customQuote'],
  );
}

class AlcoholBrain with ChangeNotifier {
  // User Profile
  double weight;
  Gender gender;
  MetabolicRate metabolicRate;
  CountryLaw country;
  Persona persona;

  // Quotes State
  String currentStateNameZh = "清醒如水";
  String currentStateNameEn = "The Sober";
  String currentQuoteZh = "酒以见性，水以养生。";
  String currentQuoteEn = "In vino veritas, in aqua sanitas.";
  String currentAvatarImage = "personality_sober";
  List<String> recentQuoteTexts = [];
  List<String> userQuotes = [];
  String? activeSessionQuote;

  // Active Session State
  bool hasSeenCinematicIntro = false;
  List<DrinkEntryData> drinks = [];
  List<DrinkSession> sessions = []; // History
  double bacPercentage = 0.0;
  double totalAlcoholGrams = 0.0;
  double totalLiquidVolumeML = 0.0;
  bool isSoberingDown = false;
  DateTime? soberDate;
  DateTime? peakBACTime;
  double peakBAC = 0.0;
  DateTime? safeDate;

  List<DrinkSession> getAllSessions() {
    final all = List<DrinkSession>.from(sessions);
    if (drinks.isNotEmpty) {
      final activeSession = DrinkSession(
        id: "active_session",
        startTime: drinks.first.timestamp,
        peakBAC: peakBAC,
        entries: List.from(drinks),
        occasion: "进行中 / ACTIVE",
        customQuote: activeSessionQuote,
      );
      all.add(activeSessionQuote != null ? activeSession : activeSession); // Dummy update to ensure all.add
    }
    return all;
  }

  // Helper to calculate chart points for any list of entries
  List<BACPoint> getPointsForEntries(List<DrinkEntryData> entries) {
    if (entries.isEmpty) return [];
    final firstTime = entries.first.timestamp;
    final beta = metabolicRate.value;
    final grams = entries.fold(0.0, (sum, e) => sum + (e.volumeML * e.abv * 0.789));
    final totalPotentialPeak = grams / (weight * gender.rFactor * 10);
    final hoursUntilSober = totalPotentialPeak / beta;
    
    final points = <BACPoint>[];
    final int numPoints = 60;
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints.toDouble();
      final currentHours = t * (hoursUntilSober + 1);
      double pBAC = 0.0;
      final currentTime = firstTime.add(Duration(seconds: (currentHours * 3600).round()));
      for (var drink in entries) {
        final elapsed = currentTime.difference(drink.timestamp).inSeconds / 3600.0;
        if (elapsed >= 0) {
          final ratio = (elapsed / 0.75).clamp(0.0, 1.0);
          final pDrink = (drink.volumeML * drink.abv * 0.789) / (weight * gender.rFactor * 10);
          pBAC += pDrink * ratio;
        }
      }
      points.add(BACPoint(t, max(0.0, pBAC - (beta * currentHours))));
    }
    return points;
  }

  double get historyTotalAlcoholGrams {
    double total = sessions.fold(0.0, (sum, s) {
      return sum + s.entries.fold(0.0, (esum, e) => esum + (e.volumeML * e.abv * 0.789));
    });
    total += drinks.fold(0.0, (sum, e) => sum + (e.volumeML * e.abv * 0.789));
    return total;
  }

  // Simulation State
  double pendingABV = 0.05;
  double pendingVolumeML = 330.0;
  double pendingTargetBAC = 0.0;
  bool isSimulating = false;
  String _selectedDrinkId = 'BEER';
  String get selectedDrinkId => _selectedDrinkId;
  set selectedDrinkId(String val) {
    _selectedDrinkId = val;
    notifyListeners();
  }

  String _displayBACString = "0.000";
  String get displayBACString => _displayBACString;
  set displayBACString(String val) {
    _displayBACString = val;
    notifyListeners();
  }

  bool isInputFocused = false;
  Timer? _refreshTimer;

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      recalculateBAC();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void updateWeight(double v) {
    weight = v;
    recalculateBAC();
    saveToLocal();
    notifyListeners();
  }

  void updateGender(Gender g) {
    if (gender != g) {
      gender = g;
      final validPersonas = Persona.values.where((p) => p.defaultGender == g).toList();
      if (!validPersonas.contains(persona) && validPersonas.isNotEmpty) {
        persona = validPersonas.first;
        refreshQuote(); 
      }
      recalculateBAC();
      saveToLocal();
      notifyListeners();
    }
  }

  void updateCountry(CountryLaw c) {
    if (country != c) {
      country = c;
      recalculateBAC();
      refreshQuote();
      saveToLocal();
      notifyListeners();
    }
  }

  void updatePersona(Persona p) {
    if (persona != p) {
      persona = p;
      refreshQuote();
      saveToLocal();
      notifyListeners();
    }
  }

  void updateMetabolicRate(MetabolicRate m) {
    metabolicRate = m;
    recalculateBAC();
    saveToLocal();
    notifyListeners();
  }

  AlcoholBrain({
    required this.weight,
    required this.gender,
    required this.metabolicRate,
    CountryLaw? country,
    Persona? persona,
  }) : this.country = country ?? CountryLaw.defaultCountry,
       this.persona = persona ?? Persona.martin {
    loadFromLocal();
    refreshQuote();
    _startTimer();
  }

  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_drinks', jsonEncode(drinks.map((e) => e.toJson()).toList()));
    await prefs.setString('history_sessions', jsonEncode(sessions.map((e) => e.toJson()).toList()));
    await prefs.setDouble('user_weight', weight);
    await prefs.setInt('user_gender', gender.index);
    await prefs.setString('user_country', country.name);
    await prefs.setString('user_persona', persona.rawValue);
    await prefs.setBool('seen_intro', hasSeenCinematicIntro);

    await prefs.setStringList('user_quotes', userQuotes);
    if (activeSessionQuote != null) {
      await prefs.setString('active_session_quote', activeSessionQuote!);
    } else {
      await prefs.remove('active_session_quote');
    }
  }

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final drinksJson = prefs.getString('active_drinks');
    final sessionsJson = prefs.getString('history_sessions');
    
    if (drinksJson != null) {
      drinks = (jsonDecode(drinksJson) as List).map((e) => DrinkEntryData.fromJson(e)).toList();
    }
    if (sessionsJson != null) {
      sessions = (jsonDecode(sessionsJson) as List).map((e) => DrinkSession.fromJson(e)).toList();
    }
    weight = prefs.getDouble('user_weight') ?? weight;
    gender = Gender.values[prefs.getInt('user_gender') ?? gender.index];
    final cName = prefs.getString('user_country');
    if (cName != null) country = CountryLaw.fromName(cName);
    final pName = prefs.getString('user_persona');
    if (pName != null) persona = Persona.fromRawValue(pName);
    
    // Onboarding
    hasSeenCinematicIntro = prefs.getBool('seen_intro') ?? false;

    // Custom Quotes
    userQuotes = prefs.getStringList('user_quotes') ?? [];
    activeSessionQuote = prefs.getString('active_session_quote');
    if (activeSessionQuote != null) {
      currentQuoteZh = activeSessionQuote!;
      currentQuoteEn = "";
    }
    
    recalculateBAC();
  }

  // ── CORE BAC CALCULATION (MATCHES iOS) ──────────────────────
  void recalculateBAC() {
    if (drinks.isEmpty) {
      bacPercentage = 0.0;
      totalAlcoholGrams = 0.0;
      totalLiquidVolumeML = 0.0;
      peakBAC = 0.0;
      peakBACTime = null;
      isSoberingDown = false;
      soberDate = null;
      safeDate = null;
      syncSimulation();
      notifyListeners();
      return;
    }

    final DateTime now = DateTime.now();
    final double beta = metabolicRate.value;
    final DateTime firstDrinkTime = drinks.first.timestamp;

    double potentialTotalBAC = 0.0;
    double currentTotalAlcoholMassGrams = 0.0;

    for (var drink in drinks) {
      final double alcoholMassGramsForDrink = drink.volumeML * drink.abv * 0.789;
      currentTotalAlcoholMassGrams += alcoholMassGramsForDrink;
      final double peakBACForDrink = alcoholMassGramsForDrink / (weight * gender.rFactor * 10);
      final double elapsed = now.difference(drink.timestamp).inSeconds / 3600.0;
      
      if (elapsed >= 0) {
        final double absorptionRatio = (elapsed / 0.75).clamp(0.0, 1.0);
        potentialTotalBAC += peakBACForDrink * absorptionRatio;
      }
    }

    final double totalElapsedSinceStart = now.difference(firstDrinkTime).inSeconds / 3600.0;
    final double rawBAC = potentialTotalBAC - (beta * totalElapsedSinceStart);
    bacPercentage = max(0.0, rawBAC);

    totalAlcoholGrams = currentTotalAlcoholMassGrams;
    totalLiquidVolumeML = drinks.fold(0.0, (sum, drink) => sum + drink.volumeML);

    final double totalPotentialPeak = totalAlcoholGrams / (weight * gender.rFactor * 10);
    final double hoursUntilSober = totalPotentialPeak / beta;
    soberDate = firstDrinkTime.add(Duration(seconds: (hoursUntilSober * 3600).round()));

    final double hoursUntilSafe = (totalPotentialPeak - country.duiLimit) / beta;
    safeDate = hoursUntilSafe > 0 ? firstDrinkTime.add(Duration(seconds: (hoursUntilSafe * 3600).round())) : null;

    // Auto-close session ONLY if sober again and time is past soberDate
    // This prevents new drinks (BAC 0 while absorbing) from closing the session prematurely.
    if (bacPercentage <= 0 && drinks.isNotEmpty && now.isAfter(soberDate!)) {
      closeSession();
      return;
    }

    // Track the absolute peak BAC reached during this entire session
    // We scan the predicted curve to find the true historical peak, 
    // ensuring it doesn't drop even as current BAC decreases.
    final double theoreticalPeak = _findPeakValue(firstDrinkTime, beta);
    if (theoreticalPeak > peakBAC) {
      peakBAC = theoreticalPeak;
    }

    final lastDrinkTime = drinks.last.timestamp;
    final timeSinceLast = now.difference(lastDrinkTime).inSeconds / 3600.0;
    isSoberingDown = (timeSinceLast > 0.75) && bacPercentage > 0;

    syncSimulation();
    notifyListeners();
  }

  double _findPeakValue(DateTime firstTime, double beta) {
    double tempPeak = 0.0;
    DateTime tempPeakTime = firstTime;
    
    // Scan up to 24 hours from the first drink to find the absolute peak
    for (int i = 0; i < 96; i++) {
      final double h = i * 0.25; // Scan every 15 minutes
      final DateTime scanTime = firstTime.add(Duration(minutes: (h * 60).round()));
      double pTotal = 0.0;
      for (var drink in drinks) {
        final double elapsed = scanTime.difference(drink.timestamp).inSeconds / 3600.0;
        if (elapsed >= 0) {
          final double ratio = (elapsed / 0.75).clamp(0.0, 1.0); // 45min absorption window
          pTotal += (drink.volumeML * drink.abv * 0.789 / (weight * gender.rFactor * 10)) * ratio;
        }
      }
      final double bacAtT = max(0.0, pTotal - (beta * h));
      if (bacAtT > tempPeak) {
        tempPeak = bacAtT;
        tempPeakTime = scanTime;
      }
    }
    peakBACTime = tempPeakTime;
    return tempPeak;
  }

  void syncSimulation() {
    final double beta = metabolicRate.value;
    final double addedAlcoholGrams = pendingVolumeML * pendingABV * 0.789;
    final double addedBAC = addedAlcoholGrams / (weight * gender.rFactor * 10);
    final double totalPotentialBAC = bacPercentage + addedBAC;
    pendingTargetBAC = max(0.0, totalPotentialBAC - (beta * 0.75));
    isSimulating = pendingVolumeML > 0;
    
    if (!isInputFocused) {
      displayBACString = isSimulating ? pendingTargetBAC.toStringAsFixed(3) : bacPercentage.toStringAsFixed(3);
    }
    notifyListeners();
  }

  void applyTargetBACFromInput(double targetBAC) {
    final double beta = metabolicRate.value;
    final double compensation = beta * 0.75;
    final double adjustedTargetAdded = max(0.0, targetBAC - bacPercentage + compensation);
    final double newVol = (adjustedTargetAdded * weight * gender.rFactor * 10) / (pendingABV * 0.789);
    
    pendingVolumeML = newVol.clamp(0.0, 2000.0);
    syncSimulation();
    commitSimulation();
  }

  void commitSimulation() {
    refreshQuote(forBAC: pendingTargetBAC);
    notifyListeners();
  }

  void addDrink() {
    if (pendingVolumeML <= 0 || pendingABV <= 0) return;
    drinks.add(DrinkEntryData(
      timestamp: DateTime.now(),
      abv: pendingABV,
      volumeML: pendingVolumeML,
    ));
    pendingVolumeML = 0.0;
    _selectedDrinkId = 'CUSTOM';
    recalculateBAC();
    refreshQuote();
    saveToLocal();
    notifyListeners();
  }

  void closeSession() {
    if (drinks.isEmpty) return;
    
    // Safety: Don't archive tiny/insignificant sessions (e.g. accidental adds)
    if (totalAlcoholGrams < 0.5 && bacPercentage < 0.001) {
      drinks.clear();
      peakBAC = 0.0;
      recalculateBAC();
      return;
    }

    // Use the accurately tracked peakBAC from the session
    final finalPeak = peakBAC > 0 ? peakBAC : _calculatePeakForEntries(drinks);
    
    sessions.insert(0, DrinkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: drinks.first.timestamp,
      endTime: DateTime.now(),
      peakBAC: finalPeak,
      entries: List.from(drinks),
      customQuote: activeSessionQuote,
    ));
    drinks.clear();
    activeSessionQuote = null; // Clear override for next session
    peakBAC = 0.0; // Reset for next session
    recalculateBAC();
    saveToLocal();
  }

  void updateSessionHangover(String sessionId, int score) {
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      sessions[index].hangoverScore = score;
      saveToLocal();
      notifyListeners();
    }
  }

  void backfillSession({
    required DateTime startTime,
    required List<DrinkEntryData> entries,
    String? occasion,
    String? location,
  }) {
    if (entries.isEmpty) return;

    final finalPeak = _calculatePeakForEntries(entries);
    
    final session = DrinkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: entries.last.timestamp.add(const Duration(hours: 2)),
      peakBAC: finalPeak,
      entries: List.from(entries),
      occasion: occasion,
      location: location,
    );

    sessions.add(session);
    // Keep history sorted by time descending
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    saveToLocal();
    notifyListeners();
  }

  double _calculatePeakForEntries(List<DrinkEntryData> entries) {
    if (entries.isEmpty) return 0.0;
    final grams = entries.fold(0.0, (sum, e) => sum + (e.volumeML * e.abv * 0.789));
    return grams / (weight * gender.rFactor * 10);
  }

  void deleteDrinkEntry(int index) {
    if (index >= 0 && index < drinks.length) {
      drinks.removeAt(index);
      recalculateBAC();
      saveToLocal();
    }
  }

  void deleteSession(String sessionId) {
    sessions.removeWhere((s) => s.id == sessionId);
    saveToLocal();
    notifyListeners();
  }

  List<BACPoint> getChartPoints() {
    if (drinks.isEmpty) return [];
    final points = <BACPoint>[];
    final firstTime = drinks.first.timestamp;
    final beta = metabolicRate.value;
    final totalAlcoholMassGrams = drinks.fold(0.0, (sum, d) => sum + (d.volumeML * d.abv * 0.789));
    final totalPotentialPeak = totalAlcoholMassGrams / (weight * gender.rFactor * 10);
    final hoursUntilSober = totalPotentialPeak / beta;
    
    final int numPoints = 60;
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints.toDouble();
      final currentHours = t * (hoursUntilSober + 1);
      double potentialBACAtT = 0.0;
      final currentTime = firstTime.add(Duration(seconds: (currentHours * 3600).round()));
      for (var drink in drinks) {
        final elapsed = currentTime.difference(drink.timestamp).inSeconds / 3600.0;
        if (elapsed >= 0) {
          final ratio = (elapsed / 0.75).clamp(0.0, 1.0);
          final peakForDrink = (drink.volumeML * drink.abv * 0.789) / (weight * gender.rFactor * 10);
          potentialBACAtT += peakForDrink * ratio;
        }
      }
      final finalBACAtT = max(0.0, potentialBACAtT - (beta * currentHours));
      points.add(BACPoint(t, finalBACAtT));
    }
    return points;
  }

  void updateStateLabels({double? forBAC}) {
    final targetBAC = forBAC ?? bacPercentage;
    final stateRange = QuotesDB.shared.getStateRange(
      bac: targetBAC,
      country: country,
      isSoberingDown: forBAC == null ? isSoberingDown : false,
      persona: persona,
    );
    currentStateNameZh = stateRange.stateNameZh;
    currentStateNameEn = stateRange.stateNameEn;
    currentAvatarImage = stateRange.avatarImage;
  }

  void refreshQuote({double? forBAC}) {
    final targetBAC = forBAC ?? bacPercentage;
    final stateRange = QuotesDB.shared.getStateRange(
      bac: targetBAC,
      country: country,
      isSoberingDown: forBAC == null ? isSoberingDown : false,
      persona: persona,
    );

    updateStateLabels(forBAC: targetBAC);
    
    // If user has set a custom quote for the active session, do not randomize
    if (activeSessionQuote != null) {
      currentQuoteZh = activeSessionQuote!;
      currentQuoteEn = ""; // Manual quotes don't have English translations
      notifyListeners();
      return;
    }

    final candidates = stateRange.quotes.isEmpty ? QuotesDB.shared.neutralQuotes : stateRange.quotes;
    var filtered = candidates.where((q) => !recentQuoteTexts.contains(q.quote)).toList();

    if (filtered.isEmpty && candidates.isNotEmpty) {
      if (recentQuoteTexts.isNotEmpty) {
        final last = recentQuoteTexts.last;
        filtered = candidates.where((q) => q.quote != last).toList();
      }
    }

    final pool = filtered.isEmpty ? candidates : filtered;

    if (pool.isNotEmpty) {
      final newQuote = pool[Random().nextInt(pool.length)];
      currentQuoteZh = newQuote.quote;
      currentQuoteEn = newQuote.translation;

      recentQuoteTexts.add(newQuote.quote);
      if (recentQuoteTexts.length > 20) {
        recentQuoteTexts.removeAt(0);
      }
    }
    notifyListeners();
  }

  QuoteData getQuoteForBAC(double targetBAC) {
    final stateRange = QuotesDB.shared.getStateRange(
      bac: targetBAC,
      country: country,
      isSoberingDown: false,
      persona: persona,
    );

    final candidates = stateRange.quotes.isEmpty ? QuotesDB.shared.neutralQuotes : stateRange.quotes;
    // Use truly random selection to ensure variety every time a poster is generated
    final q = candidates[Random().nextInt(candidates.length)];
    return QuoteData(q.quote, q.translation);
  }

  void setUserQuote(String quote) {
    if (quote.trim().isEmpty) return;
    currentQuoteZh = quote;
    currentQuoteEn = ""; // Manual quotes don't have English translations
    
    if (!userQuotes.contains(quote)) {
      userQuotes.add(quote);
    }
    
    activeSessionQuote = quote;
    saveToLocal();
    notifyListeners();
  }
}

class QuoteData {
  final String quote;
  final String translation;
  QuoteData(this.quote, this.translation);
}

class BACPoint {
  final double x;
  final double y;
  BACPoint(this.x, this.y);
}
