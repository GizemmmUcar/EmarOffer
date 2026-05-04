import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class GrafikBolumu extends StatefulWidget {
  const GrafikBolumu({super.key});

  @override
  State<GrafikBolumu> createState() => _GrafikBolumuState();
}

class _GrafikBolumuState extends State<GrafikBolumu> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _tumTeklifler = [];

  String _secilenZaman = 'Haftalık';
  final List<String> _zamanFiltreleri = [
    'Haftalık',
    '15 Günlük',
    'Aylık',
    'Yıllık',
  ];

  List<double> _grafikVerileri = [];
  List<String> _altEtiketler = [];

  @override
  void initState() {
    super.initState();
    _gercekVerileriCek();
  }

  Future<void> _gercekVerileriCek() async {
    setState(() => _isLoading = true);
    try {
      final veriler = await _apiService.getTeklifler();
      if (mounted) {
        setState(() {
          _tumTeklifler = veriler;
          _isLoading = false;
        });
        _verileriGuncelle(_secilenZaman);
      }
    } catch (e) {
      debugPrint("Grafik verisi çekilemedi: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verileriGuncelle(String zaman) {
    setState(() {
      _secilenZaman = zaman;
      _grafikVerileri = [];
      _altEtiketler = [];

      final now = DateTime.now();

      if (zaman == 'Haftalık') {
        final gunIsimleri = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          _altEtiketler.add(gunIsimleri[date.weekday - 1]);

          int count = _tumTeklifler.where((t) {
            if (t["OlusturmaTarihi"] == null) return false;
            final tDate = DateTime.parse(t["OlusturmaTarihi"]);
            return tDate.year == date.year &&
                tDate.month == date.month &&
                tDate.day == date.day;
          }).length;

          _grafikVerileri.add(count.toDouble());
        }
      } else if (zaman == '15 Günlük') {
        for (int i = 14; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          _altEtiketler.add("${date.day}/${date.month}");

          int count = _tumTeklifler.where((t) {
            if (t["OlusturmaTarihi"] == null) return false;
            final tDate = DateTime.parse(t["OlusturmaTarihi"]);
            return tDate.year == date.year &&
                tDate.month == date.month &&
                tDate.day == date.day;
          }).length;

          _grafikVerileri.add(count.toDouble());
        }
      } else if (zaman == 'Aylık') {
        _altEtiketler = ['4 H. Önce', '3 H. Önce', '2 H. Önce', 'Bu Hafta'];
        for (int i = 3; i >= 0; i--) {
          final baslangic = now.subtract(Duration(days: (i * 7) + 7));
          final bitis = now.subtract(Duration(days: i * 7));

          int count = _tumTeklifler.where((t) {
            if (t["OlusturmaTarihi"] == null) return false;
            final tDate = DateTime.parse(t["OlusturmaTarihi"]);
            return tDate.isAfter(baslangic) &&
                tDate.isBefore(bitis.add(const Duration(days: 1)));
          }).length;

          _grafikVerileri.add(count.toDouble());
        }
      } else if (zaman == 'Yıllık') {
        final ayIsimleri = [
          'Oca',
          'Şub',
          'Mar',
          'Nis',
          'May',
          'Haz',
          'Tem',
          'Ağu',
          'Eyl',
          'Eki',
          'Kas',
          'Ara',
        ];
        _altEtiketler = ayIsimleri;
        for (int i = 1; i <= 12; i++) {
          int count = _tumTeklifler.where((t) {
            if (t["OlusturmaTarihi"] == null) return false;
            final tDate = DateTime.parse(t["OlusturmaTarihi"]);
            return tDate.year == now.year && tDate.month == i;
          }).length;
          _grafikVerileri.add(count.toDouble());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = 5;
    if (_grafikVerileri.isNotEmpty) {
      final computedMax = _grafikVerileri.reduce((a, b) => a > b ? a : b);
      if (computedMax > 0) maxValue = computedMax * 1.2;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Teklif Performansı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Seçili Dönem: $_secilenZaman İstatistikleri",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _secilenZaman,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.indigo,
                      size: 20,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                    items: _zamanFiltreleri.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _verileriGuncelle(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          if (_isLoading)
            const SizedBox(
              height: 350,
              child: Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            )
          else
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.indigo.shade800,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Teklif\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: _altEtiketler[group.x.toInt()],
                              style: TextStyle(
                                color: Colors.indigo.shade100,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _altEtiketler.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              _altEtiketler[index],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                fontSize: _secilenZaman == '15 Günlük' ? 9 : 11,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value != value.toInt())
                            return const SizedBox.shrink();
                          if (value == 0) return const SizedBox.shrink();

                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _grafikVerileri.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.indigo.shade400,
                          width: _secilenZaman == 'Yıllık'
                              ? 12
                              : (_secilenZaman == '15 Günlük' ? 10 : 20),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue,
                            color: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
        ],
      ),
    );
  }
}
