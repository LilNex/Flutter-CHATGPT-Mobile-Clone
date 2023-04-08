import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.sender,
    this.isImage = false,
  }) : super(key: key);

  final String text;
  final String sender;
  final bool isImage;

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

enum TtsState { playing, stopped }

class _ChatMessageState extends State<ChatMessage> {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.sender)
          .text
          .subtitle1(context)
          .make()
          .box
          .color(widget.sender == "user" ? Vx.red200 : Vx.green200)
          .p16
          .rounded
          .alignCenter
          .makeCentered(),
      Flexible(
        child: widget.isImage
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.text,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : const CircularProgressIndicator.adaptive(),
                ),
              )
            : GestureDetector(
                onTap: () {
                  // Your callback function here
                  print("text tapped" + widget.text);
                  readText(widget.text);
                },
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    widget.text
                        .trim()
                        .text
                        .bodyText1(context)
                        .make()
                        .px8(),
                  ],
                ),
              ),
      ),
    ],
  ).py8();
}

  Future _speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  void readText(String text) {
    _speak(text);
  }
}
