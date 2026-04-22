import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mattress_model.dart';

class AppProvider extends ChangeNotifier {
  MattressState _state = const MattressState();
  List<LogEntry> _log = [];
  ThemeMode _themeMode = ThemeMode.dark;

  MattressState get state => _state;
  List<LogEntry> get log => List.unmodifiable(_log);
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  AppProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load state
    final stateJson = prefs.getString('matrax_state_v3');
    if (stateJson != null) {
      try {
        _state = MattressState.fromJson(jsonDecode(stateJson));
      } catch (_) {}
    }

    // Load log
    final logJson = prefs.getString('matrax_log_v3');
    if (logJson != null) {
      try {
        final list = jsonDecode(logJson) as List;
        _log = list.map((e) => LogEntry.fromJson(e)).toList();
      } catch (_) {}
    }

    // Load theme
    final theme = prefs.getString('matrax_theme_v1');
    _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matrax_state_v3', jsonEncode(_state.toJson()));
  }

  Future<void> _saveLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matrax_log_v3', jsonEncode(_log.map((e) => e.toJson()).toList()));
  }

  Future<void> confirmChange() async {
    final from = _state;
    final next = _state.nextStep();

    final entry = LogEntry(
      timestamp: DateTime.now(),
      shape: from.shape,
      fromSide: from.side,
      fromDir: from.direction,
      toSide: next.side,
      toDir: next.direction,
      flipped: from.side != next.side,
      rotated: from.shape == MattressShape.square && from.direction != next.direction,
      turned: from.shape == MattressShape.rect && from.direction != next.direction,
    );

    _state = next;
    _log.insert(0, entry);

    await _saveState();
    await _saveLog();
    notifyListeners();
  }

  Future<void> setShape(MattressShape shape) async {
    _state = _state.withShape(shape);
    await _saveState();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matrax_theme_v1', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> resetAll() async {
    _state = const MattressState();
    _log = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('matrax_state_v3');
    await prefs.remove('matrax_log_v3');
    notifyListeners();
  }

  String exportJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'state': _state.toJson(),
      'log': _log.map((e) => e.toJson()).toList(),
    });
  }
}