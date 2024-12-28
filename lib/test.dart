import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'location_service.dart';
import 'package:stroke_text/stroke_text.dart';
class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecast;
  String? city = "Your Location";
  String backgroundImage = "assets/clear.jpg"; // Default background image

  void fetchWeatherByCity(String cityName) async {
    try {
      final weather = await _weatherService.getCurrentWeather(cityName);
      final forecastData = await _weatherService.getFiveDayForecast(cityName);

      setState(() {
        currentWeather = weather;
        forecast = forecastData['list'];
        city = weather['name'];
        String weatherCondition = weather['weather'][0]['main'];
        backgroundImage = _getBackgroundImage(weather['main']['temp'], weatherCondition);
      });
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    super.initState();
    fetchWeatherByLocation(); // Automatically fetch weather on page load
  }

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
        String weatherCondition = weather['weather'][0]['main'];
        backgroundImage = _getBackgroundImage(weather['main']['temp'], weatherCondition);
      });
    } catch (e) {
      print(e);
    }
  }

  String _getBackgroundImage(double temperature, String weatherCondition) {
    if (weatherCondition.contains("Rain")) return "assets/rain.jpg";
    if (weatherCondition.contains("thunder")) return "assets/thunder .jpg";
    if (temperature < 20) return "assets/cold.jpg";
    if (temperature < 30) return "assets/cloudy.jpg";
    if (temperature < 35) return "assets/sunny.jpg";
    return "assets/hot.jpg";
  }

  String _formatDate() {
    return DateFormat('EEEE, MMM d').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(children: [
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
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              StrokeText(
                text: _formatDate(), // Date and day
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
                strokeColor: Colors.black,
                strokeWidth: 2,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StrokeText(
                  text: currentWeather != null
                      ? "${currentWeather!['main']['temp']}°C"
                      : "Temp",
                  textStyle: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  strokeColor: Colors.black,
                  strokeWidth: 2,
                ),

                SizedBox(width: 8),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StrokeText(
                text:city ?? "City",
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.right,
                strokeColor: Colors.black,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
      if (currentWeather != null) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _weatherDetail(
                "Humidity", "${currentWeather!['main']['humidity']}%"),
            _weatherDetail(
                "Wind Speed", "${currentWeather!['wind']['speed']} m/s"),
            _weatherDetail(
                "Pressure", "${currentWeather!['main']['pressure']} hPa"),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "It's a ${_getCondition(currentWeather!['main']['temp'])} day!",
          style: const TextStyle(fontSize: 18),
        ),
      ],
      if (forecast == null)
        Center(child: Text('No forecast data available'))
      else
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: forecast!.map((item) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['dt_txt']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${item['main']['temp']}°C',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
    ])));
  }

  Widget _weatherDetail(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  String _getCondition(double temperature) {
    if (temperature < 10) return "cold";
    if (temperature < 25) return "pleasant";
    return "hot";
  }
}
