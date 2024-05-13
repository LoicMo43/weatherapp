import 'package:flutter/material.dart';

import '../models/dailyweather.dart';
import '../models/hourlyweather.dart';

class DailyWeatherProvider extends ChangeNotifier{


DailyWeather? _dailyWeather;

DailyWeather? get dailyWeather => _dailyWeather;

set dailyWeather(DailyWeather? value) {
  _dailyWeather = value;
  notifyListeners();
}
}
