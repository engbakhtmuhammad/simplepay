import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simplepay/provider/login_provider.dart';
import 'package:simplepay/provider/signup_provider.dart';
import 'package:simplepay/provider/welcome_provider.dart';
import 'package:simplepay/services/auth_services.dart';

import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'provider/on_boardind_provider.dart';
import 'provider/resetPass_provider.dart';
import 'screens/launcherScreen/launcher_screen.dart';
import 'screens/loading_cubit.dart';
import 'services/routes.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => LoginProvider()),
      ChangeNotifierProvider(create: (_) => SignUpProvider()),
      ChangeNotifierProvider(create: (_) => WelcomeProvider()),
      ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
      ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
      Provider(create: (_) => LoadingCubit()), 
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } else {
        await Firebase.initializeApp();
      }
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorError,
                    size: 25,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to initialise firebase!',
                    style: TextStyle(color: colorError, fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
        snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(color: Colors.white)),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: colorPrimary,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade800,
        appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
        snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(color: Colors.white)),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: colorPrimary,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      color: colorPrimary,
      home: const LauncherScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}
