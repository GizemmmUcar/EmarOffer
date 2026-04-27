import 'package:flutter/material.dart';
import '../screens/giris_ekrani.dart';

class _MenuItem {
  final IconData icon;
  final String title;
  final int index;
  const _MenuItem(this.icon, this.title, this.index);
}

class SolYanMenu extends StatelessWidget {
  final int aktifSayfa;
  final String aktifRol;
  final Function(int) onSayfaDegisti;

  const SolYanMenu({
    super.key,
    required this.aktifSayfa,
    required this.aktifRol,
    required this.onSayfaDegisti,
  });

  @override
  Widget build(BuildContext context) {
    List<_MenuItem> menuItems = [const _MenuItem(Icons.home, "Ana Ekran", 0)];

    if (aktifRol == 'Yönetici') {
      menuItems.add(const _MenuItem(Icons.business, "Şirket", 1));
      menuItems.add(const _MenuItem(Icons.people, "Çalışanlar", 2));
    }

    menuItems.addAll([
      const _MenuItem(Icons.inventory_2, "Ürünler", 3),
      const _MenuItem(Icons.supervisor_account, "Müşteriler", 4),
      const _MenuItem(Icons.description, "Teklifler", 5),
    ]);

    return Container(
      width: 260,
      color: const Color(0xFF374151),
      child: Column(
        children: [
          _buildLogo(),
          const Divider(color: Colors.grey, height: 1),

          ...menuItems.map((item) {
            return _buildMenuItem(item.icon, item.title, item.index);
          }).toList(),

          const Spacer(),

          const Divider(color: Colors.white24, height: 1),

          _buildCikisYapButonu(context),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          Icon(
            Icons.business_center,
            color: Color.fromARGB(255, 227, 227, 225),
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            "Teklif",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final bool isSelected = aktifSayfa == index;
    return InkWell(
      onTap: () => onSayfaDegisti(index),
      child: Container(
        color: isSelected ? Colors.black26 : Colors.transparent,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCikisYapButonu(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GirisEkrani()),
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            const SizedBox(width: 15),
            Text(
              "Çıkış Yap",
              style: TextStyle(
                color: Colors.redAccent.shade100,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
