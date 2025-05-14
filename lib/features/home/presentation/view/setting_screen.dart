import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'notification_provider.dart'; 
import '../manager/breaking_news_cubit/breaking_news_cubit.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final breakingNewsCubit = context.read<BreakingNewsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: notificationProvider.isEnabled,
            onChanged: (bool value) async {
              notificationProvider.toggle(value);
              
              if (value) {
                // Fetch breaking news when notifications are enabled
                await breakingNewsCubit.fetchBreakingNews();
                /*breakingNewsCubit.startPeriodicNotification();*/

                 // Send a test notification to verify
                _sendTestNotification();
              } else {
                breakingNewsCubit.stopPeriodicNotification();
              }   
            },
          ),
          DropdownButtonFormField<int>(
            value: notificationProvider.intervalMinutes,
            decoration: const InputDecoration(
              labelText: "Notification Interval",
            ),
           items: const [
            DropdownMenuItem(value: 1, child: Text('Every 1 minute')),
            DropdownMenuItem(value: 5, child: Text('Every 5 minutes')),
            DropdownMenuItem(value: 10, child: Text('Every 10 minutes')),
            DropdownMenuItem(value: 30, child: Text('Every 30 minutes')),
          ],
        onChanged: notificationProvider.isEnabled
          ? (int? value) {
              if (value != null) {
                notificationProvider.setInterval(value);
                breakingNewsCubit.startPeriodicNotification();
              }
            }
            : null,
          ),
          SwitchListTile(
            title: const Text("Enable Dark Mode"),
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (_) {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          /*ElevatedButton(
            onPressed: () {
              breakingNewsCubit.fetchBreakingNews();  // Trigger fetching of breaking news
            },
            child: const Text('Fetch Breaking News'),
          ),*/
        ],
      ),
    );
  }

  void _sendTestNotification() async {

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Breaking News',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'newsicon',
    );
    const details = NotificationDetails(android: androidDetails);
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(0, 'Notifications enabled', 'Enjoy your study!', details);
  }
}

