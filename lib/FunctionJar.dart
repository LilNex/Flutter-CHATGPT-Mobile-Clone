import 'package:chat_gpt_02/Config.dart';
import 'package:chat_gpt_02/chatmessage.dart';

class FunctionJar{
  static void reLoadSpeechSetting() async{

    await Config.flutterTts.setLanguage(Config.selectedLanguage);
    await Config.flutterTts.setSpeechRate(Config.speed);
  }


  


}