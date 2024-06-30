import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:simplepay/widgets/custom_btn.dart';

import '../../../services/helper.dart';
import '../../../utils/constants.dart';
import '../../loading_cubit.dart';
import 'reset_password_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String _emailAddress = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetPasswordCubit>(
      create: (context) => ResetPasswordCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
              elevation: 0.0,
            ),
            body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
              listenWhen: (old, current) => old != current,
              listener: (context, state) async {
                if (state is ResetPasswordDone) {
                  context.read<LoadingCubit>().hideLoading();
                  MotionToast.success(
                          title: const Text("Error"),
                          description: const Text(
                              'Reset password email has been sent, Please check your email.'))
                      .show(context);

                  Navigator.pop(context);
                } else if (state is ValidResetPasswordField) {
                  await context
                      .read<LoadingCubit>()
                      .showLoading(context, 'Sending Email...', false);
                  if (!mounted) return;
                  context
                      .read<ResetPasswordCubit>()
                      .resetPassword(_emailAddress);
                } else if (state is ResetPasswordFailureState) {
                  MotionToast.error(
                          title: const Text("Error"),
                          description: Text(state.errorMessage))
                      .show(context);
                }
              },
              buildWhen: (old, current) =>
                  current is ResetPasswordFailureState && old != current,
              builder: (context, state) {
                if (state is ResetPasswordFailureState) {
                  _validate = AutovalidateMode.onUserInteraction;
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Form(
                    autovalidateMode: _validate,
                    key: _key,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/images/reset pass.png',
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 32.0, right: 24.0, left: 24.0),
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.done,
                              validator: validateEmail,
                              onFieldSubmitted: (_) => context
                                  .read<ResetPasswordCubit>()
                                  .checkValidField(_key),
                              onSaved: (val) => _emailAddress = val!,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: isDarkMode(context)
                                      ? colorPrimaryLight
                                      : colorSecondary),
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: colorPrimary,
                              decoration: getInputDecoration(
                                  hint: 'Email',
                                  prefixIcon: const Icon(
                                    Icons.mail,
                                  ),
                                  darkMode: isDarkMode(context),
                                  errorColor: colorError,
                                  context: context),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 24, left: 24, bottom: 40),
                            child: CustomBtn(
                              text: "Send Email",
                              onPressed: () => context
                                  .read<ResetPasswordCubit>()
                                  .checkValidField(_key),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
