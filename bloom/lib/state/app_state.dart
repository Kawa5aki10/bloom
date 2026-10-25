import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// "2026-10-25" for a date. Used as a key to save data per day.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

class MoodEntry {
  MoodEntry({required this.mood, this.tags = const [], this.note = ''});

  final int mood; // 1..5
  final List<String> tags;
  final String note;

  Map<String, dynamic> toJson() => {'m': mood, 't': tags, 'n': note};

  static MoodEntry fromJson(Map<String, dynamic> j) => MoodEntry(
        mood: (j['m'] as num).toInt(),
        tags: ((j['t'] as List?) ?? const []).map((e) => e.toString()).toList(),
        note: (j['n'] ?? '').toString(),
      );
}

class SleepEntry {
  SleepEntry({required this.bed, required this.wake, required this.quality});

  final int bed; // minutes after midnight
  final int wake; // minutes after midnight
  final int quality; // 1..5

  int get minutes {
    var d = wake - bed;
    if (d <= 0) d += 24 * 60;
    return d;
  }

  double get hours => minutes / 60.0;

  Map<String, dynamic> toJson() => {'b': bed, 'w': wake, 'q': quality};

  static SleepEntry fromJson(Map<String, dynamic> j) => SleepEntry(
        bed: (j['b'] as num).toInt(),
        wake: (j['w'] as num).toInt(),
        quality: (j['q'] as num).toInt(),
      );
}

class Habit {
  Habit({required this.id, required this.emoji, this.nameKey, this.customName});

  final String id;
  final String emoji;
  final String? nameKey; // built-in habits use a text key
  final String? customName; // habits made by the user

  String name(S s) {
    final custom = customName;
    if (custom != null && custom.isNotEmpty) return custom;
    final key = nameKey;
    return key == null ? '' : s.t(key);
  }

  Map<String, dynamic> toJson() => {'id': id, 'e': emoji, 'k': nameKey, 'c': customName};

  static Habit fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'].toString(),
        emoji: (j['e'] ?? '⭐').toString(),
        nameKey: j['k'] as String?,
        customName: j['c'] as String?,
      );
}

/// Points for each action.
class Xp {
  static const mood = 10;
  static const sleep = 10;
  static const habit = 5;
  static const challenge = 15;
  static const relax = 10;
}

/// Keeps all app data and saves it on the phone.
class AppState extends ChangeNotifier {
  AppState._(this._prefs);

  final SharedPreferences _prefs;
  static const _storageKey = 'bloom_data_v1';

  // Settings
  String lang = 'en';
  ThemeMode themeMode = ThemeMode.system;
  String name = '';
  bool onboarded = false;

  // Data
  int xp = 0;
  final Map<String, MoodEntry> moods = {};
  final Map<String, SleepEntry> sleeps = {};
  final List<Habit> habits = [];
  final Map<String, Set<String>> habitDone = {};
  final Set<String> challengesDone = {};
  final Map<String, int> relaxCount = {};

