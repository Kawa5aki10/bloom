import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import 'habits_screen.dart';
import 'mood_screen.dart';
import 'sleep_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final day = today();
    final mood = app.moodOn(day);
    final sleep = app.sleepOn(day);

    String sunnyText;
    var sunnyMood = 4;
    if (mood == null && sleep == null) {
      sunnyText = s.t('sunny_start');
    } else if (mood == null || sleep == null) {
      sunnyText = s.t('sunny_half');
    } else if (mood.mood <= 2) {
      sunnyText = s.t('sunny_sad');
      sunnyMood = 3;
    } else {
      sunnyText = s.t('sunny_good');
      sunnyMood = 5;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name.isEmpty ? s.t('hello_noname') : s.f('hello', {'name': app.name}),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c.text),
                    ),
                    const SizedBox(height: 2),
                    Text(s.t('how_today'), style: TextStyle(fontSize: 15, color: c.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              StatPill(emoji: '🔥', value: '${app.streak}', color: c.primary),
              const SizedBox(width: 8),
              StatPill(emoji: '⭐', value: '${app.xp}', color: const Color(0xFFE8A200)),
            ],
          ),
          const SizedBox(height: 20),

          // Mascot with a speech bubble
          AppCard(
            color: c.primarySoft,
            borderColor: c.primarySoft,
            child: Row(
              children: [
                Mascot(size: 86, mood: sunnyMood),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sunnyText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text, height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          // Check-in
          SectionTitle(s.t('checkin_title')),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CheckCard(
                  title: s.t('mood_card'),
                  emoji: mood == null ? '🙂' : moodEmojis[mood.mood - 1],
                  value: mood == null ? s.t('tap_to_add') : s.t('mood_${mood.mood}'),
                  done: mood != null,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CheckCard(
                  title: s.t('sleep_card'),
                  emoji: '😴',
                  value: sleep == null ? s.t('tap_to_add') : formatMinutes(sleep.minutes, s.t('h_short'), s.t('m_short')),
                  done: sleep != null,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SleepScreen())),
                ),
              ),
            ],
          ),

          // Daily challenge
          SectionTitle(s.t('challenge_title')),
          _ChallengeCard(day: day),

          // Habits
          SectionTitle(
            s.t('habits_title'),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
              child: Text(s.t('habits_edit'), style: TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
            ),
          ),
          if (app.habits.isEmpty)
            AppCard(child: Text(s.t('habits_empty'), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)))
          else
            ...app.habits.map((h) {
              final done = app.isHabitDone(day, h.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => app.toggleHabit(day, h.id),
                  color: done ? c.greenSoft : null,
                  borderColor: done ? c.green : null,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(h.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          h.name(s),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? c.green : Colors.transparent,
                          border: Border.all(color: done ? c.green : c.border, width: 2.5),
                        ),
                        child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.title,
    required this.emoji,
    required this.value,
    required this.done,
    required this.onTap,
  });

  final String title;
  final String emoji;
  final String value;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      borderColor: done ? c.green : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 34)),
              const Spacer(),
              if (done) Icon(Icons.check_circle_rounded, color: c.green, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: done ? c.greenDark : c.muted),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final done = app.isChallengeDone(day);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.t('c${app.challengeIndex(day)}'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (done)
            Row(
              children: [
                Icon(Icons.celebration_rounded, color: c.green),
                const SizedBox(width: 8),
                Text(s.t('challenge_done'), style: TextStyle(color: c.greenDark, fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            )
          else
            ChunkyButton(
              label: s.t('mark_done'),
              color: c.green,
              shadowColor: c.greenDark,
              onTap: () {
                app.completeChallenge(day);
                showToast(context, s.f('xp_plus', {'n': Xp.challenge}));
              },
            ),
        ],
      ),
    );
  }
}
