import 'package:test/test.dart';
import 'package:weather_repository/src/models/models.dart';

void main() {
  group(('Weather'), () {
    final weather = Weather.fromJson(<String, dynamic>{
      'location': 'Accra',
      'temperature': 26.3,
      'condition': 'rainy',
    });
    group('fromJson', () {
      test('should return the correct Weather object', () {
        expect(
            weather,
            isA<Weather>()
                .having((w) => w.location, 'location', 'Accra')
                .having((w) => w.temperature, 'temperature', 26.3)
                .having(
                  (w) => w.condition,
                  'condition',
                  WeatherCondition.rainy,
                ));
      });
    });

    group('toJson', () {
      test(('should return the JSON map containing the proper data'), () {
        final weatherMap = weather.toJson();
        expect(
            weatherMap,
            equals({
              'location': 'Accra',
              'temperature': 26.3,
              'condition': 'rainy',
            }));
      });
    });
  });
}
