import 'dart:math';
import 'package:flutter/foundation.dart';

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
}

class AlcoholBrain with ChangeNotifier {
  // User Profile
  double weight;
  Gender gender;
  MetabolicRate metabolicRate;

  // Active Session State
  List<DrinkEntryData> drinks = [];
  double bacPercentage = 0.0;
  double totalAlcoholGrams = 0.0;
  double totalLiquidVolumeML = 0.0;
  bool isSoberingDown = false;
  DateTime? soberDate;
  DateTime? peakBACTime;
  DateTime? safeDate;

  // Simulation State
  double pendingABV = 0.05;
  double pendingVolumeML = 0.0;
  double pendingTargetBAC = 0.0;

  AlcoholBrain({
    required this.weight,
    required this.gender,
    required this.metabolicRate,
  });

  void recalculateBAC() {
    if (drinks.isEmpty) {
      bacPercentage = 0.0;
      totalAlcoholGrams = 0.0;
      totalLiquidVolumeML = 0.0;
      isSoberingDown = false;
      soberDate = null;
      peakBACTime = null;
      safeDate = null;
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final beta = metabolicRate.value;
    final firstDrinkTime = drinks.first.timestamp;

    double potentialTotalBAC = 0.0;
    double currentTotalAlcoholMassGrams = 0.0;

    for (var drink in drinks) {
      final pureAlcoholML = drink.volumeML * drink.abv;
      final alcoholMassGramsForDrink = pureAlcoholML * 0.789;
      currentTotalAlcoholMassGrams += alcoholMassGramsForDrink;

      final peakBACForDrink = alcoholMassGramsForDrink / (weight * gender.rFactor * 10);
      final elapsed = now.difference(drink.timestamp).inSeconds / 3600.0;

      if (elapsed >= 0) {
        final absorptionRatio = min(1.0, elapsed / 0.75);
        potentialTotalBAC += peakBACForDrink * absorptionRatio;
      }
    }

    final totalElapsedSinceStart = now.difference(firstDrinkTime).inSeconds / 3600.0;
    final rawBAC = potentialTotalBAC - (beta * totalElapsedSinceStart);
    bacPercentage = max(0.0, rawBAC);
    totalAlcoholGrams = currentTotalAlcoholMassGrams;
    totalLiquidVolumeML = drinks.fold(0.0, (sum, drink) => sum + drink.volumeML);

    // Peak Calculation & Sober/Safe Estimates
    final totalPotentialPeak = totalAlcoholGrams / (weight * gender.rFactor * 10);
    final hoursUntilSober = totalPotentialPeak / beta;
    soberDate = firstDrinkTime.add(Duration(seconds: (hoursUntilSober * 3600).round()));

    final lastDrinkTime = drinks.last.timestamp;
    final timeSinceLast = now.difference(lastDrinkTime).inSeconds / 3600.0;
    isSoberingDown = (timeSinceLast > 0.75) && bacPercentage > 0;

    syncSimulation();
    notifyListeners();
  }

  void syncSimulation() {
    final beta = metabolicRate.value;
    final addedAlcoholGrams = pendingVolumeML * pendingABV * 0.789;
    final addedBAC = addedAlcoholGrams / (weight * gender.rFactor * 10);
    
    final totalPotentialBAC = bacPercentage + addedBAC;
    pendingTargetBAC = max(0.0, totalPotentialBAC - (beta * 0.75));
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
    recalculateBAC();
  }
}
