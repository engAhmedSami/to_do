import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/pomodoro_settings.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Hive box names
  static const String _eventsBoxName = 'events_box';
  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _trackerBoxName = 'tracker_box';

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Hive boxes
  late Box _eventsBox;
  late Box _userBox;
  late Box _settingsBox;
  late Box _trackerBox;

  // Initialize storage
  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open Hive boxes
    _eventsBox = await Hive.openBox(_eventsBoxName);
    _userBox = await Hive.openBox(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _trackerBox = await Hive.openBox(_trackerBoxName);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // USER RELATED METHODS

  // Save user ID
  Future<void> saveUserId(String userId) async {
    await _userBox.put('user_id', userId);
    await _prefs.setString('user_id', userId);
  }

  // Get user ID
  String? getUserId() {
    return _userBox.get('user_id') as String? ?? _prefs.getString('user_id');
  }

  // Save user email
  Future<void> saveUserEmail(String email) async {
    await _userBox.put('user_email', email);
    await _prefs.setString('user_email', email);
  }

  // Get user email
  String? getUserEmail() {
    return _userBox.get('user_email') as String? ??
        _prefs.getString('user_email');
  }

  // Save user name
  Future<void> saveUserName(String name) async {
    await _userBox.put('user_name', name);
    await _prefs.setString('user_name', name);
  }

  // Get user name
  String? getUserName() {
    return _userBox.get('user_name') as String? ??
        _prefs.getString('user_name');
  }

  // Clear user data
  Future<void> clearUserData() async {
    await _userBox.clear();
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
    await _prefs.remove('user_name');
  }

  // POMODORO SETTINGS METHODS

  // Save Pomodoro settings
  Future<void> savePomodoroSettings(PomodoroSettings settings) async {
    final settingsMap = {
      'focus_duration': settings.focusDuration,
      'short_break_duration': settings.shortBreakDuration,
      'long_break_duration': settings.longBreakDuration,
      'long_break_after': settings.longBreakAfter,
      'target_sessions': settings.targetSessions,
      'auto_start_breaks': settings.autoStartBreaks,
      'auto_start_pomodoros': settings.autoStartPomodoros,
      'user_id': settings.userId,
    };

    await _settingsBox.put('pomodoro_settings', settingsMap);

    // Also save to SharedPreferences for redundancy
    await _prefs.setInt('focus_duration', settings.focusDuration);
    await _prefs.setInt('short_break_duration', settings.shortBreakDuration);
    await _prefs.setInt('long_break_duration', settings.longBreakDuration);
    await _prefs.setInt('long_break_after', settings.longBreakAfter);
    await _prefs.setInt('target_sessions', settings.targetSessions);
    await _prefs.setBool('auto_start_breaks', settings.autoStartBreaks);
    await _prefs.setBool('auto_start_pomodoros', settings.autoStartPomodoros);
  }

  // Load Pomodoro settings
  PomodoroSettings loadPomodoroSettings(String userId) {
    final settingsMap = _settingsBox.get('pomodoro_settings') as Map?;

    if (settingsMap != null) {
      return PomodoroSettings(
        focusDuration: settingsMap['focus_duration'] as int? ?? 25,
        shortBreakDuration: settingsMap['short_break_duration'] as int? ?? 5,
        longBreakDuration: settingsMap['long_break_duration'] as int? ?? 15,
        longBreakAfter: settingsMap['long_break_after'] as int? ?? 4,
        targetSessions: settingsMap['target_sessions'] as int? ?? 8,
        autoStartBreaks: settingsMap['auto_start_breaks'] as bool? ?? true,
        autoStartPomodoros:
            settingsMap['auto_start_pomodoros'] as bool? ?? false,
        userId: userId,
      );
    }

    // Fallback to SharedPreferences
    return PomodoroSettings(
      focusDuration: _prefs.getInt('focus_duration') ?? 25,
      shortBreakDuration: _prefs.getInt('short_break_duration') ?? 5,
      longBreakDuration: _prefs.getInt('long_break_duration') ?? 15,
      longBreakAfter: _prefs.getInt('long_break_after') ?? 4,
      targetSessions: _prefs.getInt('target_sessions') ?? 8,
      autoStartBreaks: _prefs.getBool('auto_start_breaks') ?? true,
      autoStartPomodoros: _prefs.getBool('auto_start_pomodoros') ?? false,
      userId: userId,
    );
  }

  // EVENT CACHING METHODS

  // Cache events for offline access
  Future<void> cacheEvents(List<Map<String, dynamic>> events) async {
    await _eventsBox.put('cached_events', events);
  }

  // Get cached events
  List<Map<String, dynamic>> getCachedEvents() {
    final events = _eventsBox.get('cached_events');
    if (events == null) return [];

    return List<Map<String, dynamic>>.from(events);
  }

  // Cache a single event
  Future<void> cacheEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    await _eventsBox.put(eventId, eventData);
  }

  // Get a cached event
  Map<String, dynamic>? getCachedEvent(String eventId) {
    final event = _eventsBox.get(eventId);
    if (event == null) return null;

    return Map<String, dynamic>.from(event);
  }

  // Remove a cached event
  Future<void> removeCachedEvent(String eventId) async {
    await _eventsBox.delete(eventId);
  }

  // Clear all cached events
  Future<void> clearCachedEvents() async {
    await _eventsBox.clear();
  }

  // DAILY TRACKER CACHING METHODS

  // Cache tracker for offline access
  Future<void> cacheTracker(
    String date,
    Map<String, dynamic> trackerData,
  ) async {
    await _trackerBox.put(date, trackerData);
  }

  // Get cached tracker
  Map<String, dynamic>? getCachedTracker(String date) {
    final tracker = _trackerBox.get(date);
    if (tracker == null) return null;

    return Map<String, dynamic>.from(tracker);
  }

  // Cache weekly trackers
  Future<void> cacheWeeklyTrackers(List<Map<String, dynamic>> trackers) async {
    await _trackerBox.put('weekly_trackers', trackers);
  }

  // Get cached weekly trackers
  List<Map<String, dynamic>> getCachedWeeklyTrackers() {
    final trackers = _trackerBox.get('weekly_trackers');
    if (trackers == null) return [];

    return List<Map<String, dynamic>>.from(trackers);
  }

  // Cache monthly trackers
  Future<void> cacheMonthlyTrackers(List<Map<String, dynamic>> trackers) async {
    await _trackerBox.put('monthly_trackers', trackers);
  }

  // Get cached monthly trackers
  List<Map<String, dynamic>> getCachedMonthlyTrackers() {
    final trackers = _trackerBox.get('monthly_trackers');
    if (trackers == null) return [];

    return List<Map<String, dynamic>>.from(trackers);
  }

  // Clear all cached trackers
  Future<void> clearCachedTrackers() async {
    await _trackerBox.clear();
  }

  // APP SETTINGS METHODS

  // Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox.put('theme_mode', themeMode);
    await _prefs.setString('theme_mode', themeMode);
  }

  // Get theme mode
  String getThemeMode() {
    return _settingsBox.get('theme_mode') as String? ??
        _prefs.getString('theme_mode') ??
        'system';
  }

  // Save notification settings
  Future<void> saveNotificationSettings({
    required bool enableEventReminders,
    required bool enablePomodoroReminders,
    required bool enableDailyReminders,
  }) async {
    final settings = {
      'enable_event_reminders': enableEventReminders,
      'enable_pomodoro_reminders': enablePomodoroReminders,
      'enable_daily_reminders': enableDailyReminders,
    };

    await _settingsBox.put('notification_settings', settings);

    // Also save to SharedPreferences
    await _prefs.setBool('enable_event_reminders', enableEventReminders);
    await _prefs.setBool('enable_pomodoro_reminders', enablePomodoroReminders);
    await _prefs.setBool('enable_daily_reminders', enableDailyReminders);
  }

  // Get notification settings
  Map<String, bool> getNotificationSettings() {
    final settings = _settingsBox.get('notification_settings') as Map?;

    if (settings != null) {
      return {
        'enable_event_reminders':
            settings['enable_event_reminders'] as bool? ?? true,
        'enable_pomodoro_reminders':
            settings['enable_pomodoro_reminders'] as bool? ?? true,
        'enable_daily_reminders':
            settings['enable_daily_reminders'] as bool? ?? true,
      };
    }

    // Fallback to SharedPreferences
    return {
      'enable_event_reminders':
          _prefs.getBool('enable_event_reminders') ?? true,
      'enable_pomodoro_reminders':
          _prefs.getBool('enable_pomodoro_reminders') ?? true,
      'enable_daily_reminders':
          _prefs.getBool('enable_daily_reminders') ?? true,
    };
  }

  // Save FCM token
  Future<void> saveFcmToken(String token) async {
    await _settingsBox.put('fcm_token', token);
    await _prefs.setString('fcm_token', token);
  }

  // Get FCM token
  String? getFcmToken() {
    return _settingsBox.get('fcm_token') as String? ??
        _prefs.getString('fcm_token');
  }

  // Clear all app settings
  Future<void> clearAppSettings() async {
    await _settingsBox.clear();
  }

  // GENERAL METHODS

  // Save data with key
  Future<void> saveData(String key, dynamic data) async {
    if (data is String || data is int || data is double || data is bool) {
      await _prefs.setString(key, data.toString());
    } else {
      final jsonString = jsonEncode(data);
      await _prefs.setString(key, jsonString);
    }
  }

  // Get data by key
  dynamic getData(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      // If it's not JSON, return the raw string
      return data;
    }
  }

  // Remove data by key
  Future<void> removeData(String key) async {
    await _prefs.remove(key);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _eventsBox.clear();
    await _userBox.clear();
    await _settingsBox.clear();
    await _trackerBox.clear();
    await _prefs.clear();
  }

  // Check if there's cached data available for offline use
  bool hasCachedData() {
    return _eventsBox.isNotEmpty || _trackerBox.isNotEmpty;
  }

  // Check if the user is logged in
  bool isUserLoggedIn() {
    final userId = getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
