import 'dart:async';
import 'dart:convert';

import 'package:Weather/providers/haspermissionprovider.dart';
import 'package:Weather/providers/isloadingprovider.dart';
import 'package:Weather/screens/searchedlocationscreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../models/Current.dart';
import '../models/dailyweather.dart';
import '../models/hourlyweather.dart';
import '../providers/currentweatherprovider.dart';
import '../providers/dailyweatherprovider.dart';
import '../providers/hourlyweatherprovider.dart';
import '../providers/currentlocationprovider.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool locationservicestatus = false;
  late Position position;
  int adjustHourlyByCurrentTime = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    permissions();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void permissions() async {
    Provider.of<isLoadingProvider>(context, listen: false).isLoading = true;

    if (kIsWeb) {
      js.context.callMethod('getLocation', [
        js.JsFunction.withThis((self, coords) {
          double latitude = js.JsObject.fromBrowserObject(coords)['latitude'];
          double longitude = js.JsObject.fromBrowserObject(coords)['longitude'];
          print('Latitude: $latitude, Longitude: $longitude');
          Provider.of<CurrentLocationProvider>(context, listen: false)
            ..latitude = latitude
            ..longitude = longitude;
          getCityName();
          getWeatherData();
          Provider.of<hasPermissionProvider>(context, listen: false).hasPermission = true;
        }),
        js.JsFunction.withThis((self, error) {
          print('Error getting location: $error');
          Provider.of<hasPermissionProvider>(context, listen: false).hasPermission = false;
        })
      ]);
    } else {
      var data = await Geolocator.isLocationServiceEnabled();

        locationservicestatus = data;

      Geolocator.getServiceStatusStream().listen((event) {
        if (event == geolocator.ServiceStatus.enabled) {

            locationservicestatus = true;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Localisation activé !')));

        } else {
            locationservicestatus = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Activé votre localisation!')));
        }
      });

      if (locationservicestatus) {
        await getLocation();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Avtiver GPS'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Retour')),
                ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
                      Navigator.of(context).pop();
                    },
                    child: Text('Valider'))
              ],
            );
          },
        );
      }
    }
    Provider.of<isLoadingProvider>(context, listen: false).isLoading = false;
  }

  getLocation() async {

   LocationPermission permission= await Geolocator.requestPermission();
    if(permission==LocationPermission.whileInUse){
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Provider.of<CurrentLocationProvider>(context, listen: false).longitude =
        position.longitude;
    Provider.of<CurrentLocationProvider>(context, listen: false).latitude =
        position.latitude;
print(position.longitude);

    getCityName();
    getWeatherData();
    Provider.of<hasPermissionProvider>(context, listen: false).hasPermission=true;

    }
    else if(permission==LocationPermission.denied || permission==LocationPermission.deniedForever){
      bool shouldShowRationale = await Permission.locationWhenInUse.shouldShowRequestRationale;
      if (!shouldShowRationale) {
        showLocationPermissionDialog();
      } else {
        Provider.of<hasPermissionProvider>(context, listen: false).hasPermission=false;
      }
      Provider.of<hasPermissionProvider>(context, listen: false).hasPermission=false;

    }
  }

  void showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Avtiver manuellement la localisation'),
        content: Text('Merci'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Valider'),
          ),
        ],
      ),
    );
  }

  getCityName() async {
    String apiURL =
        "https://nominatim.openstreetmap.org/reverse?lat=${Provider.of<CurrentLocationProvider>(context, listen: false).latitude}&lon=${Provider.of<CurrentLocationProvider>(context, listen: false).longitude}&format=json";

    try {
      final response = await http.get(Uri.parse(apiURL));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Provider.of<CurrentLocationProvider>(context, listen: false).location =
            jsonData['display_name'].toString();
      }
    } catch (e) {
      print(e);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error loading city $e')));
    }
  }

  getWeatherData() async {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=${Provider.of<CurrentLocationProvider>(context, listen: false).latitude}&longitude=${Provider.of<CurrentLocationProvider>(context, listen: false).longitude}'
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
        print(Provider.of<CurrentWeatherProvider>(context, listen: false)
            .currentWeather!
            .temperature
            .toString());
        HourlyWeather hourlyWeather =
            HourlyWeather.fromJson(jsonData['hourly']);
        Provider.of<HourlyWeatherProvider>(context, listen: false)
            .hourlyWeather = hourlyWeather;
        DailyWeather dailyWeather = DailyWeather.fromJson(jsonData['daily']);
        Provider.of<DailyWeatherProvider>(context, listen: false).dailyWeather =
            dailyWeather;
      } else {
        // print(response.statusCode);
        print('error');
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('Error loading weather')));
      }
    } catch (e) {
      print('err' + e.toString());
    }

    var hourly = Provider.of<HourlyWeatherProvider>(context, listen: false);

    for (int i = 0; i < hourly.hourlyWeather!.time!.length; i++) {
      Duration d = hourly.hourlyWeather!.time![i].difference(DateTime.now());

      if (!d.isNegative) {
        break;
      }
      adjustHourlyByCurrentTime++;
    }
    Provider.of<isLoadingProvider>(context,listen: false).isLoading=false;

  }


  Icon getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icon(
          WeatherIcons.day_sunny,
          size: 26,
        );
      case 1:
        return Icon(
          WeatherIcons.day_sunny_overcast,
          size: 26,
        );
      case 2:
        return Icon(
          WeatherIcons.day_cloudy,
          size: 26,
        );
      case 3:
        return Icon(
          WeatherIcons.cloudy,
          size: 26,
        );
      case 45:
      case 48:
        return Icon(
          WeatherIcons.fog,
          size: 26,
        );
      case 51:
      case 53:
      case 55:
        return Icon(
          WeatherIcons.rain,
          size: 26,
        );
      case 56:
      case 57:
        return Icon(
          WeatherIcons.rain_mix,
          size: 26,
        );
      case 61:
      case 63:
      case 65:
        return Icon(
          WeatherIcons.rain,
          size: 26,
        );
      case 66:
      case 67:
        return Icon(
          WeatherIcons.rain_mix,
          size: 26,
        );
      case 71:
      case 73:
      case 75:
        return Icon(
          WeatherIcons.snow,
          size: 26,
        );
      case 77:
        return Icon(
          WeatherIcons.snowflake_cold,
          size: 26,
        );
      case 80:
      case 81:
      case 82:
        return Icon(
          WeatherIcons.showers,
          size: 26,
        );
      case 85:
      case 86:
        return Icon(
          WeatherIcons.snow,
          size: 26,
        );
      case 95:
        return Icon(
          WeatherIcons.thunderstorm,
          size: 26,
        );
      case 96:
      case 99:
        return Icon(
          WeatherIcons.storm_showers,
          size: 26,
        );
      default:
        return Icon(
          WeatherIcons.day_sunny,
          size: 26,
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
          'Dimanche',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return Text(
          'Invalide',
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
    double screenWidth = MediaQuery.sizeOf(context).width;
    // print('haspermission:' + hasPermission.toString());
    // print('locationservicestatus:' + locationservicestatus.toString());
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading :false,
            title:
                Text('Météo', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: SearchDelegateBar(context));
                },
              ),
              Consumer<hasPermissionProvider>(
                  builder: (context,hasPermission,child) {
                  return IconButton(
                    icon: hasPermission.hasPermission?Icon(Icons.location_on_rounded):Icon(Icons.location_off_rounded),
                    onPressed: () {
                     permissions();
                    },
                  );
                }
              ),
            ],
            backgroundColor: Colors.orangeAccent[200]),
        body: Consumer<hasPermissionProvider>(
          builder: (context,hasPermission,child) {
            return hasPermission.hasPermission==false?Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Rechercher une localisation',),
              ],
            )): Consumer<isLoadingProvider>(
                builder: (context,isLoading,child) {
                return isLoading.isLoading == true
                    ? Center(child: const CircularProgressIndicator())
                    :

                SingleChildScrollView(
                        child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Consumer<CurrentLocationProvider>(
                            builder: (context,locationprovider,child) {
                              return Container(
                                width: 150,
                                child: Text((locationprovider.location), maxLines: 2,
                                  overflow: TextOverflow.ellipsis,),
                              );
                            }
                          ),
                          Consumer<CurrentWeatherProvider>(
                              builder: (context,currentWeather,child) {
                              return Text(
                                  currentWeather.currentWeather!.temperature.toString() +
                                      ' \u00B0C',
                                  style:
                                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold));
                            }
                          ),
                          Consumer<CurrentWeatherProvider>(
                              builder: (context,currentWeather,child) {
                              return getWeatherIcon(
                                  currentWeather.currentWeather?.weathercode?.toInt() ?? 0);
                            }
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text('Météo par heure',
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
                                            builder: (context,hourly,child) {
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
                                                      .weathercode![
                                                          index + adjustHourlyByCurrentTime]
                                                      .toInt()),
                                                  SizedBox(height: 5),
                                                  Text(getFormattedHour(hourly
                                                      .hourlyWeather!
                                                      .time![
                                                          index + adjustHourlyByCurrentTime]
                                                      .hour)),
                                                ],
                                              );
                                            }
                                          ),
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
                                child: Text('Météo par jour',
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
                                            builder: (context,daily,child) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                // crossAxisAlignment: CrossAxisAlignment.,
                                                children: [
                                                  Row(
                                                    children: [
                                                      getWeekDay(
                                                          daily.dailyWeather!.time![index]),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(daily.dailyWeather!.time![index]
                                                              .day
                                                              .toString() +
                                                          '/' +
                                                          daily.dailyWeather!.time![index]
                                                              .month
                                                              .toString() +
                                                          '/' +
                                                          daily.dailyWeather!.time![index]
                                                              .year
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
                                                          Text(daily.dailyWeather!
                                                                  .temperature2mMax![index]
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
                                                          Text((daily.dailyWeather!
                                                                  .temperature2mMin![index]
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
                                                                daily.dailyWeather!
                                                                    .sunrise![index].hour,
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
                                            }
                                          ),
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
                            child: Consumer<CurrentWeatherProvider>(
                              builder: (context,currentWeather,child) {
                                return Consumer<CurrentLocationProvider>(
                                  builder: (context,locationprovider,child) {
                                    return Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Vitesse du vent:' +
                                              currentWeather.currentWeather!.windspeed
                                                  .toString() +
                                              ' Km/h'),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text('Jour / Nuit :'),
                                              currentWeather.currentWeather!.isDay == 1
                                                  ? Icon(WeatherIcons.day_sunny)
                                                  : Icon(WeatherIcons.night_clear)
                                            ],
                                          ),
                                          // ,Text('Time')
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('Latitude:' +
                                              locationprovider.latitude.toString()),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('Longitude:' +
                                              locationprovider.longitude.toString()),
                                          SizedBox(
                                            height: 20,
                                          )
                                        ]);
                                  }
                                );
                              }
                            ),
                          ),
                        ],
                      ));
              }
            );
          }
        ),
      ),
    );
  }
}




