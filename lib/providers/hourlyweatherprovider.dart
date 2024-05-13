import 'package:flutter/material.dart';

import '../models/hourlyweather.dart';

class HourlyWeatherProvider extends ChangeNotifier{


  HourlyWeather? _hourlyWeather;

  HourlyWeather? get hourlyWeather => _hourlyWeather;

  set hourlyWeather(HourlyWeather? value) {
    _hourlyWeather = value;
    notifyListeners();
  }


}
