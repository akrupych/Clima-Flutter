import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const appID = "bede00a1634467fd428ff6588363346a";

class WeatherModel {
  static String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  static String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }

  static Future<Position> getPosition() => Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      );

  static Future<String> getWeatherHere(BuildContext context) async {
    // get location
    var position;
    try {
      position = await getPosition();
    } catch (e) {
      print(e);
      showErrorDialog(context, "Can't find your location", e);
      return null;
    }
    // load weather
    try {
      final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?"
          "lat=${position.latitude}&lon=${position.longitude}"
          "&appid=$appID&units=metric");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        showErrorDialog(context, "Can't load weather data",
            Exception("Status code ${response.statusCode}"));
      }
    } catch (e) {
      print(e);
      showErrorDialog(context, "Can't load weather data", e);
    }
  }

  static void showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
}
