import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';

/// One step of a breathing exercise.
class BreathStep {
  const BreathStep(this.textKey, this.seconds, this.scale);

  final String textKey; // breathe_in / hold / breathe_out
  final int seconds;
  final double scale; // circle size at the end of the step
}

class BreathExercise {
  const BreathExercise({
    required this.titleKey,
    required this.descKey,
    required this.emoji,
    required this.color,
    required this.steps,
    required this.rounds,
  });

  final String titleKey;
  final String descKey;
  final String emoji;
  final int color;
  final List<BreathStep> steps;
  final int rounds;

  int get totalSeconds => steps.fold(0, (sum, st) => sum + st.seconds) * rounds;
}

const breathExercises = <BreathExercise>[
  BreathExercise(
    titleKey: 'ex_box',
    descKey: 'ex_box_d',
    emoji: '🟧',
    color: 0xFFFF8A3D,
    rounds: 4,
    steps: [
      BreathStep('breathe_in', 4, 1.0),
      BreathStep('hold', 4, 1.0),
      BreathStep('breathe_out', 4, 0.55),
      BreathStep('hold', 4, 0.55),
    ],
  ),
  BreathExercise(
    titleKey: 'ex_478',
    descKey: 'ex_478_d',
    emoji: '🌙',
    color: 0xFF9B7FE0,
    rounds: 4,
    steps: [
      BreathStep('breathe_in', 4, 1.0),
      BreathStep('hold', 7, 1.0),
      BreathStep('breathe_out', 8, 0.55),
    ],
  ),
  BreathExercise(
    titleKey: 'ex_calm',
    descKey: 'ex_calm_d',
    emoji: '🌊',
    color: 0xFF5AA9E6,
    rounds: 12,
    steps: [
      BreathStep('breathe_in', 4, 1.0),
      BreathStep('breathe_out', 6, 0.55),
    ],
  ),
];

class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(s.t('relax_title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c.text)),
          const SizedBox(height: 4),
          Text(s.t('relax_sub'), style: TextStyle(fontSize: 15, color: c.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          for (final ex in breathExercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                emoji: ex.emoji,
                color: Color(ex.color),
                title: s.t(ex.titleKey),
                desc: s.t(ex.descKey),
                minutes: (ex.totalSeconds / 60).ceil(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BreathingScreen(exercise: ex)),
                ),
              ),
            ),
          _ExerciseCard(
            emoji: '👀',
            color: c.green,
            title: s.t('ex_ground'),
            desc: s.t('ex_ground_d'),
            minutes: 3,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GroundingScreen())),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.emoji,
    required this.color,
    required this.title,
    required this.desc,
    required this.minutes,
    required this.onTap,
  });

  final String emoji;
  final Color color;
  final String title;
  final String desc;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(16)),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text)),
                const SizedBox(height: 3),
                Text(desc, style: TextStyle(fontSize: 13.5, color: c.muted, fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 6),
                Text(
                  context.s.f('minutes', {'n': minutes}),
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: color, size: 36),
        ],
      ),
    );
  }
}

/// Animated breathing exercise: the circle grows when you breathe in
/// and gets smaller when you breathe out.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key, required this.exercise});

  final BreathExercise exercise;

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  Timer? _timer;
  bool _running = false;
  bool _finished = false;
  int _step = 0;
  int _round = 0;
  int _left = 0;
  double _scale = 0.55;

  List<BreathStep> get _steps => widget.exercise.steps;

  void _start() {
    _timer?.cancel();
    setState(() {
      _running = true;
      _finished = false;
      _step = 0;
      _round = 0;
      _left = _steps[0].seconds;
      _scale = _steps[0].scale;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  late AppState _app;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _app = context.app;
  }

  void _tick() {
    if (!mounted) return;
    var done = false;
    setState(() {
      _left--;
      if (_left > 0) return;
      _step++;
      if (_step >= _steps.length) {
        _step = 0;
        _round++;
      }
      if (_round >= widget.exercise.rounds) {
        _timer?.cancel();
        _running = false;
        _finished = true;
        _scale = 0.55;
        done = true;
        return;
      }
      _left = _steps[_step].seconds;
      _scale = _steps[_step].scale;
    });
    if (done) _app.addRelax(today());
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _scale = 0.55;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    final color = Color(widget.exercise.color);
    final step = _steps[_step];
    final size = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(title: Text(s.t(widget.exercise.titleKey))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _finished
              ? _DoneView(onAgain: _start)
              : Column(
                  children: [
                    Text(
                      _running
                          ? s.f('round', {'a': _round + 1, 'b': widget.exercise.rounds})
                          : s.t(widget.exercise.descKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: Center(
                            child: AnimatedContainer(
                              duration: Duration(seconds: _running ? step.seconds : 1),
                              curve: Curves.easeInOut,
                              width: size * _scale,
                              height: size * _scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.22),
                                border: Border.all(color: color, width: 4),
                              ),
                              alignment: Alignment.center,
                              child: _running
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          s.t(step.textKey),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.text),
                                        ),
                                        Text(
                                          '$_left',
                                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: color),
                                        ),
                                      ],
                                    )
                                  : Text(widget.exercise.emoji, style: const TextStyle(fontSize: 44)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!_running)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          s.t('get_ready'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.muted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    _running
                        ? ChunkyButton(
                            label: s.t('stop'),
                            color: c.surface,
                            shadowColor: c.border,
                            textColor: c.text,
                            onTap: _stop,
                          )
                        : ChunkyButton(label: s.t('start'), color: color, shadowColor: Color.lerp(color, Colors.black, 0.2), onTap: _start),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onAgain});

  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    return Column(
      children: [
        const Spacer(),
        const Mascot(size: 140, mood: 5),
        const SizedBox(height: 20),
        Text(s.t('well_done'), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: c.text)),
        const SizedBox(height: 8),
        Text(
          '${s.t('relax_done')} ${s.f('xp_plus', {'n': Xp.relax})}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: c.muted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        ChunkyButton(label: s.t('finish'), onTap: () => Navigator.of(context).pop()),
        const SizedBox(height: 10),
        ChunkyButton(label: s.t('again'), color: c.surface, shadowColor: c.border, textColor: c.text, onTap: onAgain),
      ],
    );
  }
}

/// 5-4-3-2-1 grounding exercise.
class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  int _step = 0; // 0..4 → 5,4,3,2,1
  bool _finished = false;

  static const _emojis = ['👀', '✋', '👂', '👃', '👅'];

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      context.app.addRelax(today());
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    final number = 5 - _step;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('ex_ground'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _finished
              ? _DoneView(
                  onAgain: () => setState(() {
                    _step = 0;
                    _finished = false;
                  }),
                )
              : Column(
                  children: [
                    // Progress dots
                    Row(
                      children: List.generate(5, (i) {
                        return Expanded(
                          child: Container(
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i <= _step ? c.green : c.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    Text(_emojis[_step], style: const TextStyle(fontSize: 70)),
                    const SizedBox(height: 10),
                    Text('$number', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: c.green)),
                    const SizedBox(height: 10),
                    Text(
                      s.t('ground_$number'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text, height: 1.3),
                    ),
                    const Spacer(),
                    ChunkyButton(
                      label: _step < 4 ? s.t('next') : s.t('finish'),
                      color: c.green,
                      shadowColor: c.greenDark,
                      onTap: _next,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
