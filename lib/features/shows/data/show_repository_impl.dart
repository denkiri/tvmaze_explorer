import 'package:dio/dio.dart';
import 'package:tvmaze_explorer/core/errors/app_exceptions.dart';
import 'package:tvmaze_explorer/features/shows/data/show_api_service.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';
import 'package:tvmaze_explorer/features/shows/domain/repositories/show_repository.dart';

/// Concrete implementation of [ShowRepository].
///
/// Wraps [ShowApiService] calls with error handling, translating
/// Dio exceptions into domain-specific [AppException] types.
class ShowRepositoryImpl implements ShowRepository {
  ShowRepositoryImpl(this._apiService);

  final ShowApiService _apiService;

  @override
  Future<List<Show>> getShows(int page) async {
    return _handleErrors(() => _apiService.getShows(page));
  }

  @override
  Future<List<Show>> searchShows(String query) async {
    return _handleErrors(() => _apiService.searchShows(query));
  }

  @override
  Future<Show> getShowDetail(int id) async {
    return _handleErrors(() => _apiService.getShowDetail(id));
  }

  /// Executes [apiCall] and translates Dio/network errors into [AppException].
  Future<T> _handleErrors<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          throw const NetworkException();
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode == 404) {
            throw const NotFoundException();
          } else if (statusCode >= 500) {
            throw const ServerException();
          }
          throw const UnknownException();
        default:
          throw const UnknownException();
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw const UnknownException();
    }
  }
}
