import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

void main() {
  late MockOpenMeteoApiClient mockApiClient;
  late WeatherRepository weatherRepository;

  late MockLocation mockLocation;

  group('WeatherRepository', () {
    setUp(() {
      mockApiClient = MockOpenMeteoApiClient();

      mockLocation = MockLocation();
      weatherRepository = WeatherRepository(openMeteoApiClient: mockApiClient);
    });

    group('constructor', () {
      test('should not required OpenMeteoApiClient', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      final city = 'Chicago';
      const latitude = 41.85003;
      const longitude = -87.65005;

      final location = open_meteo_api.Location(
        id: 1,
        name: city,
        latitude: latitude,
        longitude: longitude,
      );

      final weather = open_meteo_api.Weather(
        temperature: 15,
        weatherCode: 0,
      );

      setUp(() {
        when(() => mockLocation.latitude).thenReturn(latitude);
        when(() => mockLocation.longitude).thenReturn(longitude);
      });

      test('should call locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => mockApiClient.locationSearch(city));
      });

      test('throws Exceoption when locationSearch fails', () async {
        final exception = Exception('oops');
        when(() => mockApiClient.locationSearch(any())).thenThrow(exception);
        final result = await weatherRepository.getWeather;
        expect(() => result(city), throwsA(exception));
      });

      test('calls getWeather with correct latitude and longitude', () async {
        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => mockLocation);
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(
          () => mockApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).called(1);
      });

      test('throws Exception when getWeatherFails', () async {
        final exception = Exception('oops');

        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => mockLocation);
        when(() => mockApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'))).thenThrow(exception);

        final result = await weatherRepository.getWeather;
        expect(() => result(city), throwsA(exception));
      });

      test('returns correct Weather on success', () async {
        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude')))
            .thenAnswer((_) async => weather);

        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            isA<Weather>()
                .having((w) => w.condition, 'condition', WeatherCondition.clear)
                .having((w) => w.location, 'location', 'Chicago')
                .having((w) => w.temperature, 'temperature', 15));
      });

      test('return Weather on success (clear)', () async {
        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
            latitude: latitude,
            longitude: longitude)).thenAnswer((_) async => weather);
        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            equals(Weather(
              condition: WeatherCondition.clear,
              temperature: weather.temperature,
              location: city,
            )));
      });

      test('return Weather on success (cloudy)', () async {
        final weather = open_meteo_api.Weather(
          temperature: 15,
          weatherCode: 1,
        );

        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
            latitude: latitude,
            longitude: longitude)).thenAnswer((_) async => weather);
        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            equals(Weather(
              condition: WeatherCondition.cloudy,
              temperature: weather.temperature,
              location: city,
            )));
      });
      test('return Weather on success (rainy)', () async {
        final weather = open_meteo_api.Weather(
          temperature: 15,
          weatherCode: 51,
        );

        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
            latitude: latitude,
            longitude: longitude)).thenAnswer((_) async => weather);
        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            equals(Weather(
              condition: WeatherCondition.rainy,
              temperature: weather.temperature,
              location: city,
            )));
      });

      test('return Weather on success (snowy)', () async {
        final weather = open_meteo_api.Weather(
          temperature: 15,
          weatherCode: 71,
        );

        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
            latitude: latitude,
            longitude: longitude)).thenAnswer((_) async => weather);
        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            equals(Weather(
              condition: WeatherCondition.snowy,
              temperature: weather.temperature,
              location: city,
            )));
      });

      test('return Weather on success (snowy)', () async {
        final weather = open_meteo_api.Weather(
          temperature: 15,
          weatherCode: 90,
        );

        when(() => mockApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => mockApiClient.getWeather(
            latitude: latitude,
            longitude: longitude)).thenAnswer((_) async => weather);
        final result = await weatherRepository.getWeather(city);
        expect(
            result,
            equals(Weather(
              condition: WeatherCondition.unknown,
              temperature: weather.temperature,
              location: city,
            )));
      });
    });
  });
}
