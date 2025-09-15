import 'package:flutter/material.dart';
import '../presentation/collections_manager/collections_manager.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/map_viewer/map_viewer.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/timeline_browser/timeline_browser.dart';
import '../presentation/map_explorer_home/map_explorer_home.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String collectionsManager = '/collections-manager';
  static const String splash = '/splash-screen';
  static const String mapViewer = '/map-viewer';
  static const String authentication = '/authentication-screen';
  static const String timelineBrowser = '/timeline-browser';
  static const String mapExplorerHome = '/map-explorer-home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    collectionsManager: (context) => const CollectionsManager(),
    splash: (context) => const SplashScreen(),
    mapViewer: (context) => const MapViewer(),
    authentication: (context) => const AuthenticationScreen(),
    timelineBrowser: (context) => const TimelineBrowser(),
    mapExplorerHome: (context) => MapExplorerHome(),
    // TODO: Add your other routes here
  };
}