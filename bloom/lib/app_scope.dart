import 'package:flutter/material.dart';

import 'l10n/strings.dart';
import 'state/app_state.dart';
import 'theme.dart';

/// Gives every screen access to the app data.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension AppContext on BuildContext {
  AppState get app => AppScope.of(this);
  S get s => S(AppScope.of(this).lang);
  AppColors get colors => AppColors.of(this);
}
