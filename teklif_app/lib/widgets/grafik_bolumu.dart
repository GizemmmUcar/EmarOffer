import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrafikBolumu extends StatelessWidget {
  final List<dynamic> grafikVerileri;

  const GrafikBolumu({super.key, required this.grafikVerileri});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> noktalar = [];
    List<String> xEkseniGunleri = [];

    if (grafikVerileri.isNotEmpty) {
      for (int i = 0; i < grafikVerileri.length; i++) {
        final data = grafikVerileri[i];
        double sayi = (data["sayi"] ?? 0).toDouble();

        noktalar.add(FlSpot(i.toDouble(), sayi));
        xEkseniGunleri.add(data["gunAdi"].toString());
      }
    } else {
      for (int i = 0; i < 7; i++) {
        noktalar.add(FlSpot(i.toDouble(), 0));
        xEkseniGunleri.add("");
      }
    }

    return Container(
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Teklif Performansı",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const Text(
            "Son 7 Günlük Gerçek İstatistik",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[200], strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) return const Text('');
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < xEkseniGunleri.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              xEkseniGunleri[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: noktalar,
                    isCurved: true,
                    color: Colors.indigo,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.indigo,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.indigo.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
