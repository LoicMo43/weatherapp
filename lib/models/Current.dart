class CurrentWeather {
  num? _temperature;
  num? _windspeed;
  num? _winddirection;
  num? _weathercode;
  num? _isDay;
  DateTime? _time;

  CurrentWeather(
      {num? temperature,
        num? windspeed,
        num? winddirection,
        num? weathercode,
        num? isDay,
        DateTime? time}) {
    if (temperature != null) {
      this._temperature = temperature;
    }
    if (windspeed != null) {
      this._windspeed = windspeed;
    }
    if (winddirection != null) {
      this._winddirection = winddirection;
    }
    if (weathercode != null) {
      this._weathercode = weathercode;
    }
    if (isDay != null) {
      this._isDay = isDay;
    }
    if (time != null) {
      this._time = time;
    }
  }

  num? get temperature => _temperature;
  set temperature(num? temperature) => _temperature = temperature;
  num? get windspeed => _windspeed;
  set windspeed(num? windspeed) => _windspeed = windspeed;
  num? get winddirection => _winddirection;
  set winddirection(num? winddirection) => _winddirection = winddirection;
  num? get weathercode => _weathercode;
  set weathercode(num? weathercode) => _weathercode = weathercode;
  num? get isDay => _isDay;
  set isDay(num? isDay) => _isDay = isDay;
  DateTime? get time => _time;
  set time(DateTime? time) => _time = time;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    // prnum(json['temperature']+json['windspeed']+json['winddirection']+json['weathercode']+json['is_day']+json['time']);
     return CurrentWeather(temperature:  json['temperature'],
   windspeed:  json['windspeed'],
   winddirection:  json['winddirection'],
   weathercode:   json['weathercode'],
  isDay:  json['is_day'],
  time:   DateTime.parse(json['time']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temperature'] = this._temperature;
    data['windspeed'] = this._windspeed;
    data['winddirection'] = this._winddirection;
    data['weathercode'] = this._weathercode;
    data['is_day'] = this._isDay;
    data['time'] = this._time;
    return data;
  }
}
