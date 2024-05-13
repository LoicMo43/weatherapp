import 'package:flutter/material.dart';


class CurrentLocationProvider extends ChangeNotifier{


  double _latitude=0.0;
  double _longitude=0.0;
  String _location='';

  double get latitude => _latitude;

  double get longitude => _longitude;

  String get location => _location;

  set longitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  set latitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  set location(String value) {
    _location = value;
    notifyListeners();
  }
}
