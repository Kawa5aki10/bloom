import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final end = today();
    final days = List.generate(7, (i) => addDays(end, i - 6));
    final labels = days.map((d) => s.t('d${d.weekday}')).toList();

    final moodValues = days.map((d) => app.moodOn(d)?.mood.toDouble()).toList();
    final sleepValues = days.map((d) => app.sleepOn(d)?.hours).toList();
    final habitValues = days.map((d) {
      final n = app.habitsDoneOn(d);
      return n == 0 ? null : n.toDouble();
    }).toList();

    final sleepKnown = sleepValues.whereType<double>().toList();
    final avgSleep = sleepKnown.isEmpty ? null : sleepKnown.reduce((a, b) => a + b) / sleepKnown.length;
    final maxHabits = app.habits.isEmpty ? 4.0 : app.habits.length.toDouble();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(s.t('progress_title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c.text)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _BigStat(emoji: '🔥', value: '${app.streak}', label: s.t('streak'), color: c.primary)),
              const SizedBox(width: 10),
              Expanded(child: _BigStat(emoji: '⭐', value: '${app.xp}', label: s.t('xp'), color: const Color(0xFFE8A200))),
              const SizedBox(width: 10),
              Expanded(child: _BigStat(emoji: '📅', value: '${app.activeDaysTotal}', label: s.t('active_days'), color: c.green)),
            ],
          ),
          SectionTitle(s.t('this_week')),
          _ChartCard(
            title: s.t('mood_week'),
            values: moodValues,
            labels: labels,
            maxValue: 5,
            colorFor: (v) => [
              const Color(0xFFE5675E),
              const Color(0xFFF2A65A),
              const Color(0xFFF5CF4E),
              const Color(0xFF9BCB5A),
              const Color(0xFF6CBF4B),
            ][_moodIndex(v)],
            topLabel: (v) => moodEmojis[_moodIndex(v)],
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: s.t('sleep_week'),
            subtitle: avgSleep == null
                ? null
                : s.f('avg_sleep', {'h': formatMinutes((avgSleep * 60).round(), s.t('h_short'), s.t('m_short'))}),
            values: sleepValues,
            labels: labels,
            maxValue: 12,
            colorFor: (v) => v >= 8 ? c.blue : c.primary,
            topLabel: (v) => v.toStringAsFixed(1),
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: s.t('habits_week'),
            values: habitValues,
            labels: labels,
            maxValue: maxHabits,
            colorFor: (_) => c.green,
            topLabel: (v) => v.round().toString(),
          ),
        ],
      ),
    );
  }
}

int _moodIndex(double v) {
  final i = v.round() - 1;
  if (i < 0) return 0;
  if (i > 4) return 4;
  return i;
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.emoji, required this.value, required this.label, required this.color});

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// Simple bar chart for 7 days.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.colorFor,
    required this.topLabel,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<double?> values;
  final List<String> labels;
  final double maxValue;
  final Color Function(double) colorFor;
  final String Function(double) topLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = context.s;
    const chartHeight = 110.0;
    final hasData = values.any((v) => v != null);
    final sub = subtitle;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.muted)),
          ],
          const SizedBox(height: 14),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(s.t('no_data'), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final v = values[i];
                final h = v == null ? 6.0 : (chartHeight * (v / maxValue)).clamp(10.0, chartHeight).toDouble();
                return Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 22,
                        child: v == null
                            ? null
                            : FittedBox(
                                child: Text(
                                  topLabel(v),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.text),
                                ),
                              ),
                      ),
                      Container(
                        height: chartHeight,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: h,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: v == null ? c.border : colorFor(v),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.muted)),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
