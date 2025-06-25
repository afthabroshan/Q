import 'dart:async';
import 'package:flutter/material.dart';
import 'package:q/constants.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  int currentStep = 0;
  String currentStreamText = '';
  bool aiIsTyping = true;
  bool showFinalButton = false;
  bool showUserInput = false;

  final TextEditingController _controller = TextEditingController();
  final Map<String, String> userResponses = {};
  final List<Widget> chatWidgets = [];
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the controller
    super.dispose();
  }

  final List<Map<String, dynamic>> conversation = [
    {
      'text':
          "As-salamu alaykum! 🌙 I'm Noor, your spiritual companion in this journey.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text': "Welcome to Deen – your personalized Islamic lifestyle app.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text':
          "Here, you'll get prayer times, Quran recitation, daily duas, learning paths, and much more.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text': "To personalize your experience, may I know your name?",
      'key': 'name',
      'requiresInput': true,
    },
    {
      'text': "JazakAllah Khair, {name}! How old are you?",
      'key': 'age',
      'requiresInput': true,
    },
    {
      'text':
          "Great, you're {age} years old. This will help us tailor the content appropriately.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text':
          "Where are you located? (City or use GPS) 📍 This helps us give accurate prayer times.",
      'key': 'location',
      'requiresInput': true,
    },
    {
      'text':
          "Got it! {location} – beautiful place! Do you follow any particular school of thought (Madhhab)?",
      'key': 'madhhab',
      'requiresInput': true,
    },
    {
      'text':
          "Thanks! We'll use the {madhhab} timings and rulings where applicable.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text':
          "What would you like to focus on in your journey? (Quran, Salah, Duas, Hadith, Fiqh, etc.)",
      'key': 'focus_area',
      'requiresInput': true,
    },
    {
      'text':
          "Perfect! We'll provide curated content based on your interest in {focus_area}.",
      'key': '',
      'requiresInput': true,
    },
    {
      'text':
          "Do you want daily reminders for Salah, Dhikr, or Islamic quotes? (Yes/No)",
      'key': 'daily_reminders',
      'requiresInput': true,
    },
    {
      'text':
          "{daily_reminders} – noted! You can always change this later in settings.",
      'key': '',
      'requiresInput': false,
    },
    {
      'text':
          "Almost done! Are you a beginner, intermediate, or advanced in your Islamic knowledge?",
      'key': 'knowledge_level',
      'requiresInput': true,
    },
    {
      'text':
          "Thanks, {name}. You're all set up as a {knowledge_level} level user!",
      'key': '',
      'requiresInput': false,
    },
    {
      'text':
          "Bismillah! Let's begin your journey toward a more fulfilling and mindful Islamic life. 🤲",
      'key': '',
      'requiresInput': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _streamNextMessage();
  }

  void _streamNextMessage() {
    if (currentStep >= conversation.length) return;
    setState(() {
      aiIsTyping = true;
      currentStreamText = '';
    });

    String rawText = conversation[currentStep]['text'];
    rawText = rawText.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      return userResponses[match.group(1)] ?? '';
    });

    int index = 0;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (index < rawText.length) {
        setState(() {
          currentStreamText += rawText[index];
        });
        index++;
        _scrollToBottom();
      } else {
        // _scrollToBottom();
        timer.cancel();
        // _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            // _scrollToBottom();
            aiIsTyping = false;

            chatWidgets.add(_buildAIMessage(currentStreamText));
          });
          final currentMessage = conversation[currentStep];
          final requiresInput = currentMessage['requiresInput'] == true;

          if (!requiresInput) {
            currentStep++;
            if (currentStep < conversation.length) {
              Future.delayed(const Duration(milliseconds: 800), () {
                _streamNextMessage();
              });
            }
          } else {
            setState(() {
              showUserInput =
                  true; // show input only *after* message finishes streaming
            });
          }
          // if (conversation[currentStep]['key'] == '') {
          //   currentStep++;
          //   if (currentStep < conversation.length) {
          //     Future.delayed(const Duration(milliseconds: 800), () {
          //       _streamNextMessage();
          //     });
          //   } else {
          //     setState(() => showFinalButton = true);
          //   }
          // }
        });
      }
    });
  }

  void _handleUserResponse(String response) {
    if (currentStep >= conversation.length) return;
    final key = conversation[currentStep]['key'];
    if (key.isNotEmpty) {
      userResponses[key] = response;
    }

    setState(() {
      chatWidgets.add(_buildUserMessage(response));
      _controller.clear();

      showUserInput = false;
      currentStep++;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (currentStep < conversation.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _streamNextMessage();
        });
      } else {
        setState(() => showFinalButton = true);
      }
    });
  }

  Widget _buildAIMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: AppTextStyles.smallheading),
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: AppTextStyles.smallheading.copyWith(
            color: AppColors.textblack,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInputField() {
    return TextField(
      controller: _controller,
      style: AppTextStyles.smallheading,
      decoration: InputDecoration(
        hintText: 'Your answer...',
        hintStyle: AppTextStyles.smallheading,
        filled: true,
        fillColor: AppColors.textdark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          _handleUserResponse(value.trim());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green, // A pleasant green
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.android, size: 40, color: AppColors.green),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    ...chatWidgets,
                    if (aiIsTyping)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentStreamText,
                            style: AppTextStyles.smallheading,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // if (!aiIsTyping &&
              //     currentStep < conversation.length &&
              //     // conversation[currentStep]['key'] != '' &&
              //     conversation[currentStep]['requiresInput'] == true)
              if (showUserInput) _buildUserInputField(),

              if (showFinalButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textdark,
                      foregroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Go to Home Page",
                      style: AppTextStyles.contentblack.copyWith(
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
