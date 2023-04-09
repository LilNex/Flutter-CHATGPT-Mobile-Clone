import 'package:flutter_tts/flutter_tts.dart';

class Config{
    


  static List<dynamic> languages = ['ko-KR', 'mr-IN', 'ru-RU', 'zh-TW', 'hu-HU', 'th-TH', 'ur-PK', 'nb-NO', 'da-DK', 'tr-TR', 'et-EE', 'bs', 'sw', 'pt-PT', 'vi-VN', 'en-US', 'sv-SE', 'ar', 'su-ID', 'bn-BD', 'gu-IN', 'kn-IN', 'el-GR', 'hi-IN', 'fi-FI', 'km-KH', 'bn-IN', 'fr-FR', 'uk-UA', 'pa-IN', 'en-AU', 'lv-LV', 'nl-NL', 'fr-CA', 'sr', 'pt-BR', 'ml-IN', 'si-LK', 'de-DE', 'cs-CZ', 'pl-PL', 'sk-SK', 'fil-PH', 'it-IT', 'ne-NP', 'ms-MY', 'hr', 'en-NG', 'nl-BE', 'zh-CN', 'es-ES', 'cy', 'ta-IN', 'ja-JP', 'bg-BG', 'sq', 'yue-HK', 'en-IN', 'es-US', 'jv-ID', 'id-ID', 'te-IN', 'ro-RO', 'ca', 'en-GB'];
  static double speed = 0.5;
  static String selectedLanguage = "en-US";
  static bool isAudioEnabled = true;
  static bool isImageSearch = false;
  static late FlutterTts flutterTts;
}