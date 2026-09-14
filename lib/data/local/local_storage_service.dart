import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

class LocalStorageService {
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toJson());
    await prefs.setString(AppConstants.prefUserProfile, jsonStr);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(AppConstants.prefUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWorkoutHistory(List<WorkoutSession> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((s) => s.toJson()).toList();
    await prefs.setString(AppConstants.prefWorkoutHistory, jsonEncode(jsonList));
  }

  static Future<List<WorkoutSession>> getWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(AppConstants.prefWorkoutHistory);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveDemoMode(bool isDemo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDemoMode, isDemo);
  }

  static Future<bool> getDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefDemoMode) ?? false;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
