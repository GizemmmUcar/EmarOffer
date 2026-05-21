import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Genel Bakış",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = constraints.maxWidth < 800
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 48) / 4;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ModernOzetKarti(
                    width: cardWidth,
                    icon: Icons.inventory_2_outlined,
                    title: "Toplam Ürün",
                    value: _stats["urunSayisi"]?.toString() ?? "0",
                    baseColor: const Color(0xFF3B82F6),
                  ),
                  ModernOzetKarti(
                    width: cardWidth,
                    icon: Icons.people_outline,
                    title: "Müşteriler",
                    value: _stats["musteriSayisi"]?.toString() ?? "0",
                    baseColor: const Color(0xFF10B981),
                  ),
                  ModernOzetKarti(
                    width: cardWidth,
                    icon: Icons.description_outlined,
                    title: "Teklifler",
                    value: _stats["teklifSayisi"]?.toString() ?? "0",
                    baseColor: const Color(0xFFF59E0B),
                  ),
                  ModernOzetKarti(
                    width: cardWidth,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Onaylanan Gelir",
                    value: _stats["toplamGelir"]?.toString() ?? "0.00 ₺",
                    baseColor: const Color(0xFF8B5CF6),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          const GrafikBolumu(),
        ],
      ),
    );
  }
}

class ModernOzetKarti extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color baseColor;
  final double width;

  const ModernOzetKarti({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.baseColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)..withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: baseColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
