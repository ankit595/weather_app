import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/test.dart';
import 'weather_service.dart';
import 'location_service.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? currentWeather; // Holds current weather data
  List<dynamic>? forecast; // Holds 5-day forecast data
  String? city = "Your Location"; // Default city name

  // Fetch weather for a specific city
  void fetchWeatherByCity(String cityName) async {
    try {
      final weather = await _weatherService.getCurrentWeather(cityName);
      final forecastData = await _weatherService.getFiveDayForecast(cityName);

      setState(() {
        currentWeather = weather;
        forecast = forecastData['list'];
        city = weather['name'];
      });
    } catch (e) {
      print(e);
    }
  }

  // Fetch weather using user's current location
  void fetchWeatherByLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      final weather = await _weatherService.getCurrentWeatherByCoordinates(
          position.latitude, position.longitude);
      final forecastData =
          await _weatherService.getFiveDayForecastByCoordinates(
              position.latitude, position.longitude);

      setState(() {
        currentWeather = weather;
        forecast = forecastData['list'];
        city = weather['name'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(8),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Enter City',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      fetchWeatherByCity(_cityController.text);
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * .5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: AssetImage("assets/clear.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Make children take full width
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Date, Day",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left, // Align to left
                    ),
                  ),
                  Spacer(), // Push "Temp" vertically to the center
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align "Temp" to the right
                    children: [
                      Text(
                        "Temp",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8), // Optional spacing from the edge
                    ],
                  ),
                  Spacer(), // Push "City" to the bottom
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "City",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.right, // Align to right
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
