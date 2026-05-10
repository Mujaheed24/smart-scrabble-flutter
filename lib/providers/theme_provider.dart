import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  bool isDark = Hive.box('scrabbleBox').get('isDark', defaultValue: false);
  
  void toggle(bool val) {
    isDark = val;
    Hive.box('scrabbleBox').put('isDark', val);
    notifyListeners();
  }
}