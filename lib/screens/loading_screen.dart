import 'package:clima/screens/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const appID = "bede00a1634467fd428ff6588363346a";

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<Position> getPosition() => Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 5),
      );

  void getWeather() async {
    // get location
    var position;
    try {
      position = await getPosition();
    } catch (e) {
      print(e);
      showErrorDialog("Can't find your location", e);
      return;
    }
    // load weather
    try {
      final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?"
          "lat=${position.latitude}&lon=${position.longitude}"
          "&appid=$appID&units=metric");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationScreen(
                      weatherJson: response.body,
                    )));
      } else {
        showErrorDialog("Can't load weather data",
            Exception("Status code ${response.statusCode}"));
      }
    } catch (e) {
      print(e);
      showErrorDialog("Can't load weather data", e);
    }
  }

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitFadingGrid(
          color: Colors.white,
        ),
      ),
    );
  }

  void showErrorDialog(String title, Exception e) {
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
