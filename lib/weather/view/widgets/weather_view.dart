import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/weather/weather_cubit/weather_cubit.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

import '../../../search/search_page.dart';
import '../../../settings/settings_page.dart';
import '../../models/weather.dart';

part 'weather_background.dart';
part 'weather_empty.dart';
part 'weather_error.dart';
part 'weather_icon.dart';
part 'weather_loaded.dart';
part 'weather_loading.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather'),
        actions: [
          IconButton(
            onPressed: () => SettingsPage.route(
              context.read<WeatherCubit>(),
            ),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {},
          builder: (context, state) {
            return switch (state.status) {
              WeatherStatus.initial => const _WeatherEmpty(),
              WeatherStatus.loading => const _WeatherLoading(),
              WeatherStatus.success => _WeatherLoaded(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () async {},
                ),
              WeatherStatus.failure => const _WeatherError(),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.search,
          semanticLabel: 'Search',
        ),
        onPressed: () async {
          final city = await Navigator.of(context).push(
            SearchPage.route(),
          );
          if (!mounted) return;
          await context.read<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}
