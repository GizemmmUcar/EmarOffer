import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/giris_ekrani.dart';
import '../services/api_service.dart';

class _MenuItem {
  final IconData icon;
  final String title;
  final int index;
  const _MenuItem(this.icon, this.title, this.index);
}

class SolYanMenu extends StatelessWidget {
  final int aktifSayfa;
  final String aktifRol;
  final int? aktifFirmaId;
  final Function(int) onSayfaDegisti;

  const SolYanMenu({
    super.key,
    required this.aktifSayfa,
    required this.aktifRol,
    required this.onSayfaDegisti,
    this.aktifFirmaId,
  });

  @override
  Widget build(BuildContext context) {
    List<_MenuItem> menuItems = [
      const _MenuItem(Icons.grid_view_rounded, "Ana Ekran", 0),
      const _MenuItem(Icons.receipt_long_rounded, "Teklifler", 1),
      const _MenuItem(Icons.people_alt_outlined, "Müşteriler", 2),
      const _MenuItem(Icons.inventory_2_outlined, "Ürünler", 3),
    ];

    if (aktifRol == 'Yönetici') {
      menuItems.add(const _MenuItem(Icons.business_rounded, "Şirketim", 4));
      menuItems.add(
        const _MenuItem(Icons.manage_accounts_outlined, "Çalışanlar", 5),
      );
    }

    menuItems.add(
      const _MenuItem(Icons.picture_as_pdf_outlined, "PDF Şablonları", 6),
    );

    if (aktifFirmaId == 1) {
      menuItems.add(
        const _MenuItem(
          Icons.admin_panel_settings_rounded,
          "Firma Yönetimi",
          7,
        ),
      );
    }

    return Container(
      width: 260,
      decoration: const BoxDecoration(color: Color(0xFF2A364A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Text(
              "MENÜ",
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(item.icon, item.title, item.index);
              },
            ),
          ),

          const Divider(color: Color(0xFF3E4C63), height: 1, thickness: 1),
          _buildCikisYapButonu(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        children: [
          Image.asset(
            'assets/logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Emar Offer",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final bool isSelected = aktifSayfa == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSayfaDegisti(index),
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0xFF3E4C63),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCikisYapButonu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () async {
          await ApiService().cikisYap();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GirisEkrani()),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: const Color(0xFF3E4C63),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFF87171),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                "Çıkış Yap",
                style: GoogleFonts.inter(
                  color: const Color(0xFFF87171),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
