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

  @override
  void dispose() {
    nameController.dispose();
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
        child: Column(
          children: [
            Container(
              color: Colors.grey.shade400,
              height: screenHeight * 0.25,
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
                      'Welcome to CelebRide🙂',
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
                      prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
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
                      prefixIcon: Icon(Icons.mail, color: Colors.grey[500]),
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
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'or',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await _googleSignInLogic.signInWithGoogle(
                                context,
                              );
                              // ✅ Only clear if user reached home screen
                              if (mounted &&
                                  ModalRoute.of(context)?.settings.name ==
                                      '/homescreen') {
                                nameController.clear();
                                emailController.clear();
                                passwordController.clear();
                              }
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'lib/images/google.png',
                                  height: 40,
                                ),
                                const SizedBox(width: 5),
                                const Text('Google'),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset('lib/images/apple.png', height: 40),
                              const SizedBox(width: 5),
                              const Text('Apple'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                      onTap: () async {
                        final success = await _authLogic.signUp(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          context: context,
                        );

                        // ✅ Only clear if navigation was successful
                        if (success && mounted) {
                          nameController.clear();
                          emailController.clear();
                          passwordController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
