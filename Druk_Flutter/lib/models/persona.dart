import '../logic/alcohol_brain.dart';

enum Persona {
  martin('Martin'),
  nikolaj('Nikolaj'),
  tommy('Tommy'),
  peter('Peter'),
  clara('Clara'),
  elena('Elena'),
  maya('Maya'),
  sofia('Sofia');

  final String rawValue;
  const Persona(this.rawValue);

  String get id => rawValue;

  String get zhName {
    switch (this) {
      case Persona.martin: return "马丁";
      case Persona.nikolaj: return "尼古拉";
      case Persona.tommy: return "汤米";
      case Persona.peter: return "彼得";
      case Persona.clara: return "克拉拉";
      case Persona.elena: return "埃琳娜";
      case Persona.maya: return "玛雅";
      case Persona.sofia: return "索菲亚";
    }
  }

  String get displayBilingualName => "$zhName / ${rawValue.toUpperCase()}";

  String get avatarImageName {
    switch (this) {
      case Persona.martin: return "persona_martin";
      case Persona.nikolaj: return "persona_nikolaj";
      case Persona.tommy: return "persona_tommy";
      case Persona.peter: return "persona_peter";
      case Persona.clara: return "persona_clara";
      case Persona.elena: return "persona_elena";
      case Persona.maya: return "persona_maya";
      case Persona.sofia: return "persona_sofia";
    }
  }

  String get zhPersonaType {
    switch (this) {
      case Persona.martin: return "哲学探索者";
      case Persona.nikolaj: return "克制平衡者";
      case Persona.tommy: return "当下主义者";
      case Persona.peter: return "数据理性者";
      case Persona.clara: return "感性共鸣者";
      case Persona.elena: return "独立清醒者";
      case Persona.maya: return "自由灵魂者";
      case Persona.sofia: return "社交仪式者";
    }
  }

  String get enPersonaType {
    switch (this) {
      case Persona.martin: return "THE PHILOSOPHER";
      case Persona.nikolaj: return "THE BALANCER";
      case Persona.tommy: return "THE PRESENTIST";
      case Persona.peter: return "THE ANALYST";
      case Persona.clara: return "THE RESONATOR";
      case Persona.elena: return "THE OBSERVER";
      case Persona.maya: return "THE FREE SPIRIT";
      case Persona.sofia: return "THE RITUALIST";
    }
  }

  String get zhDescription {
    switch (this) {
      case Persona.martin: return "追求 0.05% 黄金点，相信适量酒精能让人活得更真实。";
      case Persona.nikolaj: return "工作日戒断，周末有节制地放松，划清酒精与工作的边界。";
      case Persona.tommy: return "不设目标，随遇而安，只为享受此时此刻的真实感。";
      case Persona.peter: return "科学记录每一次摄入，用精准数字理解身体的酒精反应。";
      case Persona.clara: return "酒是打开情感的钥匙，每一杯都与一段亲密关系有关。";
      case Persona.elena: return "喝酒，但始终保持一部分自我在场，享受微醺而非沉睡。";
      case Persona.maya: return "不在乎规则，只在乎纯粹感受，饮酒是一种自由宣言。";
      case Persona.sofia: return "酒是庆典的语言，重视场合与仪式感，好酒必须分享。";
    }
  }

  String get enDescription {
    switch (this) {
      case Persona.martin: return "Chasing the 0.05% gold point, believing that moderated alcohol allows for a more authentic existence.";
      case Persona.nikolaj: return "Abstinent on weekdays, disciplined relaxation on weekends, drawing clear lines between duty and pleasure.";
      case Persona.tommy: return "Driven by the present, moving with the flow to savor the raw honesty of the current moment.";
      case Persona.peter: return "Recording every intake with scientific precision to master the body's reaction to every drop.";
      case Persona.clara: return "Alcohol is the catalyst for empathy, where every glass marks another shared human connection.";
      case Persona.elena: return "Drinking while staying partially present, savoring the haze without losing the self.";
      case Persona.maya: return "Indifferent to rules and standard metrics, drinking as a pure declaration of spiritual freedom.";
      case Persona.sofia: return "Alcohol is the language of celebration, prioritizing the ritual and the joy of shared experience.";
    }
  }

  Gender get defaultGender {
    switch (this) {
      case Persona.martin:
      case Persona.nikolaj:
      case Persona.tommy:
      case Persona.peter:
        return Gender.male;
      case Persona.clara:
      case Persona.elena:
      case Persona.maya:
      case Persona.sofia:
        return Gender.female;
    }
  }

  static Persona fromRawValue(String value) {
    return Persona.values.firstWhere(
      (p) => p.rawValue == value,
      orElse: () => Persona.martin,
    );
  }
}
