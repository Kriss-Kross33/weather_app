part of 'weather_view.dart';

class WeatherLoading extends StatelessWidget {
  const WeatherLoading({super.key});

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
          'Loading Weather',
          style: theme.textTheme.headlineSmall,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoActivityIndicator(),
        ),
      ],
    );
  }
}
