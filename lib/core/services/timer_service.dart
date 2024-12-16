import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  int get remainingSeconds => _remainingSeconds;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TimerService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize notification channels
    const AndroidNotificationChannel timerChannel = AndroidNotificationChannel(
      'timer_channel',
      'Timer',
      description: 'Timer notifications',
      importance: Importance.low,
      enableVibration: false,
    );

    const AndroidNotificationChannel completionChannel =
        AndroidNotificationChannel(
      'timer_completion_channel',
      'Timer Completion',
      description: 'Timer completion notifications',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(timerChannel);
    await androidPlugin?.createNotificationChannel(completionChannel);

    // Initialize settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    // Initialize with action handling
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload == 'timer_screen') {
          // You'll need to implement navigation using a navigation service or context
          // Navigator.pushNamed(context, '/timer');
        }
      },
    );
  }

  Future<void> _updateNotification() async {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    // Create notification actions
    final List<AndroidNotificationAction> actions = [
      const AndroidNotificationAction('pause', 'Pause'),
      const AndroidNotificationAction('stop', 'Stop'),
    ];

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Timer notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      actions: _isRunning ? actions : null,
      category: AndroidNotificationCategory.progress,
      showProgress: true,
      maxProgress: 100,
      progress: (_remainingSeconds / (minutes * 60 + seconds) * 100).round(),
    );

    await _notificationsPlugin.show(
      0,
      'Timer Running',
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining',
      NotificationDetails(android: androidDetails),
      payload: 'timer_screen',
    );
  }

  Future<void> _showCompletionNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'timer_completion_channel',
      'Timer Completion',
      channelDescription: 'Timer completion notifications',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    );

    await _notificationsPlugin.show(
      1,
      'Timer Complete!',
      'Your timer has finished',
      const NotificationDetails(android: androidDetails),
      payload: 'timer_screen',
    );
  }

  Future<void> _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
    }
  }

  void startTimer(int minutes, int seconds) {
    if (_isRunning) return;
    _remainingSeconds = (minutes * 60) + seconds;
    if (_remainingSeconds <= 0) return;
    _isRunning = true;
    _isPaused = false;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateNotification();
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _playAlarm();
        _showCompletionNotification();
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_remainingSeconds > 0) {
      _isRunning = true;
      _isPaused = false;
      notifyListeners();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _updateNotification();
          notifyListeners();
        } else {
          _timer?.cancel();
          _isRunning = false;
          _playAlarm();
          _showCompletionNotification();
          notifyListeners();
        }
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = 0;
    _notificationsPlugin.cancel(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _notificationsPlugin.cancel(0);
    super.dispose();
  }
}
