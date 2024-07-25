import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:todo_list_app/features/splash_screen.dart';
import 'package:todo_list_app/features/todo_list_screen.dart';

class RouteGenerator {
  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);

  ///screen routes
  static const String splashScreenRoute = '/splash_screen';
  static const String todoListScreenRoute = '/todo_list_screen';

  static const initialRoute = todoListScreenRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    log("Pushed ${settings.name}(${args ?? ''})");
    switch (settings.name) {
      case splashScreenRoute:
        return _route(const SplashScreen());
      case todoListScreenRoute:
        return _route(TodoListScreen());
      default:
        return _errorRoute(settings.name);
    }
  }

  static PageTransition _route(Widget widget) => PageTransition(
      type: PageTransitionType.rightToLeft,
      child: widget,
      duration: _pageTransitionDuration);

  static Route<dynamic> _errorRoute(String? name) {
    return _route(
      Scaffold(
        body: Center(
          child: Text('ROUTE\n\n$name\n\nNOT FOUND'),
        ),
      ),
    );
  }
}