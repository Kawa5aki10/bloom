import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  static const _tags = ['school', 'friends', 'family', 'sleep', 'sport', 'phone', 'food', 'body', 'weather'];

  int? _mood;
  final Set<String> _selected = {};
  final _note = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final old = context.app.moodOn(today());
    if (old != null) {
      _mood = old.mood;
      _selected.addAll(old.tags);
      _note.text = old.note;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = context.s;
    final c = context.colors;
    final selectedMood = _mood;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('mood_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              s.t('mood_q'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.text),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final value = i + 1;
                final isOn = selectedMood == value;
                return GestureDetector(
                  onTap: () => setState(() => _mood = value),
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
            const SizedBox(height: 12),
            Center(
              child: Text(
                selectedMood == null ? ' ' : s.t('mood_$selectedMood'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primary),
              ),
            ),
            SectionTitle(s.t('mood_why')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isOn = _selected.contains(tag);
                return FilterChip(
                  label: Text(s.t('tag_$tag')),
                  selected: isOn,
                  showCheckmark: false,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, color: isOn ? c.primaryDark : c.text),
                  selectedColor: c.primarySoft,
                  backgroundColor: c.surface,
                  side: BorderSide(color: isOn ? c.primary : c.border, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (v) => setState(() => v ? _selected.add(tag) : _selected.remove(tag)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: s.t('note_hint')),
            ),
            const SizedBox(height: 24),
            ChunkyButton(
              label: s.t('save'),
              onTap: selectedMood == null
                  ? null
                  : () {
                      final isNew = app.moodOn(today()) == null;
                      app.saveMood(
                        today(),
                        MoodEntry(mood: selectedMood, tags: _selected.toList(), note: _note.text.trim()),
                      );
                      showToast(context, isNew ? s.f('xp_plus', {'n': Xp.mood}) : s.t('saved'));
                      Navigator.of(context).pop();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
