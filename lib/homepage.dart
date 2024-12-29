import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'location_service.dart';
import 'package:stroke_text/stroke_text.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? currentWeather;
  List<dynamic>? forecast;
  String? city = "Your Location";
  String backgroundImage = "assets/clear.jpg"; // Default background image
  bool isLoading = false; // Tracks whether data is being fetched

  @override
  void initState() {
    super.initState();
    fetchWeatherByLocation(); // Automatically fetch weather on page load
  }

  void fetchWeatherByCity(String cityName) async {
    setState(() {
      isLoading = true;
    });
    try {
      final weather = await _weatherService.getCurrentWeather(cityName);
      final forecastData = await _weatherService.getFiveDayForecast(cityName);

      setState(() {
        currentWeather = weather;
        forecast = forecastData['list'];
        city = weather['name'];
        String weatherCondition = weather['weather'][0]['main'];
        backgroundImage =
            _getBackgroundImage(weather['main']['temp'], weatherCondition);
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchWeatherByLocation() async {
    setState(() {
      isLoading = true;
    });
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
        backgroundImage =
            _getBackgroundImage(weather['main']['temp'], weatherCondition);
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getBackgroundImage(double temperature, String weatherCondition) {
    if (weatherCondition.contains("Rain")) return "assets/rain.jpg";
    if (weatherCondition.contains("Thunderstorm")) return "assets/thunder.jpg";
    if (weatherCondition.contains("Clouds")) return "assets/cloudy.jpg";
    if (weatherCondition.contains("Fog")) return "assets/fog.jpg";
    if (weatherCondition.contains("Mist")) return "assets/fog.jpg";
    if (temperature < 22) return "assets/cold.jpg";
    if (temperature < 30) return "assets/clear.jpg";
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
        resizeToAvoidBottomInset:
        true, // Automatically resizes to avoid keyboard overflow
        body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
    child:SingleChildScrollView(
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(), // Loading indicator
          )
              : Column(
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
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), // Adjust the opacity for darkness level
                      BlendMode.darken, // Darken the image
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StrokeText(
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
                        Column(
                          children: [
                            currentWeather != null
                                ? Image.network(
                              "https://openweathermap.org/img/wn/${currentWeather!['weather'][0]['icon']}@2x.png",
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.white); // Fallback icon
                              },
                            )
                                : Icon(Icons.cloud, size: 50, color: Colors.white), // Default icon
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
                          ],
                        ),
                        SizedBox(width: 8),
                      ],
                    ),

                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          StrokeText(
                            text: city ?? "City",
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.right,
                            strokeColor: Colors.black,
                            strokeWidth: 2,
                          ),
                          Spacer(),
                          StrokeText(
                              text: "It's a ${_getCondition(currentWeather!['main']['temp'])} day!",
                              textStyle: const TextStyle(fontSize: 18),
                              strokeColor: Colors.black,
                              strokeWidth: 1
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (currentWeather != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .3,
                      height: MediaQuery.of(context).size.width * .25,
                      child: Card(
                          child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4776e6),
                                      Color(0xff8e54e9)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )),
                              child: Column(
                                children: [
                                  Icon(Icons.water_drop_outlined),
                                  _weatherDetail("Humidity",
                                      "${currentWeather!['main']['humidity']}%"),
                                ],
                              )
                          )),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .3,
                      height: MediaQuery.of(context).size.width * .25,
                      child: Card(
                          child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [Color(0xff4776e6), Color(0xff8e54e9)],
                                    stops: [0, 1],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  )

                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.air_outlined),
                                  _weatherDetail("Wind Speed",
                                      "${currentWeather!['wind']['speed']} m/s"),
                                ],
                              )
                          )),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .3,
                      height: MediaQuery.of(context).size.width * .25,
                      child: Card(
                          child: Container( padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [Color(0xff4776e6), Color(0xff8e54e9)],
                                    stops: [0, 1],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )

                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.thermostat_outlined),
                                  _weatherDetail("Pressure",
                                      "${currentWeather!['main']['pressure']} hPa"),
                                ],
                              )
                          )),
                    )
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (forecast == null)
                Center(child: Text('No forecast data available'))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: forecast!.map((item) {
                      String _formatForecastDate(String dateString) {
                        DateTime date = DateTime.parse(dateString); // Parse the date string into DateTime
                        return DateFormat('d MMM, h a').format(date); // Format the date as "28 Dec, 12AM"
                      }
                      // Extract the weather icon and description from the forecast item
                      String iconCode = item['weather'][0]['icon']; // Get the weather icon code
                      String description = item['weather'][0]['description']; // Get the description
                      String iconUrl = "https://openweathermap.org/img/wn/$iconCode@2x.png"; // Construct the icon URL

                      return SizedBox(
                        width: MediaQuery.of(context).size.width * .35,

                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatForecastDate(item['dt_txt']), // Forecast date and time
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Image.network(
                                  iconUrl,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error); // Fallback icon in case of an error
                                  },
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${item['main']['temp']}°C', // Temperature
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  description, // Weather description
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
            ],
          ),
        ),

      ),
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: fetchWeatherByLocation,
          tooltip: 'Refresh Weather',
          child: Icon(Icons.refresh),
        ),)
    );
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
    if (temperature < 15) return "chilly";
    if (temperature < 22) return "cold";
    if (temperature < 28) return "pleasant";
    if (temperature < 35) return "warm";
    return "hot";
  }
}
