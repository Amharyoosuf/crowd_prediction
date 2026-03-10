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
  final SpeechToText speech = SpeechToText();
  bool isListening = false;
  String spokenText = "";
  String translatedText = "";
  String statusMessage = "Tap mic to speak";
  bool _isModalOpen = false;

  final Map<String, String> languages = {
    "Sinhala": "si",
    "Kannada": "kn",
    "Hindi": "hi",
    "English": "en",
    "Tamil": "ta",
  };

  String selectedLanguage = "si"; // Target language fixed to Sinhala

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
    print("🎤 Mic modal opened");

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print(" Microphone permission denied");
      return;
    }

    spokenText = "";
    translatedText = "";
    statusMessage = "Tap mic to speak";
    _isModalOpen = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
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
                          print("❌ Modal closed");
                          _stopListening();
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel, color: Colors.grey),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Text("Target Language: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                          print("🌐 Target language selected: $value");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  if (isListening)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.hearing, size: 50, color: Colors.blue),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        await _startListening(modalSetState);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.mic, size: 50, color: Colors.blue),
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

                  Text(
                    statusMessage,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      translatedText.isEmpty
                          ? "Translated text will appear here..."
                          : translatedText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      print("🧹 Modal disposed");
      _isModalOpen = false;
      _stopListening();
    });
  }

  Future<void> _startListening(Function modalSetState) async {
    print("▶️ Initializing speech engine...");

    bool available = await speech.initialize(
      onStatus: (status) async {
        print("📡 Speech status: $status");

        if (status == "done" || status == "notListening") {
          modalSetState(() {
            isListening = false;
            statusMessage = "Processing...";
          });

          print("⏹ Listening stopped");
          print("📝 Final recognized text: $spokenText");

          await _translateText(spokenText, modalSetState);
        }
      },
      onError: (error) {
        print("❌ Speech error: $error");
      },
    );

    if (!available) {
      print("❌ Speech recognition not available");
      return;
    }

    modalSetState(() {
      isListening = true;
      statusMessage = "Listening...";
      spokenText = "";
    });

    print("🎧 Listening started");

    // Force English input
    speech.listen(
      localeId: "en_US",
      onResult: (result) {
        if (!_isModalOpen) return;
        modalSetState(() {
          spokenText = result.recognizedWords;
        });

        print("🗣 Recognized: ${result.recognizedWords}");
      },
      listenFor: const Duration(seconds: 20),
      partialResults: false,
      cancelOnError: true,
    );
  }

  Future<void> _stopListening() async {
    await speech.stop();
    print("🛑 Speech manually stopped");
    if (mounted) {
      setState(() {
        isListening = false;
      });
    }
  }

  Future<void> _translateText(String text, Function modalSetState) async {
    if (text.isEmpty) {
      modalSetState(() {
        statusMessage = "No speech detected";
      });
      print("⚠️ No speech detected");
      return;
    }

    try {
      print("🌍 Translating: $text");

      // Force English -> Sinhala translation
      final url = Uri.parse(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=si&dt=t&q=${Uri.encodeComponent(text)}",
      );

      final response = await http.get(url);
      final jsonData = json.decode(response.body);

      if (!_isModalOpen) return;

      modalSetState(() {
        translatedText = jsonData[0][0][0] ?? "Translation failed";
        statusMessage = "Done";
      });

      print("✅ Translated Text: $translatedText");
    } catch (e) {
      if (!_isModalOpen) return;
      modalSetState(() {
        statusMessage = "Translation failed";
      });
      print("❌ Translation error: $e");
    }
  }
}
