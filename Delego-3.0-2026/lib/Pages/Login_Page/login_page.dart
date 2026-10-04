import 'package:delego/Pages/Profile_Page/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/Login_Page/register_page.dart';
import 'package:delego/Pages/Home_Page/home_page.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/Pages/Login_Page/forgot_password.dart';
import 'package:delego/Theme/theme_controller.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/backgrounds.dart';
import 'package:delego/Widgets/buttons.dart';
import 'package:delego/Widgets/inputs.dart';

class LoginPage extends StatefulWidget {
  final ThemeController controller;
  const LoginPage({super.key, required this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> fetchAndStoreImage(String id) async {
    try {
      final response = await http.get(Uri.parse(Backend.baseUrl + '/qr?id=$id'));
      if (response.statusCode == 200) {
        String base64Image = base64Encode(response.bodyBytes);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('qr', base64Image);
      }
    } catch (_) {}
  }

  Future<void> setLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lib', true);
  }

  Future<bool?> getLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('lib');
  }

  Future<void> clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void signUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields.")),
      );
      return;
    }

    final body = {'username': email, 'password': password};

    try {
      final response = await http.post(
        Uri.parse(Backend.baseUrl + '/login'),
        body: body,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName('utf-8'),
      );
      print('statusCode:${response.statusCode}');
      print('statusBody:${response.body}');
      print('Response headers: ${response.headers}');
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        final String token = responseData['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final response2 = await http.get(
          Uri.parse(Backend.baseUrl + '/delegates/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        final data = json.decode(response2.body);

        if (data['detail'] == 'Please verify your email!') {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['detail']),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
          return;
        }

        final id = data['id'] ?? '';
        await prefs.setString('id', id);
        await prefs.setString('firstname', data['firstname'] ?? '');
        await prefs.setString('lastname', data['lastname'] ?? '');
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('contact', data['contact'] ?? '');
        await prefs.setString('dateofbirth', data['dateofbirth'] ?? '');
        await prefs.setString('gender', data['gender'] ?? '');
        await fetchAndStoreImage(id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(controller: widget.controller),
          ),
        );

        if (await getLoggedInBefore() != true) {
          setLoggedInBefore();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Update Info'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              action: SnackBarAction(
                label: "Profile",
                textColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(controller: widget.controller),
                    ),
                  );
                },
              ),
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['detail'].toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }catch (e) {
  Navigator.of(context).pop();
  
  print('Error: $e');
  print('Error Type: ${e.runtimeType}');
  
  String errorMessage = "An error occurred";
  
  try {
    // Try to parse error from response
    if (e.toString().contains('Bad state') || e.toString().contains('SocketException')) {
      errorMessage = "Cannot connect to server";
    } else {
      // Extract error message from exception string
      final errorString = e.toString();
      
      // If it contains JSON-like content, try to parse it
      if (errorString.contains('{')) {
        final jsonMatch = RegExp(r'\{.*\}').firstMatch(errorString);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0);
          final jsonResponse = jsonDecode(jsonStr!);
          errorMessage = jsonResponse['detail'] ?? 
                        jsonResponse['error'] ?? 
                        jsonResponse['message'] ?? 
                        errorString;
        } else {
          errorMessage = errorString;
        }
      } else {
        errorMessage = errorString;
      }
    }
  } catch (parseError) {
    print('Could not parse error: $parseError');
    errorMessage = e.toString();
  }
  
  print('Extracted Error: $errorMessage');
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: Duration(seconds: 5),
    ),
  );
}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          if (isDark) const Positioned.fill(child: ConstellationScaffoldBackdrop()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GatewayHeroBanner(
                    height: 210,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('WELCOME BACK', style: AppType.eyebrow(AppColors.gold)),
                        const SizedBox(height: 8),
                        Text(
                          'DELEGO',
                          style: AppType.numeral(Colors.white, size: 38)
                              .copyWith(letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppTextField(
                    controller: usernameController,
                    hint: 'Email ID',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: passwordController,
                    hint: 'Password',
                    obscure: true,
                    icon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.hotPink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  PrimaryButton(label: 'Login', onPressed: signUserIn),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
