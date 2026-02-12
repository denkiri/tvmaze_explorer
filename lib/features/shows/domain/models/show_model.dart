/// Represents a TV show from the TVMaze API.
///
/// Handles nullable fields gracefully since the API may omit data.
/// The [cast] field is populated when fetching with `?embed=cast`.
class Show {
  const Show({
    required this.id,
    required this.name,
    this.summary,
    this.genres = const [],
    this.rating,
    this.imageMedium,
    this.imageOriginal,
    this.status,
    this.premiered,
    this.scheduleDays = const [],
    this.scheduleTime,
    this.networkName,
    this.webChannelName,
    this.cast = const [],
  });

  final int id;
  final String name;
  final String? summary;
  final List<String> genres;
  final double? rating;
  final String? imageMedium;
  final String? imageOriginal;
  final String? status;
  final String? premiered;
  final List<String> scheduleDays;
  final String? scheduleTime;
  final String? networkName;
  final String? webChannelName;
  final List<CastMember> cast;

  /// Parses a [Show] from a TVMaze API JSON response.
  ///
  /// Handles the search endpoint wrapper format `{score, show}` as well
  /// as the direct show object format.
  factory Show.fromJson(Map<String, dynamic> json) {
    // Search endpoint returns {score: x, show: {...}}
    final data = json.containsKey('show')
        ? json['show'] as Map<String, dynamic>
        : json;

    // Parse image URLs safely
    final image = data['image'] as Map<String, dynamic>?;
    final imageMedium = image?['medium'] as String?;
    final imageOriginal = image?['original'] as String?;

    // Parse rating safely
    final ratingMap = data['rating'] as Map<String, dynamic>?;
    final ratingValue = ratingMap?['average'];
    final rating = ratingValue != null ? (ratingValue as num).toDouble() : null;

    // Parse schedule
    final schedule = data['schedule'] as Map<String, dynamic>?;
    final scheduleDays = (schedule?['days'] as List<dynamic>?)
            ?.map((d) => d as String)
            .toList() ??
        [];
    final scheduleTime = schedule?['time'] as String?;

    // Parse network/webchannel
    final network = data['network'] as Map<String, dynamic>?;
    final webChannel = data['webChannel'] as Map<String, dynamic>?;

    // Parse embedded cast if available
    final embedded = data['_embedded'] as Map<String, dynamic>?;
    final castList = (embedded?['cast'] as List<dynamic>?)
            ?.map((c) => CastMember.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    return Show(
      id: data['id'] as int,
      name: data['name'] as String? ?? 'Unknown',
      summary: data['summary'] as String?,
      genres: (data['genres'] as List<dynamic>?)
              ?.map((g) => g as String)
              .toList() ??
          [],
      rating: rating,
      imageMedium: imageMedium,
      imageOriginal: imageOriginal,
      status: data['status'] as String?,
      premiered: data['premiered'] as String?,
      scheduleDays: scheduleDays,
      scheduleTime: scheduleTime,
      networkName: network?['name'] as String?,
      webChannelName: webChannel?['name'] as String?,
      cast: castList,
    );
  }

  /// Creates a copy of this [Show] with [cast] replaced.
  Show copyWithCast(List<CastMember> cast) {
    return Show(
      id: id,
      name: name,
      summary: summary,
      genres: genres,
      rating: rating,
      imageMedium: imageMedium,
      imageOriginal: imageOriginal,
      status: status,
      premiered: premiered,
      scheduleDays: scheduleDays,
      scheduleTime: scheduleTime,
      networkName: networkName,
      webChannelName: webChannelName,
      cast: cast,
    );
  }
}

/// Represents a cast member in a TV show.
class CastMember {
  const CastMember({
    required this.personName,
    this.personImage,
    this.characterName,
  });

  final String personName;
  final String? personImage;
  final String? characterName;

  /// Parses a [CastMember] from the TVMaze cast API response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "person": {"name": "...", "image": {"medium": "..."}},
  ///   "character": {"name": "..."}
  /// }
  /// ```
  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>?;
    final character = json['character'] as Map<String, dynamic>?;
    final personImage = person?['image'] as Map<String, dynamic>?;

    return CastMember(
      personName: person?['name'] as String? ?? 'Unknown',
      personImage: personImage?['medium'] as String?,
      characterName: character?['name'] as String?,
    );
  }
}
