import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/utils/service_locator.dart';
import '../../data/repos/home_repo_impl.dart';
import '../manager/breaking_news_cubit/breaking_news_cubit.dart';
import '../manager/recommended_news_cubit/recommended_news_cubit.dart';
import 'widgets/home_widgets.dart';
import 'notification_provider.dart'; 

class HomeScreen extends StatelessWidget {

  final NotificationProvider notificationProvider;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const HomeScreen({
    super.key,
    required this.notificationProvider,
    required this.notificationsPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) =>
             BreakingNewsCubit(
            homeRepo: getIt.get<HomeRepoImpl>(),
            notificationProvider: notificationProvider,
            notificationsPlugin: notificationsPlugin,
          )..fetchBreakingNews(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              RecommendedNewsCubit(getIt.get<HomeRepoImpl>())
                ..fetchRecommendedNews(),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Playful', // 👈 make sure this matches your pubspec.yaml
                  fontSize: 30,
                  color: Color.fromARGB(255, 157, 154, 154),
                ),
                children: [
                  TextSpan(text: 'Your'),
                  TextSpan(
                    text: 'FavNews',
                    style: TextStyle(color: Color.fromARGB(255, 186, 38, 232)),
                  ),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: BlocBuilder<BreakingNewsCubit, BreakingNewsState>(
            builder: (context, breakingNewsState) {
              return BlocBuilder<RecommendedNewsCubit, RecommendedNewsState>(
                builder: (context, recommendedNewsState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BreakingNewsCubit>().fetchBreakingNews();
                      context.read<RecommendedNewsCubit>().fetchRecommendedNews();
                    },
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          floating: true,
                          delegate: PersistentHeader(),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: const [
                              TitleBar(
                                title: 'Breaking News',
                              ),
                              BreakingSlider(),
                              TitleBar(
                                title: 'Recommendation',
                              ),
                            ],
                          ),
                        ),
                        const SliverFillRemaining(
                          child: RecNewsListView(),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  PersistentHeader();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const HomeAppBar();
  }

  @override
  double get maxExtent => 72.0;

  @override
  double get minExtent => 72.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
