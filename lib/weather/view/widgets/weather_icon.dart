part of 'weather_view.dart';

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.condition});

  final WeatherCondition condition;

  static const _iconSize = 75.0;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    return switch (this) {
      WeatherCondition.clear => '☀️',
      WeatherCondition.cloudy => '☁️',
      WeatherCondition.rainy => '🌧️',
      WeatherCondition.snowy => '🌨️',
      WeatherCondition.unknown => '❓',
    };
  }
}
