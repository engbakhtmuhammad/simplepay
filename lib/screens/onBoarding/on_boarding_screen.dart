import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simplepay/utils/constants.dart';
import 'package:simplepay/widgets/custom_btn.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../services/helper.dart';
import '../auth/authentication_bloc.dart';
import '../welcome/welcome_screen.dart';
import 'on_boarding_cubit.dart';

class OnBoardingScreen extends StatefulWidget {
  final List<dynamic> images;
  final List<String> titles, subtitles;

  const OnBoardingScreen(
      {super.key,
      required this.images,
      required this.titles,
      required this.subtitles});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnBoardingCubit(),
      child: Scaffold(
        body: BlocBuilder<OnBoardingCubit, OnBoardingInitial>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  itemBuilder: (context, index) => OnBoardingPage(
                    image: widget.images[index],
                    title: widget.titles[index],
                    subtitle: widget.subtitles[index],
                  ),
                  controller: pageController,
                  itemCount: widget.titles.length,
                  onPageChanged: (int index) {
                    context.read<OnBoardingCubit>().onPageChanged(index);
                  },
                ),
                Visibility(
                  visible: state.currentPageCount + 1 == widget.titles.length,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 30),
                    child: Align(
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child:
                          BlocListener<AuthenticationBloc, AuthenticationState>(
                        listener: (context, state) {
                          if (state.authState == AuthState.unauthenticated) {
                            pushAndRemoveUntil(
                                context, const WelcomeScreen(), false);
                          }
                        },
                        child: SizedBox(
                          width: 120,
                          child: CustomBtn(text: "Continue",onPressed: () {
                              context
                                  .read<AuthenticationBloc>()
                                  .add(FinishedOnBoardingEvent());
                            },),
                        ),
                        
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: widget.titles.length,
                      effect: ScrollingDotsEffect(
                          activeDotColor: isDarkMode(context)?colorPrimaryLight: colorSecondary,
                          dotColor: colorGrey.withOpacity(.5),
                          dotWidth: 8,
                          dotHeight: 8,
                          fixedCenter: true),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  final dynamic image;
  final String title, subtitle;

  const OnBoardingPage(
      {super.key, this.image, required this.title, required this.subtitle});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
                widget.image,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
        const SizedBox(height: 40),
        Text(
          widget.title.toUpperCase(),
          style:  TextStyle(
              color: isDarkMode(context)?colorPrimaryLight:colorSecondary, fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.subtitle,
            style:  TextStyle(color:  isDarkMode(context)?Colors.grey:colorGrey, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
