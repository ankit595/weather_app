import 'dart:convert'; // For JSON parsing
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '86beb9583a495a982525dfd07d7b5109'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/';

  // Fetch current weather by city name
  Future<dynamic> getCurrentWeather(String city) async {
    final url = '${baseUrl}weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch 5-day forecast by city name
  Future<dynamic> getFiveDayForecast(String city) async {
    final url = '${baseUrl}forecast?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  // Fetch current weather by latitude and longitude
  Future<dynamic> getCurrentWeatherByCoordinates(double lat, double lon) async {
    final url = '${baseUrl}weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch 5-day forecast by latitude and longitude
  Future<dynamic> getFiveDayForecastByCoordinates(double lat, double lon) async {
    final url = '${baseUrl}forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
