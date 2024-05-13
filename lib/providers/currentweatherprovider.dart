import 'package:flutter/material.dart';

import '../models/Current.dart';
import '../models/dailyweather.dart';
import '../models/hourlyweather.dart';

class CurrentWeatherProvider extends ChangeNotifier{
  CurrentWeather? _currentWeather;

  CurrentWeather? get currentWeather => _currentWeather;

  set currentWeather(CurrentWeather? value) {
    _currentWeather = value;
    notifyListeners();
  }

}
