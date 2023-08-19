part of 'weather_view.dart';

class _WeatherError extends StatelessWidget {
  const _WeatherError();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Text(
          '🙈',
          style: TextStyle(fontSize: 64),
        ),
        Text(
          'Something went wront',
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}