class SearchDelegateBar extends SearchDelegate<String>{
  BuildContext? context;
SearchDelegateBar(BuildContext context1){
  context=context1;
}



  Future<LocationData> _searchLocation(String query1) async {
    final String apiUrl =
        "https://nominatim.openstreetmap.org/search?q=${query1}&format=json";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);
      List<String> locations = [];
      List<double> latitude = [];
      List<double> longitude = [];
      for (var item in data) {
            locations.add( item['display_name'].toString());
            latitude.add( double.parse(item['lat']));
            longitude.add( double.parse(item['lon']));
            print(item['display_name']);

        }


      return LocationData(
        locations: locations,
        latitude: latitude,
        longitude: longitude,
      );
    } else {
      return LocationData(locations: [], latitude: [], longitude: []);
    }
    }





  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder<LocationData>(
      future: _searchLocation(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the results
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if there was an error fetching the results
          return Text('Erreur: ${snapshot.error}');
        } else {
          // The results have been fetched, so build the suggestions
          List<String> locations = snapshot.data!.locations;
          List<double> latitude = snapshot.data!.latitude;
          List<double> longitude = snapshot.data!.longitude;

          if (locations.isNotEmpty) {
            return ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedLocationScreen(
                              latitude: latitude[index],
                              longitude: longitude[index],
                              location: locations[index],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(locations[index]),
                        subtitle:
                        Text('lat:${latitude[index]}, long:${longitude[index]}'),
                      ),
                    ),
                    Divider()
                  ],
                );
              },
            );
          } else {
            // If locations is empty, return a message
            return Center(child: Text('Non trouvé'));
          }
        }
      },
    );
  }




  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<LocationData>(
      future: _searchLocation(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the results
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if there was an error fetching the results
          return Text('Erreur: ${snapshot.error}');
        } else {
          // The results have been fetched, so build the suggestions
          List<String> locations = snapshot.data!.locations;
          List<double> latitude = snapshot.data!.latitude;
          List<double> longitude = snapshot.data!.longitude;

          if (locations.isNotEmpty) {
            return ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchedLocationScreen(
                              latitude: latitude[index],
                              longitude: longitude[index],
                              location: locations[index],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(locations[index]),
                        subtitle:
                        Text('lat:${latitude[index]}, long:${longitude[index]}'),
                      ),
                    ),
                    Divider()
                  ],
                );
              },
            );
          } else {
            // If locations is empty, return a message
            return Center(child: Text('Non trouvé'));
          }
        }
      },
    );
  }




  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }
}


class LocationData {
  List<String> locations;
  List<double> latitude;
  List<double> longitude;

  LocationData({
    required this.locations,
    required this.latitude,
    required this.longitude,
  });
}