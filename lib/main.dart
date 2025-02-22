import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/providers/activity_provider.dart';
import 'package:sav_app/providers/auth_provider.dart';
import 'package:sav_app/providers/command_provider.dart';
import 'package:sav_app/providers/itinerary_provider.dart';
import 'package:sav_app/providers/note_provider.dart';
import 'package:sav_app/providers/notif_provider.dart';
import 'package:sav_app/providers/payment_provider.dart';
import 'package:sav_app/providers/providers.dart';
import 'package:sav_app/screens/authentication/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_router.dart';
import 'config/theme.dart';
import 'constants/http_request.dart';
import 'database/db_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  // initBackgroundFetch();

  //initialization(null);
  //FlutterNativeSplash.remove();
  // WidgetsFlutterBinding.ensureInitialized();
  // await Future.delayed(const Duration(seconds: 3));
  // FlutterNativeSplash.remove();

  Timer.periodic(Duration(minutes: AppUrl.syncroTime), (timer) {
    //print('Hello, world!');
    HttpRequestApp().sendItinerary('CPT');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClientsMapProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => DepotProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => DepotProvider()),
        ChangeNotifierProvider(create: (_) => CommandProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => NotifProvider()),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        title: 'SAV_mobilino',
        debugShowCheckedModeBanner: false,
        theme: customTheme,
        home: LoginPage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
