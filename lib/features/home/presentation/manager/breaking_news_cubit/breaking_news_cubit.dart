import 'package:carousel_slider/carousel_slider.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; 

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../../../../../core/errors/failures.dart';

import '../../../data/models/news_model/news_model.dart';
import '../../../data/repos/home_repo.dart';
import '../../view/notification_provider.dart';
import 'dart:async'; // Needed for Timer

part 'breaking_news_state.dart';

class BreakingNewsCubit extends Cubit<BreakingNewsState> {
  BreakingNewsCubit({
    required this.homeRepo,
    required this.notificationProvider,
    required this.notificationsPlugin,
  }) : super(BreakingNewsInitial());

  final HomeRepo homeRepo;
  final NotificationProvider notificationProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  int current = 0;
  final CarouselSliderController carouselController = CarouselSliderController();
  final List<String> _sentHeadlines = []; // Track sent headlines
  final List<NewsModel> _newsList = [];   // Store latest fetched news
  Timer? _notificationTimer;
  int _notificationIndex = 0;

  Future<void> fetchBreakingNews() async {
    emit(BreakingNewsLoadingState());
    Either<Failure, List<NewsModel>> result = await homeRepo.fetchBreakingNews();

    result.fold(
      (failure) => emit(BreakingNewsFailureState(failure.errMessage)),
      (newsList) async {
        // ✅ Remove duplicate titles
        final Map<String, NewsModel> uniqueNewsMap = {};
        for (var news in newsList) {
          if (news.title != null && !uniqueNewsMap.containsKey(news.title)) {
            uniqueNewsMap[news.title!] = news;
          }
        }
        final uniqueNewsList = uniqueNewsMap.values.toList();
        emit(BreakingNewsSuccessState(uniqueNewsList));

        if (notificationProvider.isEnabled && uniqueNewsList.isNotEmpty) {
          _newsList.clear();
          _newsList.addAll(uniqueNewsList);
          _notificationIndex = 0;
          _sentHeadlines.clear();

          startPeriodicNotification(); // Start the one-by-one notification cycle
        }
      },
    );
  }

  /// 👇 Start sending one-by-one breaking news at user-defined interval
  void startPeriodicNotification() {
    stopPeriodicNotification();

    if (_newsList.isEmpty) return;

    final interval = Duration(minutes: notificationProvider.intervalMinutes);

    _notificationTimer = Timer.periodic(interval, (timer) async {
      final logger = Logger();
      logger.i("⏰ Timer triggered at ${DateTime.now()}");

      // Check if the current news item index is within bounds and if the news has not been sent before
      if (_notificationIndex < _newsList.length) {
        final news = _newsList[_notificationIndex];

        // Only send notification if the title is not already in the sent headlines list
        if (news.title != null && !_sentHeadlines.contains(news.title)) {
          _sentHeadlines.add(news.title!);
          await _sendLocalNotification(news.title!, news.description ?? "");
        }

        _notificationIndex++;
      } else {
        stopPeriodicNotification(); // Stop once all news items are sent
      }
    });
  }

  void stopPeriodicNotification() {
    _notificationTimer?.cancel(); // Cancel the existing timer to avoid overlap
    _notificationTimer = null;    // Nullify the timer after cancellation
  }

  Future<void> _sendLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Breaking News',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'newsicon',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID based on current timestamp
      title,
      body,
      notificationDetails,
    );
  }

  @override
  Future<void> close() {
    stopPeriodicNotification();  // Ensure the timer is canceled when the Cubit is closed
    return super.close();
  }
}
