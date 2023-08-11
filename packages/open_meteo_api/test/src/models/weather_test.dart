import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      final weather = Weather.fromJson(
        <String, dynamic>{
          'temperature': 15.3,
          'weathercode': 63,
        },
      );
      test('returns correct Weaather object', () {
        expect(
          weather,
          isA<Weather>()
              .having(
                (w) => w.temperature,
                'temperature',
                15.3,
              )
              .having(
                (w) => w.weatherCode,
                'weatherCode',
                63,
              ),
        );
      });
    });
  });
}
