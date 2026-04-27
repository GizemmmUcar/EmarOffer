import 'package:flutter/material.dart';

class UstProfilBari extends StatelessWidget {
  final String kullaniciAdi;

  const UstProfilBari({super.key, required this.kullaniciAdi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo[100],
            child: const Icon(Icons.person, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          Text(
            kullaniciAdi,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
