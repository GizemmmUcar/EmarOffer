import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/ozet_karti.dart';
import '../widgets/grafik_bolumu.dart';

class DashboardIcerik extends StatefulWidget {
  const DashboardIcerik({super.key});

  @override
  State<DashboardIcerik> createState() => _DashboardIcerikState();
}

class _DashboardIcerikState extends State<DashboardIcerik> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _apiService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ana Ekran",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              OzetKarti(
                icon: Icons.inventory_2,
                title: "Ürünler",
                value: _stats["urunSayisi"]?.toString() ?? "0",
                color: Colors.indigo,
              ),
              OzetKarti(
                icon: Icons.supervisor_account,
                title: "Müşteriler",
                value: _stats["musteriSayisi"]?.toString() ?? "0",
                color: Colors.blue,
              ),
              OzetKarti(
                icon: Icons.description,
                title: "Teklifler",
                value: _stats["teklifSayisi"]?.toString() ?? "0",
                color: Colors.orange,
              ),
              OzetKarti(
                icon: Icons.attach_money,
                title: "Onaylanan Gelir",
                value: _stats["toplamGelir"]?.toString() ?? "0.00 ₺",
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          const GrafikBolumu(),
        ],
      ),
    );
  }
}
