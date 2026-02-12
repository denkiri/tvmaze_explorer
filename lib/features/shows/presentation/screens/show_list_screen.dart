import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvmaze_explorer/core/utils/debouncer.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_providers.dart';
import 'package:tvmaze_explorer/features/shows/presentation/providers/show_search_notifier.dart';
import 'package:tvmaze_explorer/features/shows/presentation/widgets/error_state_widget.dart';
import 'package:tvmaze_explorer/features/shows/presentation/widgets/show_card.dart';

// Main screen displaying a paginated grid of TV shows with search.
class ShowListScreen extends ConsumerStatefulWidget {
  const ShowListScreen({super.key});

  @override
  ConsumerState<ShowListScreen> createState() => _ShowListScreenState();
}

class _ShowListScreenState extends ConsumerState<ShowListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  // Triggers loading the next page when scrolled near the bottom.
  void _onScroll() {
    if (_isSearching) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      ref.read(showListProvider.notifier).fetchNextPage();
    }
  }

  // Handles search input with 500ms debouncing.
  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (query.trim().isEmpty) {
        ref.read(showSearchProvider.notifier).clearSearch();
      } else {
        ref.read(showSearchProvider.notifier).search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showListState = ref.watch(showListProvider);
    final searchState = ref.watch(showSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : const Text(
                'TVMaze Explorer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(showSearchProvider.notifier).clearSearch();
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching && searchState.query.isNotEmpty
          ? _buildSearchResults(searchState)
          : _buildShowList(showListState),
    );
  }

  // Builds the search text field in the AppBar.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search TV shows...',
        border: InputBorder.none,
        filled: false,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      onChanged: _onSearchChanged,
    );
  }

  // Builds the search results view.
  Widget _buildSearchResults(ShowSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(showSearchProvider.notifier).search(state.query),
      );
    }

    if (state.hasSearched && state.results.isEmpty) {
      return const EmptyStateWidget();
    }

    return _buildGrid(
      shows: state.results,
      isLoading: false,
      hasMore: false,
    );
  }

  // Builds the paginated show list view.
  Widget _buildShowList(dynamic showListState) {
    if (showListState.shows.isEmpty && showListState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (showListState.shows.isEmpty && showListState.error != null) {
      return ErrorStateWidget(
        message: showListState.error!,
        onRetry: () => ref.read(showListProvider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(showListProvider.notifier).refresh(),
      child: _buildGrid(
        shows: showListState.shows,
        isLoading: showListState.isLoading,
        hasMore: showListState.hasMore,
        error: showListState.error,
      ),
    );
  }

  // Builds a responsive grid of show cards.
  Widget _buildGrid({
    required List shows,
    required bool isLoading,
    required bool hasMore,
    String? error,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return CustomScrollView(
          controller: _isSearching ? null : _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ShowCard(show: shows[index]),
                  childCount: shows.length,
                ),
              ),
            ),

            // Loading indicator at bottom during pagination.
            if (isLoading && hasMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Inline error with retry during pagination.
            if (error != null && shows.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(showListProvider.notifier).fetchNextPage(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
