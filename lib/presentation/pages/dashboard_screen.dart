import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Color posColor = Color.fromARGB(255, 80, 150, 241);
  Color emiMdrColor = const Color.fromARGB(255, 235, 123, 48);
  Color upiColor = const Color.fromARGB(255, 88, 224, 9);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.setMonthRange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return MerchantScaffold(
      //  backgroundColor: const Color(0xFFF2F3F7),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Transactions Report",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Period selector
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: Period.values.map((period) {
              //     final selected = provider.selectedPeriod == period;
              //     return Expanded(
              //       child: GestureDetector(
              //         onTap: () => provider.changePeriod(period, context),
              //         child: Container(
              //           margin: const EdgeInsets.symmetric(horizontal: 4),
              //           padding: const EdgeInsets.symmetric(vertical: 10),
              //           decoration: BoxDecoration(
              //             color: selected ? Colors.white : Colors.transparent,
              //             borderRadius: BorderRadius.circular(14),
              //           ),
              //           child: Center(
              //             child: Text(
              //               period.name.toUpperCase(),
              //               style: TextStyle(
              //                 fontWeight: FontWeight.w600,
              //                 color: selected ? Colors.black : Colors.grey,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),

              monthSelectionWidget(provider),

              const SizedBox(height: 20),

              _chartCard(provider),

              const SizedBox(height: 20),

              _summaryCard(),

              // const SizedBox(height: 20),

              // _schemeFilter(provider),

              // const SizedBox(height: 16),

              // _schemeCards(provider),
            ],
          ),
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
    const double groupWidth = 100;

    /// dynamic width
    final double chartWidth =
        provider.chartData.length * groupWidth < screenWidth
            ? screenWidth
            : provider.chartData.length * groupWidth;

    return Container(
      // padding: const EdgeInsets.all(16),
      height: 300,
      decoration: _card(),
      child:
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   physics: const BouncingScrollPhysics(),
          //   child:
          SizedBox(
        width: chartWidth,
        child: BarChart(
          BarChartData(
            maxY: provider.maxY,

            /// GRID
            // gridData: FlGridData(
            //   show: true,
            //   horizontalInterval: provider.maxY / 3,
            //   // getDrawingHorizontalLine: (value) {
            //   //   return FlLine(
            //   //     color: Colors.grey.withOpacity(0.2),
            //   //     strokeWidth: 1,
            //   //   );
            //   // },
            // ),

            borderData: FlBorderData(show: false),

            /// TITLES
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 50,
                  showTitles: true,
                  interval: provider.maxY / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 8),
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
            // barTouchData: BarTouchData(
            //   touchTooltipData: BarTouchTooltipData(
            //     // tooltipBgColor: Colors.black87,
            //     getTooltipItem: (group, groupIndex, rod, rodIndex) {
            //       final data = provider.chartData[group.x.toInt()];
            //       final isSuccess = rodIndex == 0;

            //       return BarTooltipItem(
            //         isSuccess
            //             ? "POS: ${data.posSuccess}"
            //             : "UPI: ${data.upiSuccess}",
            //         const TextStyle(color: Colors.white),
            //       );
            //     },
            //   ),
            // ),

            /// BARS
            barGroups: List.generate(provider.chartData.length, (i) {
              final e = provider.chartData[i];

              return BarChartGroupData(
                x: i,
                barsSpace: 10,
                barRods: [
                  BarChartRodData(
                      toY: e.posSuccess,
                      width: 10,
                      // borderRadius: BorderRadius.circular(6),
                      color: posColor,
                      label: BarChartRodLabel(
                          show: e.posSuccess > 0,
                          text: e.posSuccess.toString(),
                          style: TextStyle(fontSize: 8, color: posColor))),
                  BarChartRodData(
                      toY: e.emiMdrAmount,
                      width: 10,
                      // borderRadius: BorderRadius.circular(6),
                      color: emiMdrColor,
                      label: BarChartRodLabel(
                          show: e.emiMdrAmount > 0,
                          text: e.emiMdrAmount.toString(),
                          style: TextStyle(fontSize: 8, color: emiMdrColor))),
                  BarChartRodData(
                      toY: e.upiSuccess,
                      width: 10,
                      // borderRadius: BorderRadius.circular(6),
                      color: upiColor,
                      label: BarChartRodLabel(
                          show: e.upiSuccess > 0,
                          text: e.upiSuccess.toString(),
                          style: TextStyle(fontSize: 8, color: upiColor))),
                ],
              );
            }),
          ),
        ),
      ),
      // ),
    );
  }

  Widget _summaryCard() {
    Widget legendItem(String text, Color color, {EdgeInsetsGeometry? padding}) {
      return Padding(
        padding: padding ?? EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        legendItem("POS Transactions - Sum of Total Amount Payable to Merchant",
            posColor),
        const SizedBox(height: 10),
        legendItem("Sum of Emi MDR", emiMdrColor),
        const SizedBox(height: 10),
        legendItem("UPI Transactions - Sum of Total Amount Payable to Merchant",
            upiColor),
      ],
    );
  }

  Widget monthSelectionWidget(TransactionProvider provider) {
    return Row(
      children: [
        buildCard("From Month", provider.fromMonth, true),
        SizedBox(width: 10),
        buildCard("To Month", provider.toMonth, false),
      ],
    );
  }

  Widget buildCard(String title, DateTime? value, bool fromMonth) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Provider.of<TransactionProvider>(context, listen: false)
            .pickMonth(fromMonth, context),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              // Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                Provider.of<TransactionProvider>(context, listen: false)
                    .formatMonth(value),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
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
      borderRadius: BorderRadius.circular(5),
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
