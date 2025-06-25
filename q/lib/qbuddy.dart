import 'dart:convert';
import 'dart:developer' as lg;
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as types;
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:q/constants.dart';
import 'package:q/groqservices.dart';

class Qbuddy extends StatefulWidget {
  const Qbuddy({super.key});

  @override
  State<Qbuddy> createState() => _QbuddyState();
}

class _QbuddyState extends State<Qbuddy> {
  final _chatController = types.InMemoryChatController();
  bool _showWelcome = true;

  void _dismissWelcomeIfNeeded() {
    if (_showWelcome) {
      setState(() {
        _showWelcome = false;
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  // List<String> splitMessage(String text) {
  //   final List<String> result = [];

  //   // Split on paragraphs
  //   final paragraphs = text.split(RegExp(r'\n+'));

  //   for (final para in paragraphs) {
  //     if (para.trim().isEmpty) continue;

  //     // Check if paragraph contains Arabic (basic Arabic Unicode range)
  //     final arabicMatches = RegExp(r'[\u0600-\u06FF]+').allMatches(para);
  //     lg.log("this is the arabic matches $arabicMatches");
  //     if (arabicMatches.isNotEmpty) {
  //       // Arabic found – treat entire line as separate message
  //       result.add(para.trim());
  //     } else {
  //       // Otherwise, break the paragraph further if it's too long
  //       const int chunkSize = 250; // Customize chunk length
  //       for (int i = 0; i < para.length; i += chunkSize) {
  //         result.add(
  //           para
  //               .substring(
  //                 i,
  //                 i + chunkSize > para.length ? para.length : i + chunkSize,
  //               )
  //               .trim(),
  //         );
  //       }
  //     }
  //   }

  //   return result;
  // }
  // for utf8

  List<String> splitMessage(String text) {
    final List<String> result = [];

    // Split paragraphs based on new lines
    final paragraphs = text.split(RegExp(r'\n+'));

    for (final para in paragraphs) {
      if (para.trim().isEmpty) continue;

      // Arabic/Non-English regex: anything NOT in a-zA-Z0-9 or common punctuation
      // final nonEnglishRegex = RegExp(r'[^a-zA-Z0-9\s.,;:!?()'\"-]");
      final nonEnglishRegex = RegExp(r"[^a-zA-Z0-9\s.,;:!?()'\-]");
      if (nonEnglishRegex.hasMatch(para)) {
        try {
          final decoded = utf8.decode(para.runes.toList());
          result.add(decoded.trim());
        } catch (e) {
          // Fallback if decode fails
          result.add(para.trim());
        }
      } else {
        // English text → split further if too long
        result.addAll(_chunkText(para.trim()));
      }
    }

    return result;
  }

  // Helper to break long messages into smaller chunks
  List<String> _chunkText(String text, {int chunkSize = 300}) {
    final chunks = <String>[];
    int start = 0;

    while (start < text.length) {
      int end = start + chunkSize;

      if (end >= text.length) {
        chunks.add(text.substring(start).trim());
        break;
      }

      // Find the last period before or at the chunkSize
      int lastPeriod = text.lastIndexOf('.', end);
      if (lastPeriod <= start) {
        // No period found, fallback to original chunkSize
        lastPeriod = end;
      }

      chunks.add(text.substring(start, lastPeriod + 1).trim());
      start = lastPeriod + 1;
    }

    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _chatController.messages.isEmpty;
    return Scaffold(
      backgroundColor: Colors.black, // Light background
      body: Stack(
        children: [
          Chat(
            backgroundColor: AppColors.green,
            // timeFormat: DateFormat(),
            chatController: _chatController,
            currentUserId: 'user1',
            theme: const types.ChatTheme(
              colors: types.ChatColors(
                onPrimary: Color(
                  0xFFEDEBD7,
                ), // Soft warm cream for text/icons on primary
                onSurface: Color(
                  0xFFDDE6E4,
                ), // Slightly muted white for general text
                primary: Color(
                  0xFF007872,
                ), // A brighter shade to stand out on dark green
                surface: Color(
                  0xFF014241,
                ), // Darker than background, rich depth
                surfaceContainer: Color(0xFF003534), // Even darker container
                surfaceContainerHigh: Color(0xFF002928), // Highest elevation
                surfaceContainerLow: Color(
                  0xFF01211F,
                ), // Lower elevation containers
              ),
              shape: BorderRadius.all(Radius.circular(16)),
              typography: types.ChatTypography(
                labelLarge: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFEDEBD7), // Cream for headers
                  height: 1.4,
                ),
                labelMedium: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFDDE6E4), // Off-white for secondary labels
                  height: 1.4,
                ),
                labelSmall: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFB2C1BD), // Muted greenish gray
                ),
                bodyMedium: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFDDE6E4),
                  height: 1.4,
                ),
                bodySmall: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA9B8B5), // Soft faded tone
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDEBD7), // Stronger for emphasis
                ),
              ),
            ),

            // builders: _customBubbleBuilder, // 🎨 Bubble customization
            onMessageSend: (text) async {
              _dismissWelcomeIfNeeded();
              final userMessage = types.TextMessage(
                id: '${Random().nextInt(100000)}',
                authorId: 'user1',
                createdAt: DateTime.now().toUtc(),
                text: text,
              );
              _chatController.insertMessage(userMessage);

              final result = await GroqAIService.runGeneral(text);
              final replyText = result['response'];
              lg.log("this is the reply text $replyText");
              final messages = splitMessage(replyText);

              for (final message in messages) {
                final botMessage = types.TextMessage(
                  id: '${Random().nextInt(100000)}',
                  authorId: 'groq_bot',
                  createdAt: DateTime.now().toUtc(),
                  text: message,
                );
                _chatController.insertMessage(botMessage);
              }
            },
            resolveUser: (id) async {
              if (id == 'groq_bot') {
                return const types.User(id: 'groq_bot', name: 'QBot');
              }
              return const types.User(id: 'user1', name: 'You');
            },
          ),
          AnimatedOpacity(
            opacity: isEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Visibility(
              visible: isEmpty,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Color(0xFFEDEBD7),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '👋 Welcome!\nAsk me anything and I\'ll help you right away.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFEDEBD7),
                          fontFamily: 'Amiri',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
