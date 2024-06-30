import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:simplepay/widgets/custom_btn.dart';

import '../../../provider/resetPass_provider.dart';
import '../../../services/helper.dart';
import '../../../utils/constants.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const String routeName = '/resetPass';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResetPasswordProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
          elevation: 0.0,
        ),
        body: Consumer<ResetPasswordProvider>(
          builder: (context, provider, _) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Form(
                key: provider.formKey, // Use form key from provider
                autovalidateMode: AutovalidateMode.disabled,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              provider.validateEmail(value!) ? null : 'Invalid email',
                          onChanged: provider.setEmailAddress,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isDarkMode(context) ? colorPrimaryLight : colorSecondary,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: colorPrimary,
                          decoration: getInputDecoration(
                            hint: 'Email',
                            prefixIcon: const Icon(Icons.mail),
                            darkMode: isDarkMode(context),
                            errorColor: colorError,
                            context: context,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CustomBtn(
                          text: "Send Email",
                          onPressed: () async {
                            provider.checkValidField(context, provider.formKey);
                          },
                        ),
                      ),
                      if (provider.state == ResetPasswordState.failure)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            provider.errorMessage ?? '',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
