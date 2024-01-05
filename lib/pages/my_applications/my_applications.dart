import 'package:flutter/material.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyApplications extends StatefulWidget {
  const MyApplications({super.key});

  @override
  State<MyApplications> createState() => _MyApplicationsState();
}

class _MyApplicationsState extends State<MyApplications> {
  @override
  Widget build(BuildContext context) {
    return AppScafofld(
        child: Column(
      children: [
        CustomTextWidget(text: 'MY APPLICATIONS'),
        Row(
          children: [
            const SizedBox(
              height: 150,
              width: 150,
              child: DashboardChart(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chartLabels(
                    color: Colors.yellow, label: 'Pending For  Kyc Approval'),
                chartLabels(color: Colors.cyan, label: 'Pending For payment'),
                chartLabels(
                    color: Colors.purple, label: 'Pending For Deployment'),
                chartLabels(color: Colors.green, label: 'Live'),
              ],
            )
          ],
        )
      ],
    ));
  }

  Row chartLabels({
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: color, border: Border.all(width: 1, color: Colors.black)),
        ),
        const SizedBox(
          width: 10,
        ),
        CustomTextWidget(text: label)
      ],
    );
  }
}

class ChartData {
  final String category;
  final double sales;
  final Color color;

  ChartData(this.category, this.sales, this.color);
}

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: <ChartData>[
            ChartData('Pending For  Kyc Approval', 30, Colors.yellow),
            ChartData('Pending For payment', 40, Colors.cyan),
            ChartData('Pending For Deployment', 10, Colors.purple),
            ChartData('Live', 20, Colors.green),
          ],
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.sales,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          innerRadius: '50%',
          pointColorMapper: (ChartData data, _) => data.color,
          radius: '100%',
        ),
      ],
    );
  }
}
