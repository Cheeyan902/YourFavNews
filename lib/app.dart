import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/utils/router.dart';
import '../features/home/presentation/view/theme_provider.dart'; 
import '../features/home/presentation/view/notification_provider.dart'; 
import '../features/home/presentation/manager/breaking_news_cubit/breaking_news_cubit.dart';
import '../features/home/data/repos/home_repo_impl.dart';
import '../../../../core/utils/api_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final FlutterLocalNotificationsPlugin notificationsPlugin;

  @override
  void initState() {
    super.initState();
    notificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
  const androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await notificationsPlugin.initialize(initializationSettings);

   // Ask notification permission on Android 13+
  bool permissionGranted = true;
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    permissionGranted = await Permission.notification.request().isGranted;
  }

  debugPrint("🔔 Notification permission granted: $permissionGranted");

  // You can still show a welcome notification regardless of permission
  if (permissionGranted) {
    const androidDetails = AndroidNotificationDetails(
      'breaking_news_channel',
      'Breaking News Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'newsicon',
      styleInformation: BigTextStyleInformation(
       'Notifications have been initialized.',
        contentTitle: '<b>Welcome to YFN!</b>', // 🔥 Bold title using HTML
        htmlFormatContentTitle: true,
        htmlFormatBigText: true,
      ),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notificationsPlugin.show(
        0,
        'Welcome to YFN!',
        'Notifications have been initialized.',
        notificationDetails,
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => BreakingNewsCubit(
                  homeRepo: HomeRepoImpl(ApiService(Dio())),
                  notificationProvider: context.read<NotificationProvider>(),
                  notificationsPlugin: notificationsPlugin,
                ),
              ),
            ],
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return MaterialApp.router(
                  title: 'YourFavNews',
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.isDarkMode
                      ? ThemeData.dark().copyWith(
                          scaffoldBackgroundColor: Colors.black,
                        )
                      : ThemeData.light().copyWith(
                          scaffoldBackgroundColor: Colors.white,
                        ),
                  routerConfig: AppRouter.router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
