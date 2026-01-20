import 'package:flutter/material.dart';
import 'package:ergo_life_app/ui/screens/common/simple_webview_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual hosted URL
    const url = 'https://ergolife-landing.e-tech.network/terms';

    return const SimpleWebViewScreen(url: url, title: 'Terms of Service');
  }
}
