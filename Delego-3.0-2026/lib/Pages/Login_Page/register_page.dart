import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delego/constants/backend.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/backgrounds.dart';
import 'package:delego/Widgets/buttons.dart';
import 'package:delego/Widgets/inputs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> signUserUp() async {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    if (password != confirmPassword) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    if (password.length < 8) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters long.")),
      );
      return;
    }

    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('${Backend.baseUrl}/mumbaimun/register'),
        body: jsonEncode(body),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registration successful. Please verify your email."),
            backgroundColor: scheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['detail'].toString()),
            backgroundColor: scheme.error,
          ),
        );
      }
    } catch (_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("An error occurred. Please check your internet connection."),
          backgroundColor: scheme.error,
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
                    height: 190,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('JOIN THE DELEGATION', style: AppType.eyebrow(AppColors.gold)),
                        const SizedBox(height: 8),
                        Text(
                          'Create Account',
                          style: AppType.numeral(Colors.white, size: 26),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  AppTextField(
                    controller: firstNameController,
                    hint: 'First Name',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: lastNameController,
                    hint: 'Last Name',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: usernameController,
                    hint: 'Email ID',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: passwordController,
                    hint: 'Password',
                    obscure: true,
                    icon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: confirmPasswordController,
                    hint: 'Confirm Password',
                    obscure: true,
                    icon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(label: 'Sign Up', onPressed: signUserUp),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
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
