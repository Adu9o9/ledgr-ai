import 'dart:convert';
import 'package:http/http.dart' as http;

class AIRepository {
  // TODO: Move this to a secure .env file later. 
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  // Using the gemini-flash-latest endpoint
  static const String _endpoint = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent';

  static Future<Map<String, dynamic>> getFinancialAdvice(String monthlyData) async {
    final uri = Uri.parse('$_endpoint?key=$_apiKey');

    // The CRED-style System Instruction
    const String systemInstruction = 
      "You are an elite, concise financial advisor for a university student in India. "
      "Analyze the user's monthly spending data. Provide exactly three bullet points of advice. "
      "Point 1: Highlight the biggest area of overspending. "
      "Point 2: Offer a realistic, immediate cutback strategy. "
      "Point 3: Provide a motivating fact about saving. "
      "Keep the tone sharp, professional, and slightly witty. Max 50 words total. "
      "Return the response as a JSON object with keys 'insight_1', 'insight_2', and 'insight_3'.";

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "systemInstruction": {
            "parts": [{"text": systemInstruction}]
          },
          "contents": [
            {
              "parts": [{"text": monthlyData}]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json" // Forcing JSON output for the UI
          }
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final rawText = decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        
        // Parse the LLM's stringified JSON back into a Dart Map
        return jsonDecode(rawText) as Map<String, dynamic>;
      } else {
        // THIS WILL REVEAL THE EXACT ISSUE
        print('GOOGLE API ERROR: ${response.body}');
        throw Exception('API Error ${response.statusCode}: Check VS Code terminal.');
      }
    } catch (e) {
      throw Exception('Failed to fetch AI insights: $e');
    }
  }
}