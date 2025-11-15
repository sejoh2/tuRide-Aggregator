import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Auth/ui/sign_in_screen.dart';
import 'package:turide_aggregator/pages/Auth/ui/sign_up_screen.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showSignInPage = true;

  void togglePages() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 400,
      ), // A slightly longer duration for slides
      // Define custom curves for a more "enterprise" feel
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,

      // This builder creates the slide animation
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Use the child's key to determine which direction to slide from
        final bool isSignIn = child.key == const ValueKey('signIn');

        // Slide from the LEFT (-1.0) if it's SignIn
        // Slide from the RIGHT (1.0) if it's SignUp
        final beginOffset = isSignIn
            ? const Offset(-1.0, 0.0)
            : const Offset(1.0, 0.0);

        // Create the Tween
        final tween = Tween<Offset>(begin: beginOffset, end: Offset.zero);

        // AnimatedSwitcher uses this builder for BOTH the incoming and outgoing
        // child, applying `animation` (for in) and `secondaryAnimation` (for out)
        // automatically.
        return SlideTransition(
          position: tween.animate(animation),
          child: child,
        );
      },

      child: showSignInPage
          ? SignIn(
              // **IMPORTANT: Keys are essential for this to work**
              key: const ValueKey('signIn'),
              onTap: togglePages,
            )
          : SignUp(
              // **IMPORTANT: Keys are essential for this to work**
              key: const ValueKey('signUp'),
              onTap: togglePages,
            ),
    );
  }
}
