import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

/// First screen: choose a language and say your name.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;

    Widget langButton(String code, String label) {
      final isOn = app.lang == code;
      return Expanded(
        child: GestureDetector(
          onTap: () => app.setLang(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isOn ? c.primarySoft : c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isOn ? c.primary : c.border, width: 2),
            ),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isOn ? c.primaryDark : c.text),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Center(child: Mascot(size: 170, mood: 5)),
            const SizedBox(height: 20),
            Text(
              s.t('welcome_title'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: c.text),
            ),
            const SizedBox(height: 10),
            Text(
              s.t('welcome_text'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: c.muted, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                langButton('en', 'English'),
                const SizedBox(width: 12),
                langButton('ru', 'Русский'),
              ],
            ),
            const SizedBox(height: 20),
            Text(s.t('whats_name'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.text)),
            const SizedBox(height: 10),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded)),
            ),
            const SizedBox(height: 28),
            ChunkyButton(
              label: s.t('lets_go'),
              onTap: () {
                app.setName(_name.text);
                app.finishOnboarding();
              },
            ),
          ],
        ),
      ),
    );
  }
}
