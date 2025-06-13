import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipewipe/providers/image_list_provider.dart';
import 'package:swipewipe/views/albums/albums_view.dart';
import 'package:swipewipe/views/organize/organize_view.dart';
import 'package:swipewipe/views/settings/settings_view.dart';
import 'package:swipewipe/views/statistics/statistisc_view.dart';
import 'package:swipewipe/views/swipe/swipe_image_view.dart';

export 'package:go_router/go_router.dart' show GoRouter;
export 'package:flutter/material.dart' show GlobalKey, NavigatorState;

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Page<dynamic> fadeScalePage(
    {required Widget child, required GoRouterState state}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/organize',
  routes: [
    // GoRoute(
    //   path: '/splash',
    //   pageBuilder: (context, state) => NoTransitionPage(child: SplashView()),
    // ),
    GoRoute(
      path: '/organize',
      pageBuilder: (context, state) =>
          fadeScalePage(child: OrganizeView(), state: state),
    ),
    GoRoute(
      path: '/statistics',
      pageBuilder: (context, state) =>
          fadeScalePage(child: StatistiscView(), state: state),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          fadeScalePage(child: SettingsView(), state: state),
    ),
    GoRoute(
      path: '/albums',
      pageBuilder: (context, state) =>
          fadeScalePage(child: AlbumsView(), state: state),
    ),
    GoRoute(
      path: '/swipe',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final mediaList = extra['mediaList'] as List<AssetEntity>;
        final initialIndex = extra['initialIndex'] as int;

        return fadeScalePage(
          child: ProviderScope(
            overrides: [
              initialAssetList.overrideWithValue(mediaList),
            ],
            child: SwipeImagePage(
              mediaList: mediaList,
              initialIndex: initialIndex,
            ),
          ),
          state: state,
        );
      },
    ),
  ],
);

final GoRouter appRouter = router;
final GlobalKey<NavigatorState> rootNavigatorKey = _rootNavigatorKey;
