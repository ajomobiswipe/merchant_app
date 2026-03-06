import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return MerchantScaffold(
      //  backgroundColor: const Color(0xFFF2F3F7),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transactions Report",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: Period.values.map((period) {
                final selected = provider.selectedPeriod == period;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.changePeriod(period, context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          period.name.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _chartCard(provider),

            const SizedBox(height: 20),

            _summaryCard(provider),

            const SizedBox(height: 20),

            _schemeFilter(provider),

            const SizedBox(height: 16),

            _schemeCards(provider),
          ],
        ),
      ),
      onTapHome: () {
        NavigationService.navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('merchantHomeScreen', (route) => false);
      },
    );
  }

  Widget _chartCard(TransactionProvider provider) {
    final screenWidth =
        MediaQuery.of(NavigationService.navigatorKey.currentContext!)
            .size
            .width;

    /// width per group (adjust if needed)
    const double groupWidth = 70;

    /// dynamic width
    final double chartWidth =
        provider.chartData.length * groupWidth < screenWidth
            ? screenWidth
            : provider.chartData.length * groupWidth;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      decoration: _card(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: chartWidth,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: provider.maxY,

              /// GRID
              gridData: FlGridData(
                show: true,
                horizontalInterval: provider.maxY / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),

              borderData: FlBorderData(show: false),

              /// TITLES
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: provider.maxY / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= provider.chartData.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          provider.chartData[index].label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),

              /// TOOLTIP
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final data = provider.chartData[group.x.toInt()];
                    final isSuccess = rodIndex == 0;

                    return BarTooltipItem(
                      isSuccess
                          ? "Success: ${data.success}"
                          : "Failed: ${data.failed}",
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),

              /// BARS
              barGroups: List.generate(provider.chartData.length, (i) {
                final e = provider.chartData[i];

                return BarChartGroupData(
                  x: i,
                  barsSpace: 10,
                  barRods: [
                    BarChartRodData(
                      toY: e.success,
                      width: 5,
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF2ECC71),
                    ),
                    BarChartRodData(
                      toY: e.failed,
                      width: 5,
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFFE74C3C),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Success ${provider.totalSuccess}",
                  style: const TextStyle(color: Colors.green, fontSize: 16)),
              const SizedBox(height: 6),
              Text("Failed ${provider.totalFailed}",
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          Text("₹${provider.totalAmount.toStringAsFixed(0)}",
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _schemeFilter(TransactionProvider provider) {
    final schemes = ["All", "Visa", "Mastercard", "UPI"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: schemes.map((scheme) {
        final selected = provider.selectedScheme == scheme;
        return Expanded(
          child: GestureDetector(
            onTap: () => provider.changeScheme(scheme),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  scheme,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.black : Colors.grey),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _schemeCards(TransactionProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.filteredSchemes.map((scheme) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scheme.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text("${scheme.totalTxns} txns"),
                const SizedBox(height: 6),
                Text("Success ₹${scheme.successAmount}",
                    style: const TextStyle(color: Colors.green)),
                Text("Failed ₹${scheme.failedAmount}",
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
