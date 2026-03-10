import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class FloatingMic extends StatefulWidget {
  const FloatingMic({super.key});

  @override
  State<FloatingMic> createState() => _FloatingMicState();
}

class _FloatingMicState extends State<FloatingMic> {
  SpeechToText speech = SpeechToText();
  bool isListening = false;
  String spokenText = "";
  String translatedText = "";
  bool _isModalOpen = false;

  // Available languages
  final Map<String, String> languages = {
    "Sinhala": "si",
    "Kannada": "kn",
    "Hindi": "hi",
    "English": "en",
    "Tamil": "ta",
  };
  String selectedLanguage = "si"; // default Sinhala

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 95,
      right: 30,
      child: FloatingActionButton(
        onPressed: _openModal,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.mic, size: 32),
      ),
    );
  }

  void _openModal() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;

    spokenText = "";
    translatedText = "";
    _isModalOpen = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            // Start listening automatically
            _startListening(modalSetState);

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.translate, color: Colors.blue),
                      const Text(
                        "Voice Translation",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          _stopListening();
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel, color: Colors.grey),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Dropdown for selecting language
                  Row(
                    children: [
                      const Text("Select Language: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: selectedLanguage,
                        items: languages.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.key),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          modalSetState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Mic Button
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                        ),
                        child: Icon(
                          isListening ? Icons.mic_none : Icons.mic,
                          size: 50,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isListening ? "Listening..." : "Tap mic to speak",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Translated Text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      translatedText.isEmpty ? "Translated text will appear here..." : translatedText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _isModalOpen = false;
      _stopListening();
    });
  }

  Future<void> _startListening(Function modalSetState) async {
    bool available = await speech.initialize(
      onStatus: (status) async {
        print("Speech status: $status");
        if ((status == "done" || status == "notListening") && spokenText.isNotEmpty) {
          await _translateText(spokenText, modalSetState);
          _stopListening();
        }
      },
      onError: (error) => print("Speech error: $error"),
    );

    if (!available) {
      print("Speech recognition unavailable");
      return;
    }

    setState(() => isListening = true);

    speech.listen(
      onResult: (result) async {
        print("Recognized words: ${result.recognizedWords}");
        if (!_isModalOpen) return;
        modalSetState(() => spokenText = result.recognizedWords);
      },
      listenFor: const Duration(seconds: 20),
      partialResults: true,
      cancelOnError: true,
    );
  }

  void _stopListening() {
    speech.stop();
    if (mounted) setState(() => isListening = false);
  }

  Future<void> _translateText(String text, Function modalSetState) async {
    if (text.isEmpty) return;
    try {
      final url = Uri.parse(
          "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$selectedLanguage&dt=t&q=${Uri.encodeComponent(text)}");
      final response = await http.get(url);
      final jsonData = json.decode(response.body);
      if (!_isModalOpen) return;
      modalSetState(() {
        translatedText = jsonData[0][0][0] ?? "Translation failed";
      });
      print("Translated: $translatedText");
    } catch (e) {
      if (!_isModalOpen) return;
      modalSetState(() {
        translatedText = "Translation failed";
      });
    }
  }
}
