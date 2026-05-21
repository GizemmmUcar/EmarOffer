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

  int _dokunulanPastaIndex = -1;
  double _kabulYuzde = 0;
  double _bekliyorYuzde = 0;
  double _retYuzde = 0;

  String _seciliZaman = "Bu Hafta";
  List<double> _barValues = [];
  List<String> _barLabels = [];

  double _maxY = 5.0;
  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    try {
      final veriler = await _apiService.getTeklifler();
      if (mounted) {
        setState(() {
          _tumTeklifler = veriler;
          _grafikleriHesapla();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _grafikleriHesapla() {
    DateTime bugun = DateTime.now();

    double kabul = 0, ret = 0, bekliyor = 0;
    for (var t in _tumTeklifler) {
      String durum = t["Durum"]?.toString() ?? "";
      if (durum == "Kabul Edildi") {
        kabul++;
      } else if (durum == "Reddedildi") {
        ret++;
      } else {
        bekliyor++;
      }
    }

    double toplam = kabul + ret + bekliyor;
    if (toplam > 0) {
      _kabulYuzde = (kabul / toplam) * 100;
      _bekliyorYuzde = (bekliyor / toplam) * 100;
      _retYuzde = (ret / toplam) * 100;
    } else {
      _kabulYuzde = 0;
      _bekliyorYuzde = 0;
      _retYuzde = 0;
    }

    _barValues = [];
    _barLabels = [];

    if (_seciliZaman == 'Bu Hafta') {
      _barValues = List.filled(7, 0.0, growable: true);
      _barLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

      DateTime haftaninBasi = bugun.subtract(Duration(days: bugun.weekday - 1));
      DateTime haftaninSonu = haftaninBasi.add(
        const Duration(days: 6, hours: 23, minutes: 59),
      );

      for (var t in _tumTeklifler) {
        if (t["OlusturmaTarihi"] != null) {
          try {
            DateTime tarih = DateTime.parse(t["OlusturmaTarihi"].toString());
            if (tarih.isAfter(
                  haftaninBasi.subtract(const Duration(seconds: 1)),
                ) &&
                tarih.isBefore(haftaninSonu.add(const Duration(seconds: 1)))) {
              _barValues[tarih.weekday - 1]++;
            }
          } catch (_) {}
        }
      }
    } else if (_seciliZaman == 'Bu Ay') {
      _barValues = List.filled(4, 0.0, growable: true);
      _barLabels = ['1.Hft', '2.Hft', '3.Hft', '4.Hft'];

      for (var t in _tumTeklifler) {
        if (t["OlusturmaTarihi"] != null) {
          try {
            DateTime tarih = DateTime.parse(t["OlusturmaTarihi"].toString());
            if (tarih.year == bugun.year && tarih.month == bugun.month) {
              int hafta = ((tarih.day - 1) / 7).floor();
              if (hafta > 3) hafta = 3;
              _barValues[hafta]++;
            }
          } catch (_) {}
        }
      }
    } else if (_seciliZaman == 'Bu Yıl') {
      _barValues = List.filled(12, 0.0, growable: true);
      _barLabels = [
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

      for (var t in _tumTeklifler) {
        if (t["OlusturmaTarihi"] != null) {
          try {
            DateTime tarih = DateTime.parse(t["OlusturmaTarihi"].toString());
            if (tarih.year == bugun.year) {
              _barValues[tarih.month - 1]++;
            }
          } catch (_) {}
        }
      }
    }

    double enYuksekDeger = 0;
    for (var val in _barValues) {
      if (val > enYuksekDeger) enYuksekDeger = val;
    }

    _maxY = enYuksekDeger >= 5 ? (enYuksekDeger * 1.2).ceilToDouble() : 5.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 380,
        child: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    final bool isMobil = MediaQuery.of(context).size.width < 1100;

    if (isMobil) {
      return Column(
        children: [
          SizedBox(height: 380, child: _buildCariTrendGrafigi()),
          const SizedBox(height: 24),
          SizedBox(height: 380, child: _buildKazanmaOraniGrafigi()),
        ],
      );
    }

    return SizedBox(
      height: 380,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: _buildCariTrendGrafigi()),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: _buildKazanmaOraniGrafigi()),
        ],
      ),
    );
  }

  Widget _buildCariTrendGrafigi() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _kartDekorasyonu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      "Oluşturulan teklif sayıları",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Bu Hafta', 'Bu Ay', 'Bu Yıl'].map((zaman) {
                    final bool secili = _seciliZaman == zaman;
                    return GestureDetector(
                      onTap: () {
                        if (!secili) {
                          setState(() {
                            _seciliZaman = zaman;
                            _grafikleriHesapla();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: secili
                              ? Colors.indigo.shade600
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: secili
                              ? [
                                  BoxShadow(
                                    color: Colors.indigo.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          zaman,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: secili
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: secili ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          Expanded(child: _buildCustomBarChart()),
        ],
      ),
    );
  }

  Widget _buildCustomBarChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                double stepValue = _maxY - ((_maxY / 5) * index);
                return Row(
                  children: [
                    SizedBox(
                      width: 25,
                      child: Text(
                        stepValue.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.grey.shade200),
                    ),
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_barValues.length, (index) {
                  final double val = _barValues[index];
                  double heightFactor = _maxY > 0 ? (val / _maxY) : 0.0;
                  if (heightFactor > 1.0) heightFactor = 1.0;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          val > 0 ? val.toInt().toString() : "",
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF818CF8),
                                      Color(0xFF4F46E5),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _barLabels[index],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKazanmaOraniGrafigi() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _kartDekorasyonu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kazanma Oranı",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tüm zamanlar",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _dokunulanPastaIndex = -1;
                            return;
                          }
                          _dokunulanPastaIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 4,
                    centerSpaceRadius: 55,
                    sections: _dilimleriOlustur(),
                  ),
                  duration: Duration.zero,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "%${_kabulYuzde.toInt()}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Başarı",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _gostergeItem("Kabul", Colors.green.shade500, _kabulYuzde),
              _gostergeItem("Bekleyen", Colors.orange.shade400, _bekliyorYuzde),
              _gostergeItem("Ret", Colors.red.shade400, _retYuzde),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _dilimleriOlustur() {
    if (_tumTeklifler.isEmpty ||
        (_kabulYuzde <= 0 && _bekliyorYuzde <= 0 && _retYuzde <= 0)) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade100,
          value: 1,
          title: '',
          radius: 25.0,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.green.shade500,
        value: _kabulYuzde,
        title: '',
        radius: _dokunulanPastaIndex == 0 ? 30.0 : 25.0,
      ),
      PieChartSectionData(
        color: Colors.orange.shade400,
        value: _bekliyorYuzde,
        title: '',
        radius: _dokunulanPastaIndex == 1 ? 30.0 : 25.0,
      ),
      PieChartSectionData(
        color: Colors.red.shade400,
        value: _retYuzde,
        title: '',
        radius: _dokunulanPastaIndex == 2 ? 30.0 : 25.0,
      ),
    ];
  }

  Widget _gostergeItem(String baslik, Color renk, double yuzde) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: renk),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "%${yuzde.toInt()}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration _kartDekorasyonu() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
