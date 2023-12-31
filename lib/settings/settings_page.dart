import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/weather/models/weather.dart';

import '../weather/weather_cubit/weather_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage._();

  static Route<void> route(WeatherCubit weatherCubit) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: weatherCubit,
        child: const SettingsPage._(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        buildWhen: (previous, current) =>
            previous.temperatureUnits != current.temperatureUnits,
        builder: (context, state) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Temperature Units'),
                isThreeLine: true,
                subtitle: const Text(
                    'Use metric measurements for temperature units.'),
                trailing: Switch.adaptive(
                  value: state.temperatureUnits.isCelsius,
                  onChanged: (_) => context.read<WeatherCubit>().toggleUnits(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
