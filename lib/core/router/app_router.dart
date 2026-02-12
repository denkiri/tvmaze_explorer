import 'package:go_router/go_router.dart';
import 'package:tvmaze_explorer/features/shows/presentation/screens/show_detail_screen.dart';
import 'package:tvmaze_explorer/features/shows/presentation/screens/show_list_screen.dart';

// Application route configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ShowListScreen(),
    ),
    GoRoute(
      path: '/show/:id',
      name: 'showDetail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final showName = state.extra as String? ?? 'Show Details';
        return ShowDetailScreen(showId: id, showName: showName);
      },
    ),
  ],
);
