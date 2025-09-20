import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiAiService {
  
  final String _apiKey = dotenv.env['GEMINI_API_KEY']!;
  final String _modelUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  Future<Map<String, dynamic>> generateItinerary(String prompt) async {
    final url = Uri.parse('$_modelUrl?key=$_apiKey');
    final fullPrompt = """
    You are a travel planning expert. Based on the following user request, generate a travel itinerary.
    User Request: "$prompt"
    
    IMPORTANT: Your response MUST be a single, valid JSON object that follows this exact structure, with no extra text or explanations before or after the JSON:
    {
      "title": "A creative title for the trip",
      "days": [
        {
          "title": "Day 1: A summary for this day",
          "items": [
            {"type": "Morning", "description": "Activity for the morning."},
            {"type": "Transfer", "description": "Details about transfer."},
            {"type": "Accommodation", "description": "Details about accommodation."},
            {"type": "Afternoon", "description": "Activity for the afternoon."},
            {"type": "Evening", "description": "Activity for the evening."}
          ]
        }
      ],
      "mapInfo": {
        "origin": "User's origin city if mentioned, otherwise 'Origin'",
        "destination": "The main destination city",
        "duration": "Estimated travel duration",
        "latitude": 34.9671,
        "longitude": 135.7727
      }
    }
    """;

    return _makeApiCall(url, fullPrompt);
  }
  Future<Map<String, dynamic>> refineItinerary(String chatHistory) async {
    final url = Uri.parse('$_modelUrl?key=$_apiKey');
    final fullPrompt = """
    You are a helpful travel planning assistant. Continue the conversation based on the history provided.
    The user wants to refine their travel plan. Your response should be a concise, helpful, and conversational paragraph.
    Do not respond in JSON. Just provide a friendly text response.

    CONVERSATION HISTORY:
    $chatHistory

    YOUR RESPONSE:
    """;
    
    // This call is different, it expects a text response, not JSON
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": [{"parts": [{"text": fullPrompt}]}]}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final textResponse = responseBody['candidates'][0]['content']['parts'][0]['text'];
        return {
          'itinerary': {'response': textResponse}, // Wrapping it to match expected structure
          'usage': {'requestTokens': 0, 'responseTokens': 0}
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('API Error: ${errorBody['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to refine itinerary: $e');
    }
  }

  // Helper function to reduce code duplication
  Future<Map<String, dynamic>> _makeApiCall(Uri url, String prompt) async {
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String jsonString = responseBody['candidates'][0]['content']['parts'][0]['text'];
        
        final startIndex = jsonString.indexOf('{');
        final endIndex = jsonString.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          jsonString = jsonString.substring(startIndex, endIndex + 1);
        }
        
        final itineraryJson = jsonDecode(jsonString);
        return {
          'itinerary': itineraryJson,
          'usage': {'requestTokens': 0, 'responseTokens': 0}
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('API Error: ${errorBody['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate itinerary: $e');
    }
  }
}