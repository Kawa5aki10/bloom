import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../widgets/common.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  static const icons = ['💧', '🚶', '📵', '🍎', '📚', '🧘', '🏃', '🥦', '😴', '✍️', '🎵', '🦷'];

  Future<void> _add(BuildContext context) async {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final controller = TextEditingController();
    var emoji = icons.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t('add_habit'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.text)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: s.t('habit_name')),
                onChanged: (_) => setSheet(() {}),
              ),
              const SizedBox(height: 16),
              Text(s.t('pick_icon'), style: TextStyle(fontWeight: FontWeight.w800, color: c.text)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: icons.map((e) {
                  final isOn = e == emoji;
                  return GestureDetector(
                    onTap: () => setSheet(() => emoji = e),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isOn ? c.primarySoft : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isOn ? c.primary : c.border, width: 2),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ChunkyButton(
                label: s.t('save'),
                onTap: controller.text.trim().isEmpty
                    ? null
                    : () {
                        app.addHabit(controller.text, emoji);
                        Navigator.of(ctx).pop();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('habits_screen'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (app.habits.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(s.t('habits_empty'), style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
              ),
            for (final h in app.habits)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Text(h.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(h.name(s), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text)),
                      ),
                      IconButton(
                        tooltip: s.t('delete'),
                        onPressed: () => app.removeHabit(h.id),
                        icon: Icon(Icons.delete_outline_rounded, color: c.muted),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ChunkyButton(label: s.t('add_habit'), icon: Icons.add_rounded, onTap: () => _add(context)),
          ],
        ),
      ),
    );
  }
}
