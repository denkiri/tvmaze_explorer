import 'package:flutter_test/flutter_test.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';

void main() {
  group('Show.fromJson', () {
    test('parses a show from list endpoint JSON', () {
      final json = {
        'id': 1,
        'name': 'Under the Dome',
        'genres': ['Drama', 'Science-Fiction', 'Thriller'],
        'status': 'Ended',
        'premiered': '2013-06-24',
        'schedule': {
          'time': '22:00',
          'days': ['Thursday'],
        },
        'rating': {'average': 6.6},
        'network': {
          'id': 2,
          'name': 'CBS',
        },
        'webChannel': null,
        'image': {
          'medium': 'https://static.tvmaze.com/uploads/images/medium_portrait/610/1525272.jpg',
          'original': 'https://static.tvmaze.com/uploads/images/original_untouched/610/1525272.jpg',
        },
        'summary': '<p><b>Under the Dome</b> is a story.</p>',
      };

      final show = Show.fromJson(json);

      expect(show.id, 1);
      expect(show.name, 'Under the Dome');
      expect(show.genres, ['Drama', 'Science-Fiction', 'Thriller']);
      expect(show.status, 'Ended');
      expect(show.premiered, '2013-06-24');
      expect(show.rating, 6.6);
      expect(show.networkName, 'CBS');
      expect(show.webChannelName, isNull);
      expect(show.imageMedium, contains('medium_portrait'));
      expect(show.imageOriginal, contains('original_untouched'));
      expect(show.summary, contains('<p>'));
      expect(show.scheduleDays, ['Thursday']);
      expect(show.scheduleTime, '22:00');
    });

    test('parses a show from search endpoint wrapper format', () {
      final json = {
        'score': 0.9,
        'show': {
          'id': 1,
          'name': 'Under the Dome',
          'genres': ['Drama'],
          'status': 'Ended',
          'rating': {'average': 6.6},
          'image': null,
          'schedule': {'time': '', 'days': []},
          'network': null,
          'webChannel': null,
          'summary': null,
        },
      };

      final show = Show.fromJson(json);

      expect(show.id, 1);
      expect(show.name, 'Under the Dome');
      expect(show.imageMedium, isNull);
      expect(show.imageOriginal, isNull);
      expect(show.networkName, isNull);
    });

    test('handles null/missing fields gracefully', () {
      final json = {
        'id': 99,
        'name': null,
        'genres': null,
        'rating': null,
        'image': null,
        'schedule': null,
        'network': null,
        'webChannel': null,
      };

      final show = Show.fromJson(json);

      expect(show.id, 99);
      expect(show.name, 'Unknown');
      expect(show.genres, isEmpty);
      expect(show.rating, isNull);
      expect(show.imageMedium, isNull);
      expect(show.scheduleDays, isEmpty);
      expect(show.scheduleTime, isNull);
      expect(show.networkName, isNull);
    });
  });

  group('CastMember.fromJson', () {
    test('parses cast member correctly', () {
      final json = {
        'person': {
          'id': 1,
          'name': 'Mike Vogel',
          'image': {
            'medium': 'https://static.tvmaze.com/uploads/images/medium_portrait/0/1815.jpg',
          },
        },
        'character': {
          'id': 1,
          'name': 'Dale "Barbie" Barbara',
        },
      };

      final cast = CastMember.fromJson(json);

      expect(cast.personName, 'Mike Vogel');
      expect(cast.personImage, contains('medium_portrait'));
      expect(cast.characterName, 'Dale "Barbie" Barbara');
    });

    test('handles null character image', () {
      final json = {
        'person': {
          'id': 14,
          'name': 'Jeff Fahey',
          'image': {
            'medium': 'https://example.com/photo.jpg',
          },
        },
        'character': {
          'id': 14,
          'name': 'Sheriff Duke Perkins',
          'image': null,
        },
      };

      final cast = CastMember.fromJson(json);
      expect(cast.personName, 'Jeff Fahey');
      expect(cast.characterName, 'Sheriff Duke Perkins');
    });

    test('handles missing person image', () {
      final json = {
        'person': {
          'name': 'Unknown Actor',
          'image': null,
        },
        'character': {
          'name': 'Some Character',
        },
      };

      final cast = CastMember.fromJson(json);
      expect(cast.personImage, isNull);
    });
  });
}
