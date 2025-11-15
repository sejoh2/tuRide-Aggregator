import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Auth/auth_google_sign_in_logic.dart';
import 'package:turide_aggregator/pages/Auth/auth_sign_up_logic.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_button.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_text_field.dart';

class SignUp extends StatefulWidget {
  final Function()? onTap;
  const SignUp({super.key, required this.onTap});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthGoogleSignInLogic _googleSignInLogic = AuthGoogleSignInLogic();
  final AuthSignUpLogic _authLogic = AuthSignUpLogic();

  bool isLoading = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  static const double _headerHeightRatio = 0.25;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade400,

          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. Logo/Header Container (Fixed Height)
                    Container(
                      color: Colors.grey.shade400,
                      height: screenHeight * _headerHeightRatio,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'tu',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'lib/images/download__2_-removebg-preview.png',
                                width: 32,
                                height: 32,
                              ),
                              const Text(
                                'ide',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Find the best ride',
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      child: Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 40),
                                const Text(
                                  'Welcome to tuRide🙂',
                                  style: TextStyle(fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Lets Create an account for you!',
                                  style: TextStyle(fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Full Name'),
                                ),
                                MyTextField(
                                  controller: nameController,
                                  hintText: 'Enter Full Name',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.grey[500],
                                  ),
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Email'),
                                ),
                                MyTextField(
                                  controller: emailController,
                                  hintText: 'Enter Email',
                                  prefixIcon: Icon(
                                    Icons.mail,
                                    color: Colors.grey[500],
                                  ),
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('Password'),
                                ),
                                MyTextField(
                                  controller: passwordController,
                                  hintText: 'Enter Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.grey[500],
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            await _googleSignInLogic
                                                .signInWithGoogle(context);
                                            if (mounted &&
                                                ModalRoute.of(
                                                      context,
                                                    )?.settings.name ==
                                                    '/homescreen') {
                                              emailController.clear();
                                              passwordController.clear();
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'lib/images/google.png',
                                                height: 30,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text('Google'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.apple, size: 30),
                                            SizedBox(width: 5),
                                            Text('Apple'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Already have an account?'),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: widget.onTap,
                                      child: const Text(
                                        'Log In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                MyButton(
                                  text: 'Sign Up',
                                  onTap: isLoading
                                      ? null
                                      : () async {
                                          if (!mounted) return;
                                          setState(() {
                                            isLoading = true; // 🔹 Show loading
                                          });

                                          final success = await _authLogic
                                              .signUp(
                                                name: nameController.text
                                                    .trim(),
                                                email: emailController.text
                                                    .trim(),
                                                password: passwordController
                                                    .text
                                                    .trim(),
                                                context: context,
                                              );

                                          if (!mounted) return; // <-- Important
                                          setState(() {
                                            isLoading =
                                                false; // 🔹 Hide loading
                                          });

                                          if (success) {
                                            nameController.clear();
                                            emailController.clear();
                                            passwordController.clear();
                                          }
                                        },
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            height: double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
