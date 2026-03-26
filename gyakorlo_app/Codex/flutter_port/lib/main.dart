import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'szakmasztar2_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(Szakmasztar2App(preferences: preferences));
}
