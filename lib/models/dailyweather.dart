class DailyWeather {
  List<DateTime>? _time;
  List<num>? _weathercode;
  List<num>? _temperature2mMax;
  List<num>? _temperature2mMin;
  List<DateTime>? _sunrise;
  List<DateTime>? _sunset;

  DailyWeather(
      {List<DateTime>? time,
        List<num>? weathercode,
        List<num>? temperature2mMax,
        List<num>? temperature2mMin,
        List<DateTime>? sunrise,
        List<DateTime>? sunset}) {
    if (time != null) {
      this._time = time;
    }
    if (weathercode != null) {
      this._weathercode = weathercode;
    }
    if (temperature2mMax != null) {
      this._temperature2mMax = temperature2mMax;
    }
    if (temperature2mMin != null) {
      this._temperature2mMin = temperature2mMin;
    }
    if (sunrise != null) {
      this._sunrise = sunrise;
    }
    if (sunset != null) {
      this._sunset = sunset;
    }
  }

  List<DateTime>? get time => _time;
  set time(List<DateTime>? time) => _time = time;
  List<num>? get weathercode => _weathercode;
  set weathercode(List<num>? weathercode) => _weathercode = weathercode;
  List<num>? get temperature2mMax => _temperature2mMax;
  set temperature2mMax(List<num>? temperature2mMax) =>
      _temperature2mMax = temperature2mMax;
  List<num>? get temperature2mMin => _temperature2mMin;
  set temperature2mMin(List<num>? temperature2mMin) =>
      _temperature2mMin = temperature2mMin;
  List<DateTime>? get sunrise => _sunrise;
  set sunrise(List<DateTime>? sunrise) => _sunrise = sunrise;
  List<DateTime>? get sunset => _sunset;
  set sunset(List<DateTime>? sunset) => _sunset = sunset;

  DailyWeather.fromJson(Map<String, dynamic> json) {
    _time = (json['time'] as List).map((timeString) => DateTime.parse(timeString)).toList();
    _weathercode = (json['weathercode'] as List).cast<num>();
    _temperature2mMax = (json['temperature_2m_max'] as List).cast<num>();
    _temperature2mMin = (json['temperature_2m_min'] as List).cast<num>();
    _sunrise = (json['sunrise'] as List).map((sunriseString) => DateTime.parse(sunriseString)).toList();
    _sunset = (json['sunset'] as List).map((sunsetString) => DateTime.parse(sunsetString)).toList();
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this._time;
    data['weathercode'] = this._weathercode;
    data['temperature_2m_max'] = this._temperature2mMax;
    data['temperature_2m_min'] = this._temperature2mMin;
    data['sunrise'] = this._sunrise;
    data['sunset'] = this._sunset;
    return data;
  }
}
