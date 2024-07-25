import 'package:flutter/cupertino.dart';

class AppGlobals {
  AppGlobals._();

  static final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

  static bool _isLoggedIn = false;

  static set setLoggedIn(bool isLoggedIn) => _isLoggedIn = isLoggedIn;
  static get getLoggedIn => _isLoggedIn;
}