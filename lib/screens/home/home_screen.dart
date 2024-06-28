import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';
import '../../services/helper.dart';
import '../../utils/constants.dart';
import '../auth/authentication_bloc.dart';
import '../welcome/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: isDarkMode(context)?colorBlack:colorWhite,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
               const DrawerHeader(
                decoration: BoxDecoration(
                  color: colorSecondary,
                ),
                child: Text(
                  'Drawer Header'
                 ,style: TextStyle(color: colorWhite),
                ),
              ),
              ListTile(
                title: Text(
                  'Logout',style: TextStyle(color: isDarkMode(context)?colorWhite:colorBlack),
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
                  context.read<AuthenticationBloc>().add(LogoutEvent());
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
          child: Column(
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
                child: Text(user.fullName(),style: TextStyle(color: isDarkMode(context)?colorWhite:colorBlack),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(user.email,style: TextStyle(color: isDarkMode(context)?colorWhite:colorBlack),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(user.userID,style: TextStyle(color: isDarkMode(context)?colorWhite:colorBlack),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
