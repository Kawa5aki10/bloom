import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../main.dart' show appName;
import '../widgets/common.dart';
import '../widgets/mascot.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _name.text = context.app.name;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final app = context.app;
    final s = context.s;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s.t('reset_q'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(s.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.t('delete'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (yes == true) {
      _name.clear();
      app.resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(s.t('profile_title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c.text)),
          const SizedBox(height: 16),
          SectionTitle(s.t('your_name')),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            onChanged: app.setName,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded)),
          ),
          SectionTitle(s.t('language')),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ru', label: Text('Русский')),
              ],
              selected: {app.lang},
              onSelectionChanged: (v) => app.setLang(v.first),
            ),
          ),
          SectionTitle(s.t('theme')),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(s.t('theme_system'))),
                ButtonSegment(value: ThemeMode.light, label: Text(s.t('theme_light'))),
                ButtonSegment(value: ThemeMode.dark, label: Text(s.t('theme_dark'))),
              ],
              selected: {app.themeMode},
              onSelectionChanged: (v) => app.setTheme(v.first),
            ),
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Row(
              children: [
                const Mascot(size: 64, mood: 4),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c.text)),
                      const SizedBox(height: 4),
                      Text(s.t('about'), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.lock_rounded, color: c.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.t('privacy'), style: TextStyle(color: c.text, fontWeight: FontWeight.w600, height: 1.3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: _confirmReset,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              label: Text(s.t('reset'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
