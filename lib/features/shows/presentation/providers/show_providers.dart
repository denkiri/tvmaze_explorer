import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvmaze_explorer/core/network/dio_client.dart';
import 'package:tvmaze_explorer/features/shows/data/show_api_service.dart';
import 'package:tvmaze_explorer/features/shows/data/show_repository_impl.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';
import 'package:tvmaze_explorer/features/shows/domain/repositories/show_repository.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_list_notifier.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_search_notifier.dart';

//Core dependency providers
// Provides a configured [Dio] instance.
final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});

// Provides the [ShowApiService] used to call TVMaze endpoints.
final showApiServiceProvider = Provider<ShowApiService>((ref) {
  return ShowApiService(ref.watch(dioProvider));
});

// Provides the [ShowRepository] implementation.
final showRepositoryProvider = Provider<ShowRepository>((ref) {
  return ShowRepositoryImpl(ref.watch(showApiServiceProvider));
});

// Feature providers

//Provides the paginated show list state.
final showListProvider =
    NotifierProvider<ShowListNotifier, ShowListState>(
  ShowListNotifier.new,
);

//Provides the search results state.
final showSearchProvider =
    NotifierProvider<ShowSearchNotifier, ShowSearchState>(
  ShowSearchNotifier.new,
);

//Provides detailed show info (with cast) by show ID.
final showDetailProvider =
    FutureProvider.family<Show, int>((ref, id) async {
  final repository = ref.watch(showRepositoryProvider);
  return repository.getShowDetail(id);
});
