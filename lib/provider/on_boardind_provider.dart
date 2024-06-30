import 'package:flutter/foundation.dart';

class OnBoardingProvider with ChangeNotifier {
  int _currentPageCount = 0;

  int get currentPageCount => _currentPageCount;

  void onPageChanged(int count) {
    _currentPageCount = count;
    notifyListeners();
  }
}
