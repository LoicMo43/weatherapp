import 'package:Weather/providers/currentweatherprovider.dart';
import 'package:Weather/providers/dailyweatherprovider.dart';
import 'package:Weather/providers/haspermissionprovider.dart';
import 'package:Weather/providers/hourlyweatherprovider.dart';
import 'package:Weather/providers/isloadingprovider.dart';
import 'package:Weather/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/currentlocationprovider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentWeatherProvider>(create: (_) => CurrentWeatherProvider()),
        ChangeNotifierProvider<DailyWeatherProvider>(create: (_) => DailyWeatherProvider()),
        ChangeNotifierProvider<HourlyWeatherProvider>(create: (_) => HourlyWeatherProvider()),
        ChangeNotifierProvider<CurrentLocationProvider>(create: (_) => CurrentLocationProvider()),
        ChangeNotifierProvider<hasPermissionProvider>(create: (_) => hasPermissionProvider()),
        ChangeNotifierProvider<isLoadingProvider>(create: (_) => isLoadingProvider()),
      ],
      child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'Weatherapp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
          useMaterial3: true,
        ),
        home:MainScreen(),
      debugShowCheckedModeBanner: false,

    );
  }
}

