import 'dart:ui';

import 'package:chat_gpt_02/Config.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'FunctionJar.dart';
import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;
  bool _isListening = false;
  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: dotenv.env["API_KEY"],
        baseOption: HttpSetup(receiveTimeout: 60000));
    _speech = stt.SpeechToText();
    initTTP();
    super.initState();
  }

  @override
  void dispose() {
    chatGPT?.close();
    chatGPT?.genImgClose();
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();
    print("this is the request " + message.text);
    if (Config.isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");

      final response = await chatGPT!.generateImage(request);
      Vx.log(response!.data!.last!.url!);
      insertNewData(response.data!.last!.url!, isImage: true);
    } else {
      final request =
          CompleteText(prompt: message.text, model: kTranslateModelV3);

      final response = await chatGPT!.onCompleteText(request: request);
      Vx.log(response!.choices[0].text);
      insertNewData(response.choices[0].text, isImage: false);
      if (Config.isAudioEnabled) {
        //  await speak(response!.choices[0].text);
        readText(response!.choices[0].text);
        print("audio is avaible");
      } else
        print("Audio is disabled");
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Question/description"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                Config.isImageSearch = false;
                _sendMessage();
              },
            ),
            IconButton(
              onPressed: _listen,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            )
          ],
        ),
      ],
    ).px16();
  }

  late stt.SpeechToText _speech;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) {
          setState(() {
             _isListening = false;

          });
          print('1onError: $val');
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            print('jarhbou get this ' + val.recognizedWords);
            if (val.hasConfidenceRating && val.confidence > 0) {
              _isListening = false;
              _confidence = val.confidence;
              _controller.text = val.recognizedWords;
              _sendMessage();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Settings"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("Language"),
                    trailing: DropdownButton<String>(
                      value: Config.selectedLanguage,
                      items: Config.languages
                          .map<DropdownMenuItem<String>>((language) {
                        return DropdownMenuItem<String>(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          Config.selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Speed"),
                    trailing: SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Config.speed.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Container(
                            width: 100, // set the desired width here
                            child: Slider(
                              value: Config.speed,
                              min: 0.1,
                              max: 3.0,
                              divisions: 9,
                              onChanged: (value) {
                                setState(() {
                                  Config.speed = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text("Audio Speaking"),
                    trailing: Switch(
                      value: Config.isAudioEnabled,
                      onChanged: (value) {
                        setState(() {
                          Config.isAudioEnabled = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Image Search"),
                    trailing: Switch(
                      value: Config.isImageSearch,
                      onChanged: (value) {
                        setState(() {
                          Config.isImageSearch = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'speed': Config.speed,
                      'language': Config.selectedLanguage,
                      'audio_enabled': Config.isAudioEnabled,
                    });
                    FunctionJar.reLoadSpeechSetting();
                  },
                  child: const Text("Save"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        // Update speed and audio_enabled based on the dialog result
        setState(() {
          Config.speed = result['speed'];
          Config.isAudioEnabled = result['audio_enabled'];
        });

        // Call the audio speaking function here with the updated audio_enabled value
        //_speak(_isAudioEnabled);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ChatGPT"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showSettingsDialog();
              },
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }

  TtsState ttsState = TtsState.stopped;

  Future _speak(String text) async {
    var result = await Config.flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await Config.flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  void readText(String text) {
    _speak(text);
  }

  void initTTP() async {
    Config.flutterTts = FlutterTts();
    await Config.flutterTts.setLanguage(Config.selectedLanguage);
    await Config.flutterTts.setSpeechRate(Config.speed);
    Config.flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
      });
    });

    Config.flutterTts.setCompletionHandler(() {
      setState(() {
        print("jar Complete");
        if (Config.isAudioEnabled) {
          _listen();
          print("audio is avaible");
        } else
          print("Audio is disabled");
      });
    });

    Config.flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
      });
    });

    await Config.flutterTts.setVolume(1.0);

    //await flutterTts.setPitch(1.0);

    //  await flutterTts.isLanguageAvailable("en-US");
  }
}
