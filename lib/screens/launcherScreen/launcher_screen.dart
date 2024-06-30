import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';
import '../onBoarding/data.dart';
import '../onBoarding/on_boarding_screen.dart';
import '../welcome/welcome_screen.dart';

class LauncherScreen extends StatefulWidget {
  static const String routeName = '/launcher';
  const LauncherScreen({Key? key}) : super(key: key);

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  void initState() {
    super.initState();
    // This will trigger checkFirstRun in AuthenticationProvider
    Provider.of<AuthenticationProvider>(context, listen: false).checkFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          switch (authProvider.authState) {
            case AuthState.firstRun:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pushReplacement(
                  context,
                  OnBoardingScreen(
                    images: imageList,
                    titles: titlesList,
                    subtitles: subtitlesList,
                  ),
                );
              });
              break;
            case AuthState.authenticated:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pushReplacement(context, const HomeScreen());
              });
              break;
            case AuthState.unauthenticated:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pushReplacement(context, const WelcomeScreen());
              });
              break;
            default:
              // Handle any additional states or do nothing
              break;
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(colorPrimary),
            ),
          );
        },
      ),
    );
  }
}
