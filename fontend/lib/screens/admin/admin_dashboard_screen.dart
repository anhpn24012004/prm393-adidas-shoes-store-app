import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  late Future<AdminDashboardModel> _future;
  String _chartRange = 'weekly';

  @override
  void initState() {
    super.initState();
    _future = _service.getDashboard();
  }

  void _reload() {
    setState(() => _future = _service.getDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: FutureBuilder<AdminDashboardModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: ElevatedButton(
                  onPressed: _reload,
                  child: Text(context.tr('retry').toUpperCase()),
                ),
              );
            }

            return _DashboardContent(
              data: snapshot.data!,
              chartRange: _chartRange,
              onRangeChanged: (value) => setState(() => _chartRange = value),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AdminDashboardModel data;
  final String chartRange;
  final ValueChanged<String> onRangeChanged;

  const _DashboardContent({
    required this.data,
    required this.chartRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final revenue = formatVnd(data.totalRevenue);
    final totalActivity =
        data.totalOrders + data.totalProducts + data.totalUsers;
    final chartValues = _chartValues(data);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.tr('adminDashboard'),
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.32,
          children: [
            _MetricCard(
              value: '${data.totalProducts}',
              label: context.tr('metricProducts'),
              progress: _ratio(data.totalProducts, totalActivity),
              dark: true,
            ),
            _MetricCard(
              value: '${data.totalOrders}',
              label: context.tr('metricOrders'),
              progress: _ratio(data.totalOrders, totalActivity),
              color: AppColors.blue,
            ),
            _MetricCard(
              value: '${data.totalUsers}',
              label: context.tr('metricCustomers'),
              progress: _ratio(data.totalUsers, totalActivity),
            ),
            _MetricCard(
              value: _compactMoney(data.totalRevenue),
              label: context.tr('metricRevenue'),
              progress: data.totalRevenue <= 0
                  ? 0
                  : math.min(data.totalRevenue / 100000000, 1),
              color: const Color(0xFFE1AEC1),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('metricRevenue'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _RangeSelector(value: chartRange, onChanged: onRangeChanged),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 190,
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                revenue,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  painter: _RevenueChartPainter(
                    values: chartValues,
                    accentValues: chartValues.reversed.toList(),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          context.tr('adminTools').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        _AdminActionGrid(
          actions: [
            _AdminAction(
              icon: Icons.people_outline,
              label: context.tr('userManagement'),
              route: '/admin/users',
            ),
            _AdminAction(
              icon: Icons.receipt_long_outlined,
              label: context.tr('orderManagement'),
              route: '/admin/orders',
            ),
            _AdminAction(
              icon: Icons.inventory_2_outlined,
              label: context.tr('productManagement'),
              route: '/admin/products',
            ),
            _AdminAction(
              icon: Icons.assignment_return_outlined,
              label: context.tr('returnsRefunds'),
              route: '/admin/returns-refunds',
            ),
            _AdminAction(
              icon: Icons.local_shipping_outlined,
              label: context.tr('shipmentManagement'),
              route: '/admin/shipments',
            ),
            _AdminAction(
              icon: Icons.category_outlined,
              label: context.tr('categoryManagement'),
              route: '/admin/categories',
            ),
          ],
        ),
      ],
    );
  }

  static double _ratio(num value, num total) {
    if (total <= 0) return 0;
    return math.min(value / total, 1).toDouble();
  }

  static String _compactMoney(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  static List<double> _chartValues(AdminDashboardModel data) {
    final revenueUnit = data.totalRevenue <= 0
        ? 18.0
        : data.totalRevenue / 1000000;
    return [
      math.max(14.0, data.totalOrders + 14.0),
      math.max(18.0, data.totalUsers / 2),
      math.max(20.0, data.totalProducts + data.pendingOrders + 10.0),
      math.max(16.0, data.completedOrders + 15.0),
      math.max(22.0, revenueUnit + data.totalRefundRequests + 18.0),
      math.max(15.0, data.totalReviews + 12.0),
      math.max(18.0, data.pendingOrders + data.totalOrders + 12.0),
    ];
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final double progress;
  final bool dark;
  final Color? color;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.progress,
    this.dark = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final background = dark ? Colors.black : Colors.white;
    final textColor = dark ? Colors.white : Colors.black;
    final mutedColor = dark ? Colors.white70 : AppColors.muted;
    final barColor = dark ? Colors.white : color ?? const Color(0xFFDDE4E8);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          const Spacer(),
          Row(
            children: [
              Text('0%', style: TextStyle(color: mutedColor, fontSize: 11)),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              color: barColor,
              backgroundColor: dark
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFEDEDED),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RangeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('monthly', 'Tháng'),
      ('weekly', 'Tuần'),
      ('today', 'Hôm nay'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E1E1)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final selected = value == item.$1;
          return InkWell(
            onTap: () => onChanged(item.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: selected ? Colors.black : Colors.white,
              child: Text(
                item.$2,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AdminActionGrid extends StatelessWidget {
  final List<_AdminAction> actions;

  const _AdminActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.05,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, action.route),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(action.icon, color: AppColors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminAction {
  final IconData icon;
  final String label;
  final String route;

  const _AdminAction({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _RevenueChartPainter extends CustomPainter {
  final List<double> values;
  final List<double> accentValues;

  const _RevenueChartPainter({
    required this.values,
    required this.accentValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDADADA)
      ..strokeWidth = 1;
    final labelPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    final chartRect = Rect.fromLTWH(28, 2, size.width - 34, size.height - 22);

    for (var i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * i / 5;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    for (var i = 0; i <= 6; i++) {
      final x = chartRect.left + chartRect.width * i / 6;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }

    final maxValue = [
      ...values,
      ...accentValues,
    ].fold<double>(1, (max, value) => math.max(max, value).toDouble());
    final minValue = [
      ...values,
      ...accentValues,
    ].fold<double>(maxValue, (min, value) => math.min(min, value).toDouble());

    final range = math.max(maxValue - minValue, 1).toDouble();
    final primaryPath = _pathFor(values, chartRect, minValue, range);
    final accentPath = _pathFor(accentValues, chartRect, minValue, range);

    canvas.drawPath(
      accentPath,
      Paint()
        ..color = const Color(0xFFE0B1C2)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      primaryPath,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var i = 0; i < labels.length; i++) {
      final x = chartRect.left + chartRect.width * i / (labels.length - 1);
      labelPaint.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      labelPaint.layout();
      labelPaint.paint(
        canvas,
        Offset(x - labelPaint.width / 2, chartRect.bottom + 7),
      );
    }
  }

  Path _pathFor(List<double> source, Rect rect, double minValue, double range) {
    final path = Path();
    for (var i = 0; i < source.length; i++) {
      final x = rect.left + rect.width * i / (source.length - 1);
      final normalized = (source[i] - minValue) / range;
      final y = rect.bottom - rect.height * normalized;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.accentValues != accentValues;
  }
}
