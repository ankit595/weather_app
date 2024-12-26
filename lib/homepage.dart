import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';
import 'location_service.dart';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
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
      final forecastData = await _weatherService.getFiveDayForecastByCoordinates(
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      fetchWeatherByCity(_cityController.text);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Button to fetch weather by current location
              ElevatedButton(
                onPressed: fetchWeatherByLocation,
                child: Text('Use Current Location'),
              ),
              SizedBox(height: 20),

              // Current weather display
              currentWeather == null
                  ? Center(child: Text('No weather data available'))
                  : Column(
                children: [
                  Text(
                    'Current Weather in $city',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${currentWeather!['main']['temp']}°C, ${currentWeather!['weather'][0]['description']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Divider(),

              // 5-day forecast display
              forecast == null
                  ? Center(child: Text('No forecast data available'))
                  : Expanded(
                child: ListView.builder(
                  itemCount: forecast!.length,
                  itemBuilder: (context, index) {
                    final item = forecast![index];
                    return ListTile(
                      title: Text('${item['dt_txt']}'),
                      subtitle: Text(
                          '${item['main']['temp']}°C, ${item['weather'][0]['description']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
