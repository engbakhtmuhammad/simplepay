import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../welcome/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    if (authProvider.authState == AuthState.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      });
    }

    final user = authProvider.user;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: isDarkMode(context) ? colorBlack : colorWhite,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: colorSecondary,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: colorWhite),
              ),
            ),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(color: isDarkMode(context) ? colorWhite : colorBlack),
              ),
              leading: Transform.rotate(
                angle: pi / 1,
                child: Icon(
                  Icons.exit_to_app,
                  color: isDarkMode(context)
                      ? Colors.grey.shade50
                      : Colors.grey.shade900,
                ),
              ),
              onTap: () {
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
              color: isDarkMode(context)
                  ? Colors.grey.shade50
                  : Colors.grey.shade900),
        ),
        iconTheme: IconThemeData(
            color: isDarkMode(context)
                ? Colors.grey.shade50
                : Colors.grey.shade900),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: user == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  user.profilePictureURL == ''
                      ? CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey.shade400,
                          child: ClipOval(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: Image.asset(
                                'assets/images/placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : displayCircleImage(user.profilePictureURL, 80, false),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.fullName(),
                      style: TextStyle(
                          color: isDarkMode(context) ? colorWhite : colorBlack),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.email,
                      style: TextStyle(
                          color: isDarkMode(context) ? colorWhite : colorBlack),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.userID,
                      style: TextStyle(
                          color: isDarkMode(context) ? colorWhite : colorBlack),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
