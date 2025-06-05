import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/layout.dart';

class LayoutService {
  /// In-memory list of all layouts (kept in sync with shared_preferences).
  static List<LayoutConfig> layouts = [];

  /// Key under which we store our JSON in SharedPreferences.
  static const String _prefsKey = 'saved_layouts';

  /// Must be called once at app startup to load any previously saved layouts.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(jsonString);
        layouts = decoded
            .map((e) => LayoutConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // If parsing fails for any reason, just start with an empty list:
        layouts = [];
      }
    } else {
      // No saved JSON → start empty
      layouts = [];
    }
  }

  /// Write the current `layouts` list back to SharedPreferences as JSON.
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        layouts.map((l) => l.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_prefsKey, jsonString);
  }

  /// Add a new layout and persist immediately.
  static Future<void> addLayout(LayoutConfig layout) async {
    layouts.add(layout);
    await _saveToPrefs();
  }

  /// Overwrite the layout at [index] (used for edits), then persist.
  static Future<void> updateLayout(int index, LayoutConfig updated) async {
    layouts[index] = updated;
    await _saveToPrefs();
  }

  /// Remove the layout at [index] and persist.
  static Future<void> removeLayout(int index) async {
    layouts.removeAt(index);
    await _saveToPrefs();
  }
}
