import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/weather/view/widgets/widgets.dart';
import 'package:weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeatherCubit>(
      create: (context) => WeatherCubit(
        context.read<WeatherRepository>(),
      ),
      child: const WeatherView(),
    );
  }
}
