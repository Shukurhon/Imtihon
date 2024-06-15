import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String joyNomi = "";
  String mamlakat = "";
  String harorat = "";
  String obHavo = "";
  String vaqt = "";
  String shamol = "";
  String namlik = "";
  String bulutli = "";
  String gifUrl = "assets/images/loading.gif"; // Initial GIF

  List vaqti = [];

  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData('Fergana'); // start with default city
  }

  void getData(String city) async {
    String apiUrl =
        "https://api.weatherapi.com/v1/forecast.json?key=40b2851af21546fbbd294943232312&q=$city&days=2&aqi=yes&alerts=yes";
    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> malumot = jsonDecode(response.body);
      Map<String, dynamic> timeData = malumot["location"];
      Map<String, dynamic> data = malumot["current"];
      Map<String, dynamic> conditionData = data["condition"];

      setState(() {
        joyNomi = timeData["name"];
        mamlakat = timeData["country"];
        harorat = data["temp_c"].toString() + "°C";
        obHavo = conditionData["text"];
        vaqt = timeData["localtime"].substring(11);
        shamol = data["wind_kph"].toString() + " kph";
        namlik = data["humidity"].toString() + "%";
        bulutli = data["cloud"].toString() + "%";

        // Update vaqti list for hourly weather
        vaqti = malumot["forecast"]["forecastday"][0]["hour"].map((hourData) {
          return {
            "time": hourData["time"].substring(11),
            "temp": hourData["temp_c"].toString() + "°C"
          };
        }).toList();

        // Set the GIF based on weather condition
        gifUrl = getWeatherGifUrl(obHavo);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  String getWeatherGifUrl(String weatherType) {
    if (weatherType.toLowerCase().contains('rain')) {
      return "assets/images/rain.gif";
    } else if (weatherType.toLowerCase().contains('cloud')) {
      return "assets/images/cloud.gif";
    } else if (weatherType.toLowerCase().contains('clear') ||
        weatherType.toLowerCase().contains('sun')) {
      return "assets/images/sun.gif";
    } else {
      return "assets/images/sun.gif"; // Default GIF
    }
  }

  void searchCity() {
    getData(cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_sharp,
                color: Colors.white,
              ),
              Text(
                joyNomi.isNotEmpty ? joyNomi : 'Loading...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60), topRight: Radius.circular(60))),
          backgroundColor: Colors.blue[700],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cityController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                labelText: 'Enter city name',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              style: TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                searchCity();
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.white),
                            onPressed: searchCity,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: Image.asset(
                        gifUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      harorat.isNotEmpty ? harorat : 'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    Text(
                      obHavo.isNotEmpty ? obHavo : 'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    SizedBox(height: 10),
                    Text(
                      vaqt.isNotEmpty ? vaqt : 'Loading...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.air, color: Colors.white),
                            Text(
                              shamol.isNotEmpty ? shamol : 'Loading...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              'Windy',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.opacity, color: Colors.white),
                            Text(
                              namlik.isNotEmpty ? namlik : 'Loading...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              'Humidity',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.cloud, color: Colors.white),
                            Text(
                              bulutli.isNotEmpty ? bulutli : 'Loading...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              'Cloudy',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Text(
                                '24 hours >',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: vaqti.length,
                        itemBuilder: (context, index) {
                          return HourlyWeather(
                            vaqti[index]["time"],
                            vaqti[index]["temp"],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(),
      ),
    );
  }
}

class HourlyWeather extends StatelessWidget {
  final String time;
  final String temperature;

  HourlyWeather(this.time, this.temperature);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(width: 0.1, color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 17),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              temperature,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Icon(Icons.cloud, color: Colors.white, size: 30),
            SizedBox(
              height: 15,
            ),
            Text(
              time,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
