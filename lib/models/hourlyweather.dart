class HourlyWeather {
  List<DateTime>? _time;
  List<num>? _temperature2m;
  List<num>? _weathercode;
  List<num>? _isDay;

  HourlyWeather(
      {List<DateTime>? time,
        List<num>? temperature2m,
        List<num>? weathercode,
        List<num>? isDay}) {
    if (time != null) {
      this._time = time;
    }
    if (temperature2m != null) {
      this._temperature2m = temperature2m;
    }
    if (weathercode != null) {
      this._weathercode = weathercode;
    }
    if (isDay != null) {
      this._isDay = isDay;
    }
  }

  List<DateTime>? get time => _time;
  set time(List<DateTime>? time) => _time = time;
  List<num>? get temperature2m => _temperature2m;
  set temperature2m(List<num>? temperature2m) => _temperature2m = temperature2m;
  List<num>? get weathercode => _weathercode;
  set weathercode(List<num>? weathercode) => _weathercode = weathercode;
  List<num>? get isDay => _isDay;
  set isDay(List<num>? isDay) => _isDay = isDay;

  HourlyWeather.fromJson(Map<String, dynamic> json) {
    List<String> timeStrings = List.castFrom<dynamic, String>(json['time']);
    _time = timeStrings.map((timeString) => DateTime.parse(timeString)).toList();
    _temperature2m = json['temperature_2m'].cast<num>();
    _weathercode = json['weathercode'].cast<num>();
    _isDay = json['is_day'].cast<num>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this._time;
    data['temperature_2m'] = this._temperature2m;
    data['weathercode'] = this._weathercode;
    data['is_day'] = this._isDay;
    return data;
  }
}
