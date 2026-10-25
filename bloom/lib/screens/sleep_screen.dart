import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _bed = 22 * 60 + 30; // 22:30
  int _wake = 7 * 60; // 07:00
  int? _quality;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final old = context.app.sleepOn(today());
    if (old != null) {
      _bed = old.bed;
      _wake = old.wake;
      _quality = old.quality;
    }
  }

  String _clock(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _pick(bool bed) async {
    final current = bed ? _bed : _wake;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) return;
    setState(() {
      final value = picked.hour * 60 + picked.minute;
      if (bed) {
        _bed = value;
      } else {
        _wake = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final entry = SleepEntry(bed: _bed, wake: _wake, quality: _quality ?? 3);
    final hours = entry.hours;
    final tip = hours < 8 ? s.t('sleep_tip_low') : (hours <= 10 ? s.t('sleep_tip_ok') : s.t('sleep_tip_high'));
    final tipColor = hours < 8 ? c.primary : (hours <= 10 ? c.green : c.blue);
    final quality = _quality;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('sleep_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                Expanded(child: _TimeTile(label: s.t('bedtime'), emoji: '🌙', time: _clock(_bed), onTap: () => _pick(true))),
                const SizedBox(width: 12),
                Expanded(child: _TimeTile(label: s.t('waketime'), emoji: '☀️', time: _clock(_wake), onTap: () => _pick(false))),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              borderColor: tipColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.t('you_slept'), style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    formatMinutes(entry.minutes, s.t('h_short'), s.t('m_short')),
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: tipColor),
                  ),
                  const SizedBox(height: 6),
                  Text(tip, style: TextStyle(color: c.text, fontWeight: FontWeight.w600, height: 1.35)),
                ],
              ),
            ),
            SectionTitle(s.t('sleep_quality')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final value = i + 1;
                final isOn = quality == value;
                return GestureDetector(
                  onTap: () => setState(() => _quality = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isOn ? 62 : 54,
                    height: isOn ? 62 : 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOn ? c.primarySoft : c.surface,
                      border: Border.all(color: isOn ? c.primary : c.border, width: 2.5),
                    ),
                    child: Text(moodEmojis[i], style: TextStyle(fontSize: isOn ? 32 : 28)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                quality == null ? ' ' : s.t('mood_$quality'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primary),
              ),
            ),
            const SizedBox(height: 24),
            ChunkyButton(
              label: s.t('save'),
              onTap: quality == null
                  ? null
                  : () {
                      final isNew = app.sleepOn(today()) == null;
                      app.saveSleep(today(), SleepEntry(bed: _bed, wake: _wake, quality: quality));
                      showToast(context, isNew ? s.f('xp_plus', {'n': Xp.sleep}) : s.t('saved'));
                      Navigator.of(context).pop();
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.emoji, required this.time, required this.onTap});

  final String label;
  final String emoji;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(time, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c.text)),
              const Spacer(),
              Icon(Icons.edit_rounded, size: 18, color: c.muted),
            ],
          ),
        ],
      ),
    );
  }
}
