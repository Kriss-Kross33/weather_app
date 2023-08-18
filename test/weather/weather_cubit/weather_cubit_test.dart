import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

import '../../helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  initHydratedStorage();
  late MockWeatherRepository mockWeatherRepository;
  late MockWeather mockWeather;
  late WeatherCubit weatherCubit;
  const weatherLocation = 'London';
  const weatherCondition = weather_repository.WeatherCondition.clear;
  const weatherTemperature = 15.0;
  group('WeatherCubit', () {
    setUp(() {
      mockWeatherRepository = MockWeatherRepository();
      mockWeather = MockWeather();
      weatherCubit = WeatherCubit(mockWeatherRepository);
      when(() => mockWeather.condition).thenReturn(weatherCondition);
      when(() => mockWeather.location).thenReturn(weatherLocation);
      when(() => mockWeather.temperature).thenReturn(weatherTemperature);
      when(() => mockWeatherRepository.getWeather(any()))
          .thenAnswer((async) async => mockWeather);
    });

    test('initial state is correct', () {
      expect(weatherCubit.state, WeatherState());
    });

    group('toJson/fromJson', () {
      test('works properly', () {
        expect(
          weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
          weatherCubit.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => <WeatherState>[],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        verify: (_) {
          verify(() => mockWeatherRepository.getWeather(weatherLocation));
        },
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws an Exception',
        build: () => weatherCubit,
        setUp: () {
          when(() => mockWeatherRepository.getWeather(any()))
              .thenThrow(Exception('oops'));
        },
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(
            status: WeatherStatus.failure,
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, loaded] when getWeather returns (celcius)',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      const Temperature(value: weatherTemperature),
                    ),
              )
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                        (w) => w.temperature,
                        'temperature',
                        Temperature(
                          value: weatherTemperature.toFahrenheit(),
                        )),
              )
              .having(
                (ws) => ws.temperatureUnits,
                'temperatureUnits',
                TemperatureUnits.fahrenheit,
              ),
        ],
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when status is success',
        build: () => weatherCubit,
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) => verifyNever(
            () => mockWeatherRepository.getWeather(weatherLocation)),
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when weather is empty',
        build: () => weatherCubit,
        seed: () => WeatherState(weather: Weather.empty),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) => verifyNever(
          () => mockWeatherRepository.getWeather(weatherLocation),
        ),
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [failure] when getWeather throws an exception',
        build: () => weatherCubit,
        act: (cubit) => cubit.refreshWeather(),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: weatherCondition,
            location: weatherLocation,
            lastUpdated: DateTime(2023),
            temperature: const Temperature(value: weatherTemperature),
          ),
        ),
        setUp: () =>
            when(() => mockWeatherRepository.getWeather(any())).thenThrow(
          Exception('oops'),
        ),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.failure,
            weather: Weather(
              condition: weatherCondition,
              location: weatherLocation,
              lastUpdated: DateTime(2023),
              temperature: const Temperature(value: weatherTemperature),
            ),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emit [success] when getWeather returns (celcius)',
        build: () => weatherCubit,
        act: (cubit) => cubit.refreshWeather(),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: weatherCondition,
            location: weatherLocation,
            lastUpdated: DateTime(2023),
            temperature: const Temperature(value: weatherTemperature),
          ),
        ),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      const Temperature(value: weatherTemperature),
                    ),
              )
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [success] when getWeather returns (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
            condition: weatherCondition,
            location: weatherLocation,
            lastUpdated: DateTime(2023),
            temperature: const Temperature(value: weatherTemperature),
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having((ws) => ws.temperatureUnits, 'temperatureUnits',
                  TemperatureUnits.fahrenheit)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature.toFahrenheit()),
                    ),
              ),
        ],
      );
    });

    group('toggleUnits', () {
      blocTest<WeatherCubit, WeatherState>(
        'emit updated units when status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emit updated temperature when weather is empty (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            condition: weatherCondition,
            lastUpdated: DateTime(2023),
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.temperatureUnits, 'temperatureUnits',
                  TemperatureUnits.fahrenheit)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.temperature, 'temperature',
                        Temperature(value: weatherTemperature.toFahrenheit()))
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull),
              )
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emit updated temperature when weather is empty (celcius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
            condition: weather_repository.WeatherCondition.snowy,
            lastUpdated: DateTime(2023),
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having(
                (ws) => ws.temperatureUnits,
                'temperatureUnits',
                TemperatureUnits.celsius,
              )
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having(
                      (w) => w.condition,
                      'condition',
                      weather_repository.WeatherCondition.snowy,
                    )
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      Temperature(
                        value: weatherTemperature.toCelsius(),
                      ),
                    ),
              ),
        ],
      );
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
