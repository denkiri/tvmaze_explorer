import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvmaze_explorer/core/errors/app_exceptions.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';
import 'package:tvmaze_explorer/features/shows/domain/repositories/show_repository.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_providers.dart';

// State for the paginated show list.
class ShowListState {
  const ShowListState({
    this.shows = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
  });

  final List<Show> shows;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  ShowListState copyWith({
    List<Show>? shows,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ShowListState(
      shows: shows ?? this.shows,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

//  Manages paginated loading of TV shows from the TVMaze index.
// Loads 250 shows per page. Automatically tracks the current page
// and whether more pages are available.
class ShowListNotifier extends Notifier<ShowListState> {
  @override
  ShowListState build() {
    // Load the first page immediately.
    Future.microtask(() => fetchNextPage());
    return const ShowListState();
  }
  ShowRepository get _repository => ref.read(showRepositoryProvider);

  // Fetches the next page of shows and appends them to the list.
  // Does nothing if already loading or no more pages are available.
  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newShows = await _repository.getShows(state.currentPage);
      state = state.copyWith(
        shows: [...state.shows, ...newShows],
        currentPage: state.currentPage + 1,
        isLoading: false,
        // TVMaze pagination is ID-based, so pages can have fewer than 250
        // results due to deleted shows. Only stop on 404 or empty response.
        hasMore: newShows.isNotEmpty,
      );
    } on NotFoundException {
      // 404 means we've gone past the last page.
      state = state.copyWith(isLoading: false, hasMore: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  // Resets the list and reloads from page 0.
  Future<void> refresh() async {
    state = const ShowListState();
    await fetchNextPage();
  }
}
