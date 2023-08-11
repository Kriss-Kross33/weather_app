import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

import 'lol.dart';

class MockClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Mock implements Uri {}

void main() {
  late MockClient mockClient;
  late MockResponse mockResponse;
  late FakeUri fakeUri;
  late OpenMeteoApiClient openMeteoApiClient;

  setUp(() {
    mockClient = MockClient();
    mockResponse = MockResponse();
    openMeteoApiClient = OpenMeteoApiClient(httpClient: mockClient);
  });

  setUpAll(() {
    fakeUri = FakeUri();
    registerFallbackValue(fakeUri);
  });

  group('OpenMeteoApiClient', () {
    group('constructor', () {
      test('should note require an http client', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'mock-query';
      final uri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {'name': query, 'count': '1'},
      );
      test('makes correct http request', () async {
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('{}');
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        try {
          await openMeteoApiClient.locationSearch(query);
        } catch (_) {}
        verify(() => mockClient.get(uri)).called(1);
      });

      test('throws LocationRequestFailure on a non-200 status code', () {
        when(() => mockResponse.statusCode).thenReturn(400);
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = openMeteoApiClient.locationSearch;
        expect(
          () => result(query),
          throwsA(
            isA<LocationRequestFailure>(),
          ),
        );
      });

      test('throws LocationNotFoundFailure on an error response', () {
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('{}');
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = openMeteoApiClient.locationSearch;
        expectLater(
            () => result(query), throwsA(isA<LocationNotFoundFailure>()));
      });

      test('throws a LocationNotFoundFailure on empty response', () {
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('{}');
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = openMeteoApiClient.locationSearch;
        expect(() => result(query), throwsA(isA<LocationNotFoundFailure>()));
      });

      test('returns Location on valid response', () async {
        final body = '''
                      {
                        "results": [
                          {
                            "id": 4887398,
                            "name": "Chicago",
                            "latitude": 41.85003,
                            "longitude": -87.65005
                          }
                        ]
                      }
                    ''';
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn(body);
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = await openMeteoApiClient.locationSearch(query);
        expect(
          result,
          isA<Location>()
              .having((l) => l.latitude, 'latitude', 41.85003)
              .having((l) => l.longitude, 'longitude', -87.65005),
        );
      });
    });

    group('getWeather', () {
      test('make a valid http request', () async {
        const latitude = 41.85003;
        const longitude = -87.6500;
        final uri = Uri.https('api.open-meteo.com', 'v1/forecast', {
          'latitude': '$latitude',
          'longitude': '$longitude',
          'current_weather': 'true'
        });
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('{}');
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        try {
          await openMeteoApiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          );
        } catch (_) {}
        verify(() => mockClient.get(uri)).called(1);
      });

      test('throws a WeatherRequestFailure on a non-200 status code', () {
        when(() => mockResponse.statusCode).thenReturn(400);
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = openMeteoApiClient.getWeather;
        expect(
          () => result(latitude: latitude, longitude: longitude),
          throwsA(
            isA<WeatherRequestFailure>(),
          ),
        );
      });

      test('throws a WeatherNotFoundFailure on empty response', () async {
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('{}');
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = openMeteoApiClient.getWeather;
        expect(
          () => result(latitude: latitude, longitude: longitude),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test('returns a Weather when response is valid', () async {
        final body = '''
            {
              "latitude": 43,
              "longitude": -87.875,
              "generationtime_ms": 0.2510547637939453,
              "utc_offset_seconds": 0,
              "timezone": "GMT",
              "timezone_abbreviation": "GMT",
              "elevation": 189,
              "current_weather": {
                "temperature": 15.3,
                "windspeed": 25.8,
                "winddirection": 310,
                "weathercode": 63,
                "time": "2022-09-12T01:00"
              }
            }
        ''';
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn(body);
        when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);
        final result = await openMeteoApiClient.getWeather(
          latitude: latitude,
          longitude: longitude,
        );
        expect(
          result,
          isA<Weather>()
              .having((w) => w.temperature, 'temperature', 15.3)
              .having((w) => w.weatherCode, 'weatherCode', 63),
        );
      });
    });
  });
}
