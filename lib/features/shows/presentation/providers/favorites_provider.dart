import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key used for storing favorite show IDs in SharedPreferences.
const _favoritesKey = 'favorite_show_ids';

// Provides the [SharedPreferences] instance.
// Must be overridden in main.dart with the actual instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// State for favorites — a simple set of show IDs.
class FavoritesState {
  const FavoritesState({this.favoriteIds = const {}});

  final Set<int> favoriteIds;

  bool isFavorite(int showId) => favoriteIds.contains(showId);

  FavoritesState copyWith({Set<int>? favoriteIds}) {
    return FavoritesState(favoriteIds: favoriteIds ?? this.favoriteIds);
  }
}

// Manages favorite show IDs with SharedPreferences persistence.
class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    // Load saved favorites synchronously as the initial state.
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_favoritesKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
      final ids = decoded.map((e) => e as int).toSet();
      return FavoritesState(favoriteIds: ids);
    }
    return const FavoritesState();
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  // Toggles a show's favorite status and persists the change.
  Future<void> toggleFavorite(int showId) async {
    final updatedIds = Set<int>.from(state.favoriteIds);
    if (updatedIds.contains(showId)) {
      updatedIds.remove(showId);
    } else {
      updatedIds.add(showId);
    }
    state = state.copyWith(favoriteIds: updatedIds);
    await _saveFavorites();
  }

  // Persists the current favorites to SharedPreferences.
  Future<void> _saveFavorites() async {
    final encoded = jsonEncode(state.favoriteIds.toList());
    await _prefs.setString(_favoritesKey, encoded);
  }
}

// Provides the favorites state and notifier.
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);
