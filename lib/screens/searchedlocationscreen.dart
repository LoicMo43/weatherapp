import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/Current.dart';
import '../models/dailyweather.dart';
import '../models/hourlyweather.dart';
import '../providers/currentweatherprovider.dart';
import '../providers/dailyweatherprovider.dart';
import '../providers/hourlyweatherprovider.dart';
import '../providers/isloadingprovider.dart';
import 'mainscreen.dart';

class SearchedLocationScreen extends StatefulWidget {
  double latitude = 0.0;
  double longitude = 0.0;
  String location = "";

  SearchedLocationScreen(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.location});

  @override
  State<SearchedLocationScreen> createState() => _SearchedLocationScreenState();
}

class _SearchedLocationScreenState extends State<SearchedLocationScreen> {
  // bool isLoading = false;
  int adjustHourlyByCurrentTime = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWeatherData();
    });
  }

  getWeatherData() async {
    Provider.of<isLoadingProvider>(context, listen: false).isLoading = true;

    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=${widget.latitude}&longitude=${widget.longitude}'
        '&hourly=temperature_2m,weathercode,is_day&daily=weathercode,temperature_2m_max,'
        'temperature_2m_min,sunrise,sunset&current_weather=true&timezone=auto';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = await json.decode(response.body);
        CurrentWeather currentWeather =
            CurrentWeather.fromJson(jsonData['current_weather']);
        Provider.of<CurrentWeatherProvider>(context, listen: false)
            .currentWeather = currentWeather;

        HourlyWeather hourlyWeather =
            HourlyWeather.fromJson(jsonData['hourly']);
        Provider.of<HourlyWeatherProvider>(context, listen: false)
            .hourlyWeather = hourlyWeather;
        DailyWeather dailyWeather = DailyWeather.fromJson(jsonData['daily']);
        Provider.of<DailyWeatherProvider>(context, listen: false).dailyWeather =
            dailyWeather;
      } else {
        print('erreur');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur de chargement de données')));
      }
    } catch (e) {
      print('err' + e.toString());
    }

    Provider.of<isLoadingProvider>(context, listen: false).isLoading = false;
    var hourly = Provider.of<HourlyWeatherProvider>(context, listen: false);

    for (int i = 0; i < hourly.hourlyWeather!.time!.length; i++) {
      Duration d = hourly.hourlyWeather!.time![i].difference(DateTime.now());

      if (!d.isNegative) {
        break;
      }
      adjustHourlyByCurrentTime++;
    }
  }

  Icon getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icon(
          WeatherIcons.day_sunny,
          size: 26,
          weight: 34,
        );
      case 1:
        return Icon(
          WeatherIcons.day_sunny_overcast,
          size: 26,
          weight: 34,
        );
      case 2:
        return Icon(
          WeatherIcons.day_cloudy,
          size: 26,
          weight: 34,
        );
      case 3:
        return Icon(
          WeatherIcons.cloudy,
          size: 26,
          weight: 34,
        );
      case 45:
      case 48:
        return Icon(
          WeatherIcons.fog,
          size: 26,
          weight: 34,
        );
      case 51:
      case 53:
      case 55:
        return Icon(
          WeatherIcons.rain,
          size: 26,
          weight: 34,
        );
      case 56:
      case 57:
        return Icon(
          WeatherIcons.rain_mix,
          size: 26,
          weight: 34,
        );
      case 61:
      case 63:
      case 65:
        return Icon(
          WeatherIcons.rain,
          size: 26,
          weight: 34,
        );
      case 66:
      case 67:
        return Icon(
          WeatherIcons.rain_mix,
          size: 26,
          weight: 34,
        );
      case 71:
      case 73:
      case 75:
        return Icon(
          WeatherIcons.snow,
          size: 26,
          weight: 34,
        );
      case 77:
        return Icon(
          WeatherIcons.snowflake_cold,
          size: 26,
          weight: 34,
        );
      case 80:
      case 81:
      case 82:
        return Icon(
          WeatherIcons.showers,
          size: 26,
          weight: 34,
        );
      case 85:
      case 86:
        return Icon(
          WeatherIcons.snow,
          size: 26,
          weight: 34,
        );
      case 95:
        return Icon(
          WeatherIcons.thunderstorm,
          size: 26,
          weight: 34,
        );
      case 96:
      case 99:
        return Icon(
          WeatherIcons.storm_showers,
          size: 26,
          weight: 34,
        );
      default:
        return Icon(
          WeatherIcons.day_sunny,
          size: 26,
          weight: 34,
        ); // Default icon for unknown weather code
    }
  }

  String removeStringTillFirstComma(String inputString) {
    int commaIndex = inputString.indexOf(',');
    if (commaIndex != -1) {
      return inputString.substring(commaIndex + 1);
    } else {
      return inputString;
    }
  }

  Widget getWeekDay(DateTime date) {
    switch (date.weekday) {
      case 1:
        return Text(
          'Lundi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 2:
        return Text(
          'Mardi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 3:
        return Text(
          'Mercredi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 4:
        return Text(
          'Jeudi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 5:
        return Text(
          'Vendredi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 6:
        return Text(
          'Samedi',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 7:
        return Text(
          'D',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return Text(
          'Inconnu',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }

  bool isOneDigit(int number) {
    String numberString = number.toString();
    return numberString.length == 1;
  }

  String getFormattedHour(int hour, [int min = 0]) {
    String twoDigitHour = hour.toString().padLeft(2, '0');
    String twoDigitMin = min.toString().padLeft(2, '0');
    return '$twoDigitHour:$twoDigitMin';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // var hourly = Provider.of<HourlyWeatherProvider>(context);
    // var daily = Provider.of<DailyWeatherProvider>(context);
    // var currentWeather = Provider.of<CurrentWeatherProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_outlined),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MainScreen()));
              },
            ),
            title:
                Text('Météo', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orangeAccent[200]),
        body: Consumer<isLoadingProvider>(builder: (context, isLoading, child) {
          return isLoading.isLoading == true
              ? Center(child: const CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 150,
                      child: Text(
                        (widget.location),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Consumer<CurrentWeatherProvider>(
                        builder: (context, currentWeather, child) {
                      return Text(
                          currentWeather.currentWeather!.temperature
                                  .toString() +
                              ' \u00B0C',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold));
                    }),
                    Consumer<CurrentWeatherProvider>(
                        builder: (context, currentWeather, child) {
                      return getWeatherIcon(
                          currentWeather.currentWeather?.weathercode?.toInt() ??
                              0);
                    }),
                    SizedBox(
                      height: 30,
                    ),
                    // Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Météo horaire',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Container(
                          width: screenWidth,
                          height: 160,
                          padding: EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: 24,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Center(
                                    child: Consumer<HourlyWeatherProvider>(
                                        builder: (context, hourly, child) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(hourly
                                                  .hourlyWeather!
                                                  .temperature2m![index +
                                                      adjustHourlyByCurrentTime]
                                                  .toString() +
                                              ' \u00B0C'),
                                          SizedBox(height: 5),
                                          getWeatherIcon(hourly
                                              .hourlyWeather!
                                              .weathercode![index +
                                                  adjustHourlyByCurrentTime]
                                              .toInt()),
                                          SizedBox(height: 5),
                                          Text(getFormattedHour(hourly
                                              .hourlyWeather!
                                              .time![index +
                                                  adjustHourlyByCurrentTime]
                                              .hour)),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    // Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Météo quotidienne',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Container(
                          width: screenWidth,
                          height: 230,
                          padding: EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: 7,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Center(
                                    child: Consumer<DailyWeatherProvider>(
                                        builder: (context, daily, child) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // crossAxisAlignment: CrossAxisAlignment.,
                                        children: [
                                          Row(
                                            children: [
                                              getWeekDay(daily
                                                  .dailyWeather!.time![index]),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(daily.dailyWeather!
                                                      .time![index].day
                                                      .toString() +
                                                  '/' +
                                                  daily.dailyWeather!
                                                      .time![index].month
                                                      .toString() +
                                                  '/' +
                                                  daily.dailyWeather!
                                                      .time![index].year
                                                      .toString())
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    WeatherIcons.thermometer,
                                                    size: 20,
                                                    color: Colors.blue,
                                                  ),
                                                  Text(daily
                                                          .dailyWeather!
                                                          .temperature2mMax![
                                                              index]
                                                          .toString() +
                                                      ' \u00B0C'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    WeatherIcons
                                                        .thermometer_exterior,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                  Text((daily
                                                          .dailyWeather!
                                                          .temperature2mMin![
                                                              index]
                                                          .toString() +
                                                      ' \u00B0C')),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          getWeatherIcon(daily
                                              .dailyWeather!.weathercode![index]
                                              .toInt()),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    WeatherIcons.sunrise,
                                                    size: 20,
                                                    color: Colors.orange,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    getFormattedHour(
                                                        daily
                                                            .dailyWeather!
                                                            .sunrise![index]
                                                            .hour,
                                                        daily
                                                            .dailyWeather!
                                                            .sunrise![index]
                                                            .minute),
                                                    // style: TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(
                                                WeatherIcons.sunset,
                                                size: 20,
                                                color: Colors.deepPurple,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                getFormattedHour(
                                                    daily.dailyWeather!
                                                        .sunset![index].hour,
                                                    daily.dailyWeather!
                                                        .sunset![index].minute),
                                                // style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    // Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Détails',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<CurrentWeatherProvider>(
                                builder: (context, currentWeather, child) {
                              return Text('Vitesse du vent:' +
                                  currentWeather.currentWeather!.windspeed
                                      .toString() +
                                  ' Km/h');
                            }),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text('Jour / Nuit:'),
                                Consumer<CurrentWeatherProvider>(
                                    builder: (context, currentWeather, child) {
                                  return currentWeather.currentWeather!.isDay ==
                                          1
                                      ? Icon(WeatherIcons.day_sunny)
                                      : Icon(WeatherIcons.night_clear);
                                })
                              ],
                            ),
                            // ,Text('Time')
                            SizedBox(
                              height: 5,
                            ),
                            Text('Latitude:' + widget.latitude.toString()),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Longitude:' + widget.longitude.toString()),
                            SizedBox(
                              height: 20,
                            )
                          ]),
                    ),
                  ],
                ));
        }),
      ),
    );
  }
}
