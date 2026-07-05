import 'currency_formatter.dart';

abstract final class AppFormatters {
  static String vnd(num value) => formatVnd(value.toDouble());
}
