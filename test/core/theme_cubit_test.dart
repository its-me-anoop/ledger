import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is ThemeMode.system when no pref stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs);
      expect(cubit.state, ThemeMode.system);
    });

    test('setMode(dark) emits ThemeMode.dark', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs);
      cubit.setMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
    });

    test('setMode(light) then setMode(system) results in system', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs);
      cubit.setMode(ThemeMode.light);
      cubit.setMode(ThemeMode.system);
      expect(cubit.state, ThemeMode.system);
    });

    test('loads persisted theme on construction', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs);
      expect(cubit.state, ThemeMode.dark);
    });
  });
}
