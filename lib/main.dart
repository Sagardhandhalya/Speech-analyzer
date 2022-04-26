import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String text = "";
  String currentStm = "";
  Map<String, int> wordsFre = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech analyzer'), centerTitle: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        duration: const Duration(milliseconds: 2000),
        child: FloatingActionButton(
          onPressed: listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        // child: Container(
        //   child: Text(
        //     text,
        //     style: const TextStyle(fontSize: 20),
        //   ),
        //   padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        // ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 10.0,
            runSpacing: 10.0,
            children: wordsFre.keys
                .map((key) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Wrap(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              key,
                              style: const TextStyle(fontSize: 20),
                            ),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.grey, width: 1))),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              wordsFre[key].toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(onStatus: (val) {
        if (val == 'done') {
          text = text + " " + currentStm;
          currentStm.split(' ').forEach((word) {
            if (wordsFre[word] == null) {
              wordsFre[word] = 1;
            } else {
              wordsFre[word] = (wordsFre[word])! + 1;
            }
          });

          setState(() => _isListening = false);
        }
      }, onError: (val) {
        setState(() => _isListening = false);
      });
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  currentStm = val.recognizedWords;
                }));
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
