import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_app/theme/cubit/theme_cubit.dart';
import 'package:weather_app/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

import '../helpers/hydrated_bloc.dart';

class MockWeather extends Mock implements Weather {
  MockWeather(this._condition);

  final WeatherCondition _condition;

  @override
  WeatherCondition get condition => _condition;
}

void main() {
  late ThemeCubit themeCubit;
  initHydratedStorage();

  setUp(() {
    themeCubit = ThemeCubit();
  });
  group('ThemeCubit', () {
    test('initial state is correct', () {
      expect(ThemeCubit().state, ThemeCubit.defaultColor);
    });

    group('fromJson/toJson', () {
      test('works properly', () {
        final themeCubit = ThemeCubit();
        expect(themeCubit.fromJson(themeCubit.toJson(themeCubit.state)),
            equals(themeCubit.state));
      });
    });

    group('updateTheme', () {
      final clearWeather = MockWeather(WeatherCondition.clear);
      final snowyWeather = MockWeather(WeatherCondition.snowy);
      final rainyWeather = MockWeather(WeatherCondition.rainy);
      final cloudyWeather = MockWeather(WeatherCondition.cloudy);
      final unknownWeather = MockWeather(WeatherCondition.unknown);

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.clear',
        build: () => themeCubit,
        act: (cubit) => cubit.updateTheme(clearWeather),
        expect: () => <Color>[Colors.orangeAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.snowy',
        build: () => themeCubit,
        act: (cubit) => cubit.updateTheme(snowyWeather),
        expect: () => <Color>[Colors.lightBlueAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.cloudy',
        build: () => themeCubit,
        act: (cubit) => cubit.updateTheme(cloudyWeather),
        expect: () => <Color>[Colors.blueGrey],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.rainy',
        build: () => themeCubit,
        act: (cubit) => cubit.updateTheme(rainyWeather),
        expect: () => <Color>[Colors.indigoAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.unknown',
        build: () => themeCubit,
        act: (cubit) => cubit.updateTheme(unknownWeather),
        expect: () => <Color>[ThemeCubit.defaultColor],
      );
    });
  });
}
