import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Auth/auth_google_sign_in_logic.dart';
import 'package:turide_aggregator/pages/Auth/auth_sign_in_logic.dart';
import 'package:turide_aggregator/pages/Auth/ui/forgot_password_dialog.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_button.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_text_field.dart';

class SignIn extends StatefulWidget {
  final Function()? onTap;
  const SignIn({super.key, required this.onTap});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthSignInLogic _authLogic = AuthSignInLogic();
  final AuthGoogleSignInLogic _googleSignInLogic = AuthGoogleSignInLogic();

  bool isChecked = false;

  static const double _headerHeightRatio = 0.25;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),

          child: IntrinsicHeight(
            child: Column(
              children: [
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

                Expanded(
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
                            'Welcome back to tuRide🙂',
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'You\'ve been missed!',
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
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
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.black,
                                  ),
                                  const Text('Remember me'),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const ForgotPasswordDialog(),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      await _googleSignInLogic.signInWithGoogle(
                                        context,
                                      );
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'lib/images/apple.png',
                                        height: 30,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Apple'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Don\'t have an account?'),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Text(
                                  'Register.',
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
                            text: 'Log In',
                            onTap: () async {
                              final success = await _authLogic.signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                context: context,
                              );

                              if (success && mounted) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
