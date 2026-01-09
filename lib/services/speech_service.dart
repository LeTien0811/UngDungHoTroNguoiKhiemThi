class SpeechService {
  String textResult = '';
  void startToListen(String text)  {
      textResult += text;
  }

  Future<String> stopListen() async{
    return '';
  }
}