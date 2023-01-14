import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static late SharedPreferences _prefs;
  static String _servicesURL = 'http://';

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get servicesURL{
    return _prefs.getString('servicesURL') ?? _servicesURL;
  }

  static set servicesURL(String servicesURL){
    _servicesURL = servicesURL;
    _prefs.setString('servicesURL', servicesURL);
  }

}
