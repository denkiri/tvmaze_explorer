import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvmaze_explorer/core/errors/app_exceptions.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';
import 'package:tvmaze_explorer/features/shows/domain/repositories/show_repository.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_providers.dart';

// State for the show search feature.
class ShowSearchState {
  const ShowSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.hasSearched = false,
  });

  final List<Show> results;
  final bool isLoading;
  final String? error;
  final String query;
  final bool hasSearched;

  ShowSearchState copyWith({
    List<Show>? results,
    bool? isLoading,
    String? error,
    String? query,
    bool? hasSearched,
  }) {
    return ShowSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

// Manages search state for TV shows.
class ShowSearchNotifier extends Notifier<ShowSearchState> {
  @override
  ShowSearchState build() => const ShowSearchState();

  ShowRepository get _repository => ref.read(showRepositoryProvider);

  // Searches for shows matching [query].
  //Clears results and resets state if [query] is empty.
  Future<void> search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      state = const ShowSearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      query: trimmed,
    );

    try {
      final results = await _repository.searchShows(trimmed);
      // Only update if the query hasn't changed while loading.
      if (state.query == trimmed) {
        state = state.copyWith(
          results: results,
          isLoading: false,
          hasSearched: true,
        );
      }
    } on AppException catch (e) {
      if (state.query == trimmed) {
        state = state.copyWith(
          isLoading: false,
          error: e.message,
          hasSearched: true,
        );
      }
    }
  }

  // Clears the current search and resets to initial state.
  void clearSearch() {
    state = const ShowSearchState();
  }
}
