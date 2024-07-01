import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplepay/services/auth_services.dart';

import '../screens/auth/login/login_screen.dart';

class SignUpProvider with ChangeNotifier {
  Uint8List? _imageData;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, email, password, confirmPassword, phone;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool acceptEULA = false;

  Uint8List? get imageData => _imageData;

  TextEditingController get passwordController => _passwordController;

  TextEditingController get phoneController => _phoneController;

  GlobalKey<FormState> get formKey => _key;

  AutovalidateMode get validateMode => _validate;

  bool get eulaAccepted => acceptEULA;

  void retrieveLostData() async {
    if (!kIsWeb && Platform.isAndroid) {
      final LostDataResponse response = await ImagePicker().retrieveLostData();
      if (response.file != null) {
        _imageData = await response.file!.readAsBytes();
        notifyListeners();
      }
    }
  }

  void chooseImageFromGallery() async {
    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        _imageData = await File(result.files.single.path!).readAsBytes();
        notifyListeners();
      }
    } else {
      XFile? xImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (xImage != null) {
        _imageData = await xImage.readAsBytes();
        notifyListeners();
      }
    }
  }

  void captureImageByCamera() async {
    XFile? xImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (xImage != null) {
      _imageData = await xImage.readAsBytes();
      notifyListeners();
    }
  }

  void validateFields(BuildContext context) {
    if (_key.currentState?.validate() ?? false) {
      if (acceptEULA) {
        _key.currentState!.save();
        AuthService authService =
            Provider.of<AuthService>(context, listen: false);
        authService
            .registerWithEmailPassword(email!, password!, phone!, firstName, lastName, _imageData)
            .then((user) {
          if (user != null) {
            // Account creation successful, navigate to login screen
            MotionToast.success(
              title: const Text("Success"),
              description: const Text('Account created successfully!'),
            ).show(context);
            Navigator.pushNamed(
                context, LoginScreen.routeName); // Navigate to login screen
          } else {
            // Account creation failed
            MotionToast.error(
              title: const Text("Error"),
              description:
                  const Text('Failed to create account. Please try again.'),
            ).show(context);
          }
        });
      } else {
        MotionToast.error(
          title: const Text("Error"),
          description: const Text('Please accept the EULA'),
        ).show(context);
      }
    } else {
      _key.currentState!.validate(); // Trigger validation
    }
  }

  void toggleEulaCheckbox(bool value) {
    acceptEULA = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
