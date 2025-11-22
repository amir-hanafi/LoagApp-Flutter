import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const baseUrl = "http://10.187.243.197:8000/api";

  static Future<void> updateLocation(String userId, double lat, double lng) async {
  final res = await http.post(
    Uri.parse("$baseUrl/location/update"),
    body: {
      "user_id": userId,
      "lat": lat.toString(),
      "lng": lng.toString(),
    },
  );
  print("UPDATE RESPONSE: ${res.body}");
}

static Future<List<dynamic>> getAllLocations() async {
  final res = await http.get(Uri.parse("$baseUrl/location/all"));

  print("GET ALL RESPONSE: ${res.body}");

  if (res.statusCode == 200) {
    return jsonDecode(res.body); // <- ini LIST langsung
  }
  return [];
}

}