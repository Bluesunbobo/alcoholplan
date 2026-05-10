class CountryLaw {
  final String id;
  final String name;
  final String enName;
  final String flag;
  final double duiLimit; // 饮酒驾驶标准 BAC %
  final double? dwiLimit; // 醉酒驾驶标准 BAC % (Drunk Driving)
  final bool isProhibition; // 是否为禁酒国家

  const CountryLaw({
    required this.name,
    required this.enName,
    required this.flag,
    required this.duiLimit,
    this.dwiLimit,
    required this.isProhibition,
  }) : id = name;

  bool get hasDrunkLimit => dwiLimit != null;
  
  String get duiLimitString => "${duiLimit.toStringAsFixed(3)}%";
  String get dwiLimitString => dwiLimit != null ? "${dwiLimit!.toStringAsFixed(3)}%" : "N/A";

  String get displayBilingualName => "$name / $enName";

  static const List<CountryLaw> allCountries = [
    CountryLaw(name: "中国", enName: "China", flag: "🇨🇳", duiLimit: 0.02, dwiLimit: 0.08, isProhibition: false),
    CountryLaw(name: "丹麦", enName: "Denmark", flag: "🇩🇰", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "德国", enName: "Germany", flag: "🇩🇪", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "法国", enName: "France", flag: "🇫🇷", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "意大利", enName: "Italy", flag: "🇮🇹", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "西班牙", enName: "Spain", flag: "🇪🇸", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "英国", enName: "UK", flag: "🇬🇧", duiLimit: 0.08, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "美国", enName: "USA", flag: "🇺🇸", duiLimit: 0.08, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "加拿大", enName: "Canada", flag: "🇨🇦", duiLimit: 0.05, dwiLimit: 0.08, isProhibition: false),
    CountryLaw(name: "澳大利亚", enName: "Australia", flag: "🇦🇺", duiLimit: 0.05, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "日本", enName: "Japan", flag: "🇯🇵", duiLimit: 0.03, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "韩国", enName: "South Korea", flag: "🇰🇷", duiLimit: 0.03, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "俄罗斯", enName: "Russia", flag: "🇷🇺", duiLimit: 0.03, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "挪威", enName: "Norway", flag: "🇳🇴", duiLimit: 0.02, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "瑞典", enName: "Sweden", flag: "🇸🇪", duiLimit: 0.02, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "捷克", enName: "Czechia", flag: "🇨🇿", duiLimit: 0.0, dwiLimit: null, isProhibition: false),
    CountryLaw(name: "沙特", enName: "Saudi Arabia", flag: "🇸🇦", duiLimit: 0.0, dwiLimit: null, isProhibition: true),
  ];

  static CountryLaw get defaultCountry => allCountries[0]; // China

  static CountryLaw fromName(String name) {
    return allCountries.firstWhere((c) => c.name == name, orElse: () => defaultCountry);
  }

  static CountryLaw fromEnName(String enName) {
    return allCountries.firstWhere((c) => c.enName == enName, orElse: () => defaultCountry);
  }
}
