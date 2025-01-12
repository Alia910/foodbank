import 'package:flutter/material.dart';
import 'package:foodbank/signin.dart';
import 'package:foodbank/signup.dart';
import 'package:foodbank/theme/theme.dart';
import 'package:foodbank/widgets/custom_scaffold.dart';
import 'package:foodbank/widgets/welcome_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackButton: false, // Ensuring the back button does not appear
      backgroundImage: 'assets/images/bg1.png', // Provide custom background image
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome to\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF083C81),
                          fontFamily: 'Welcome',
                        ),
                      ),
                      TextSpan(
                        text: '\nFood Bank Locator',
                        style: TextStyle(
                          fontSize: 28,
                          color: Color(0xFF083C81),
                          fontFamily: 'FB',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInPage(),
                      color: Colors.transparent,
                      textColor: Color(0xFF083C81),
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const SignUpPage(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
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
