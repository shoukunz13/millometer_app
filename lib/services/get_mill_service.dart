import 'dart:convert';
import 'package:http/http.dart' as http;

class MillService {
  final String baseUrl = 'http://10.0.2.2:3004/api/getallmills';
  final String apiKey =
      '1b50e01f728f56b50a66c92261b746c0aa8277251de247df713d72f5a8a65b04';

  Future<List<Mill>> fetchMills() async {
    print('Fetching mills from $baseUrl');
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'api-key':
              apiKey, // Include your access token or other necessary headers
        },
      );
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        print('JSON response: $jsonResponse');
        return jsonResponse.map((mill) => Mill.fromJson(mill)).toList();
      } else {
        print('Failed to load mills. Status code: ${response.statusCode}');
        throw Exception('Failed to load mills');
      }
    } catch (e) {
      print('Error fetching mills: $e');
      throw Exception('Error fetching mills');
    }
  }
}

class Mill {
  final String raspberrypi_id;
  final String label;

  Mill({required this.raspberrypi_id, required this.label});

  factory Mill.fromJson(Map<String, dynamic> json) {
    print('Parsing mill from JSON: $json');
    return Mill(
      raspberrypi_id: json['PiID'],
      label: json['name'] ?? json['PiID'],
    );
  }
}
