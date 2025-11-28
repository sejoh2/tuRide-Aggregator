import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Auth/sign_up_or_sign_in_toggle.dart';
import 'package:turide_aggregator/pages/Auth/ui/my_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 70),
          child: Column(
            children: [
              const SizedBox(height: 90),
              Center(
                child: Text(
                  'Welcome to tu_Ride',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),

              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'lib/images/500-removebg-preview.png',
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),

                      Positioned(
                        top: 2,
                        left: 2,
                        child: Image.asset(
                          'lib/images/bolt-taxi-app-icon-removebg-preview.png',
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Image.asset(
                          'lib/images/uber-app-icon-removebg-preview.png',
                          height: 40,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 2,
                        child: Image.asset(
                          'lib/images/1200x630wa-removebg-preview.png',
                          height: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 40,
                        child: Image.asset(
                          'lib/images/jBun0F3d2fUSWN_XM5K6Y5qjJ0EZP-ohWwNSs-jSwR1WeQmBfLlVgXh_K72DLy9rBA.png',
                          height: 40,
                        ),
                      ),

                      Positioned(
                        top: -15,
                        child: Image.asset(
                          'lib/images/icon-removebg-preview.png',
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Text(
                'Compare rideshares prices in ',
                style: TextStyle(fontSize: 18),
              ),

              Text('realtime for free', style: TextStyle(fontSize: 18)),

              const SizedBox(height: 30),

              MyButton(
                text: 'Get Started',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginOrRegisterPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Column(
                children: [
                  Text(
                    'By Geting started you agree to tuRide\'s',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Terms Of Use',
                    style: TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
