import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      final location = Location.fromJson(
        <String, dynamic>{
          'id': 4887398,
          'name': 'Chicago',
          'latitude': 41.85003,
          'longitude': -87.65005,
        },
      );
      test('returns correct Location object', () {
        expect(
            location,
            isA<Location>()
                .having((w) => w.id, 'id', 4887398)
                .having((w) => w.name, 'name', 'Chicago')
                .having((w) => w.latitude, 'latitude', 41.85003)
                .having((w) => w.longitude, 'longitude', -87.65005));
      });
    });
  });
}
