import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';

/// Abstract repository defining the contract for show data access.
///
/// This interface decouples the business/presentation layers from
/// the concrete data source implementation (API, cache, etc.).
abstract class ShowRepository {
  /// Fetches a paginated list of shows.
  /// [page] is zero-indexed; each page contains up to 250 shows.
  Future<List<Show>> getShows(int page);

  /// Searches for shows matching [query].
  /// Returns an empty list if no matches are found.
  Future<List<Show>> searchShows(String query);

  /// Fetches detailed information for a show by [id], including cast.
  Future<Show> getShowDetail(int id);
}
