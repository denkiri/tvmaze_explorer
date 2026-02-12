import 'package:dio/dio.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';

// Service class responsible for making HTTP requests to the TVMaze API.
class ShowApiService {
  ShowApiService(this._dio);

  final Dio _dio;

  // Fetches a paginated list of shows.
  Future<List<Show>> getShows(int page) async {
    final response = await _dio.get<List<dynamic>>(
      '/shows',
      queryParameters: {'page': page},
    );

    return (response.data ?? [])
        .map((json) => Show.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Searches for shows matching [query] using TVMaze's fuzzy search.
  ///
  /// Response format: `[{score: 0.9, show: {...}}, ...]`
  /// The [Show.fromJson] factory handles unwrapping the search wrapper.
  Future<List<Show>> searchShows(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/search/shows',
      queryParameters: {'q': query},
    );

    return (response.data ?? [])
        .map((json) => Show.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches detailed show information with embedded cast data.
  ///
  /// Uses `?embed=cast` to include cast members in a single request.
  Future<Show> getShowDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/shows/$id',
      queryParameters: {'embed': 'cast'},
    );

    return Show.fromJson(response.data!);
  }
}
