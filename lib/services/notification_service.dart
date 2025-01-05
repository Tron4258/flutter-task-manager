import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );
  }

  Future<void> scheduleTaskReminder(Task task) async {
    // Schedule reminder 1 hour before due date
    final scheduledDate = task.dueDate.subtract(Duration(hours: 1));
    
    if (scheduledDate.isBefore(DateTime.now())) {
      print('Cannot schedule notification for past date');
      return;
    }

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Task Due Soon',
      '${task.title} is due in 1 hour',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task due dates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );

    print('Scheduled notification for task: ${task.title}');
  }

  Future<void> cancelTaskReminder(Task task) async {
    await _notifications.cancel(task.id.hashCode);
    print('Cancelled notification for task: ${task.title}');
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    print('Cancelled all notifications');
  }
} 