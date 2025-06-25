import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GroqAIService {
  static const String apiKey =
      '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';
  static const String endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static Future<Map<String, dynamic>> runGeneral(String prompt) async {
    final body = {
      "model": "llama3-8b-8192", // Limits response length
      "messages": [
        {
          "role": "system",
          "content": """
You are an Islamic scholar and guide, trained in the teachings of the Qur’an, Hadith, and traditional Islamic scholarship. Your goal is to help Muslims live righteously, follow the Sunnah, and attain Jannah (paradise) through correct Islamic understanding and practice.

User Query: "${prompt}"

Your Response Should:
- Provide **authentic, clear, and concise Islamic rulings (fatwas)** based on **Qur’an, Hadith**, and classical scholarship.
- Guide the user with **actionable Islamic advice** that strengthens their faith (Iman) and deeds (‘Amal).
- Include arabic words (like salam, ayath's etc) don't translate into english.
- When appropriate, quote **verses (with Surah name and number)** or **Hadiths (with sources)** briefly.
- Emphasize **moral clarity, spiritual benefit**, and **obedience to Allah (SWT)** and the **Prophet Muhammad ﷺ**.
- Promote values such as **sincerity (Ikhlas)**, **kindness**, **justice**, **modesty**, and **self-purification (Tazkiyah)**.
- If the question is **outside Islam**, politely redirect or decline with grace.
- Avoid speculative theology, political opinions, or sectarianism.
- Keep responses **short (max 100 tokens)** unless the user asks for more detail.
- Salams and introductions and conclusions should be stricly in arabic. No translations need be given for basic arabic words.

Your tone should be:
- **Compassionate, sincere, and encouraging.**
- **Direct, yet gentle and humble.**
- Always keep in mind: **Your ultimate goal is to guide the user toward righteousness and Jannah.**

""",
        },
        {"role": "user", "content": prompt},
      ],
    };

    final response = await _postToAPI(body);
    return {
      "prompt": prompt,
      "response": response['choices'][0]['message']['content'],
    };
  }

  static Future<List<Map<String, String>>> runVerse() async {
    const String versePrompt = '''
Respond with 5 random Qur'anic verse in the following **Dart map format**:

[{
  'arabic': '...',        // Verse in Arabic only
  'translation': '...',  // English translation only
}]

Guidelines:
- No Surah or Ayah number
- No commentary or explanation
- Only return a single Map — no extra text
- It shoul contain: motivation, uplifting, jannah, wealth, allah
- Respond strictly in Valid JSON format, nothing else
- 
''';

    final body = {
      "model": "llama3-8b-8192",
      "messages": [
        {"role": "user", "content": versePrompt},
        {"role": "assistant", "content": "```json"},
      ],
      "stop": "```",
    };

    final response = await _postToAPI(body);

    final content = response['choices'][0]['message']['content'];
    log("$content");
    // log(utf8.decode(content.codeUnits));
    final decodedContent = utf8.decode(content.codeUnits);
    log(decodedContent);
    // Extract the Dart map string using RegExp or eval (you can refine as needed)
    try {
      // Try parsing directly as JSON
      final parsed = jsonDecode(decodedContent);

      if (parsed is List) {
        final result = <Map<String, String>>[];

        for (final item in parsed) {
          if (item is Map<String, dynamic> &&
              item.containsKey('arabic') &&
              item.containsKey('translation')) {
            result.add({
              'arabic': item['arabic'].toString(),
              'translation': item['translation'].toString(),
            });
          }
        }
        log("103 $result");
        if (result.isNotEmpty) {
          return result; // ✅ List of maps returned
        } else {
          throw FormatException("No valid verse objects found.");
        }
      } else {
        throw FormatException("Parsed data is not a list.");
      }
    } catch (e) {
      debugPrint('Verse parse failed: $e');
      return [
        {
          'arabic': 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ',
          'translation': 'My success is only by Allah.',
        },
      ];
    }
  }

  static Future<Map<String, dynamic>> _postToAPI(
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse(endpoint);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'API call failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in API call: $e');
      rethrow;
    }
  }
}