  S get s => S(lang);

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState._(prefs);
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      state._addDefaultHabits();
    } else {
      try {
        state._fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        state._addDefaultHabits();
      }
    }
    return state;
  }

  void _addDefaultHabits() {
    habits
      ..clear()
      ..addAll([
        Habit(id: 'water', emoji: '💧', nameKey: 'h_water'),
        Habit(id: 'walk', emoji: '🚶', nameKey: 'h_walk'),
        Habit(id: 'nophone', emoji: '📵', nameKey: 'h_nophone'),
        Habit(id: 'fruit', emoji: '🍎', nameKey: 'h_fruit'),
      ]);
  }

  void _fromJson(Map<String, dynamic> j) {
    lang = (j['lang'] ?? 'en').toString();
    themeMode = _themeFromString((j['theme'] ?? 'system').toString());
    name = (j['name'] ?? '').toString();
    onboarded = j['onboarded'] == true;
    xp = ((j['xp'] ?? 0) as num).toInt();

    final m = (j['moods'] as Map?) ?? const {};
    m.forEach((k, v) => moods[k.toString()] = MoodEntry.fromJson(Map<String, dynamic>.from(v as Map)));

    final sl = (j['sleeps'] as Map?) ?? const {};
    sl.forEach((k, v) => sleeps[k.toString()] = SleepEntry.fromJson(Map<String, dynamic>.from(v as Map)));

    final h = (j['habits'] as List?) ?? const [];
    for (final e in h) {
      habits.add(Habit.fromJson(Map<String, dynamic>.from(e as Map)));
    }

    final hd = (j['habitDone'] as Map?) ?? const {};
    hd.forEach((k, v) => habitDone[k.toString()] = (v as List).map((e) => e.toString()).toSet());

    final c = (j['challenges'] as List?) ?? const [];
    challengesDone.addAll(c.map((e) => e.toString()));

    final r = (j['relax'] as Map?) ?? const {};
    r.forEach((k, v) => relaxCount[k.toString()] = (v as num).toInt());
  }

  Map<String, dynamic> _toJson() => {
        'lang': lang,
        'theme': themeMode.name,
        'name': name,
        'onboarded': onboarded,
        'xp': xp,
        'moods': moods.map((k, v) => MapEntry(k, v.toJson())),
        'sleeps': sleeps.map((k, v) => MapEntry(k, v.toJson())),
        'habits': habits.map((e) => e.toJson()).toList(),
        'habitDone': habitDone.map((k, v) => MapEntry(k, v.toList())),
        'challenges': challengesDone.toList(),
        'relax': relaxCount,
      };

  static ThemeMode _themeFromString(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _changed() {
    _prefs.setString(_storageKey, jsonEncode(_toJson()));
    notifyListeners();
  }

  // ---------- Settings ----------

  void setLang(String value) {
    lang = value;
    _changed();
  }

  void setTheme(ThemeMode value) {
    themeMode = value;
    _changed();
  }

  void setName(String value) {
    name = value.trim();
    _changed();
  }

  void finishOnboarding() {
    onboarded = true;
    _changed();
  }

  // ---------- Mood & sleep ----------

  MoodEntry? moodOn(DateTime d) => moods[dayKey(d)];
  SleepEntry? sleepOn(DateTime d) => sleeps[dayKey(d)];

  void saveMood(DateTime d, MoodEntry e) {
    final key = dayKey(d);
    if (!moods.containsKey(key)) xp += Xp.mood;
    moods[key] = e;
    _changed();
  }

  void saveSleep(DateTime d, SleepEntry e) {
    final key = dayKey(d);
    if (!sleeps.containsKey(key)) xp += Xp.sleep;
    sleeps[key] = e;
    _changed();
  }

  // ---------- Habits ----------

  bool isHabitDone(DateTime d, String id) => habitDone[dayKey(d)]?.contains(id) ?? false;

  int habitsDoneOn(DateTime d) => habitDone[dayKey(d)]?.length ?? 0;

  void toggleHabit(DateTime d, String id) {
    final set = habitDone.putIfAbsent(dayKey(d), () => <String>{});
    if (set.contains(id)) {
      set.remove(id);
      xp = xp > Xp.habit ? xp - Xp.habit : 0;
    } else {
      set.add(id);
      xp += Xp.habit;
    }
    _changed();
  }

  void addHabit(String customName, String emoji) {
    final id = 'h${DateTime.now().millisecondsSinceEpoch}';
    habits.add(Habit(id: id, emoji: emoji, customName: customName.trim()));
    _changed();
  }

  void removeHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    for (final set in habitDone.values) {
      set.remove(id);
    }
    _changed();
  }

  // ---------- Daily challenge ----------

  int challengeIndex(DateTime d) {
    final dayOfYear = DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(d.year)).inDays;
    return dayOfYear % S.challengeCount;
  }

  bool isChallengeDone(DateTime d) => challengesDone.contains(dayKey(d));

  void completeChallenge(DateTime d) {
    if (challengesDone.add(dayKey(d))) {
      xp += Xp.challenge;
      _changed();
    }
  }

  // ---------- Relax ----------

  void addRelax(DateTime d) {
    final key = dayKey(d);
    relaxCount[key] = (relaxCount[key] ?? 0) + 1;
    xp += Xp.relax;
    _changed();
  }

  // ---------- Stats ----------

  bool isActive(DateTime d) {
    final key = dayKey(d);
    return moods.containsKey(key) ||
        sleeps.containsKey(key) ||
        (habitDone[key]?.isNotEmpty ?? false) ||
        challengesDone.contains(key) ||
        (relaxCount[key] ?? 0) > 0;
  }

  /// Days in a row with at least one action.
  int get streak {
    var d = today();
    if (!isActive(d)) d = addDays(d, -1);
    var n = 0;
    while (isActive(d)) {
      n++;
      d = addDays(d, -1);
    }
    return n;
  }

  int get activeDaysTotal {
    final keys = <String>{
      ...moods.keys,
      ...sleeps.keys,
      ...challengesDone,
      ...relaxCount.keys,
      ...habitDone.entries.where((e) => e.value.isNotEmpty).map((e) => e.key),
    };
    return keys.length;
  }

  void resetAll() {
    xp = 0;
    name = '';
    moods.clear();
    sleeps.clear();
    habitDone.clear();
    challengesDone.clear();
    relaxCount.clear();
    _addDefaultHabits();
    onboarded = false;
    _changed();
  }
}
