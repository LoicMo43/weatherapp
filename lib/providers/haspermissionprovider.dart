
import 'package:flutter/material.dart';

class hasPermissionProvider extends ChangeNotifier{


  bool _hasPermission=false;

  bool get hasPermission => _hasPermission;

  set hasPermission(bool value) {
    _hasPermission = value;
    notifyListeners();
  }
}
