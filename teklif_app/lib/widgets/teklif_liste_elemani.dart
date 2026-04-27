import 'package:flutter/material.dart';

class TeklifListeElemani extends StatelessWidget {
  final int index;
  final Map<String, dynamic> teklif;
  final VoidCallback onShowDetails;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onPdfExport;

  const TeklifListeElemani({
    super.key,
    required this.index,
    required this.teklif,
    required this.onShowDetails,
    required this.onDelete,
    required this.onStatusChange,
    required this.onEdit,
    required this.onPdfExport,
  });

  @override
  Widget build(BuildContext context) {
    final teklifNo =
        teklif["TeklifNo"]?.toString() ?? teklif["Baslik"]?.toString() ?? "-";
    final firma = teklif["FirmaAdi"]?.toString() ?? "-";
    final toplam = teklif["GenelToplam"]?.toString() ?? "0";
    final durum = teklif["Durum"]?.toString() ?? "Bekliyor";
    final indirimTutari = teklif["ToplamIndirim"]?.toString() ?? "0";
    final olusturan = teklif["OlusturanKisi"]?.toString() ?? "Bilinmiyor";

    final bool isMobil = MediaQuery.of(context).size.width < 800;

    final durumDropdown = PopupMenuButton<String>(
      initialValue: durum,
      tooltip: "Durumu Değiştir",
      onSelected: onStatusChange,
      itemBuilder: (context) => const [
        PopupMenuItem(value: "Bekliyor", child: Text("Bekliyor")),
        PopupMenuItem(value: "Kabul Edildi", child: Text("Kabul Edildi")),
        PopupMenuItem(value: "Reddedildi", child: Text("Reddedildi")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getDurumColor(durum),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              durum,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white),
          ],
        ),
      ),
    );

    final aksiyonButonlari = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(Colors.teal, Icons.info_outline, "Detay", onShowDetails),
        const SizedBox(width: 6),
        _actionButton(
          Colors.deepPurple,
          Icons.picture_as_pdf,
          "PDF Önizle",
          onPdfExport,
        ),
        const SizedBox(width: 6),
        _actionButton(Colors.blue.shade600, Icons.edit, "Düzenle", onEdit),
        const SizedBox(width: 6),
        _actionButton(Colors.red.shade600, Icons.delete, "Sil", onDelete),
      ],
    );

    if (isMobil) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Teklif: $teklifNo",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  durumDropdown,
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.indigo,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firma,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Oluşturan: $olusturan",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Toplam Tutar",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          "$toplam ₺",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (indirimTutari != "0")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "İndirim",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "-$indirimTutari ₺",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: aksiyonButonlari),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _cell((index + 1).toString(), 40, isCenter: true),
          _cell(teklifNo, 140, textColor: Colors.blue.shade700),
          _cell(firma, 220),
          _cell(olusturan, 130, textColor: Colors.grey.shade600),
          _cell("$toplam ₺", 120, isBold: true),
          _cell(
            indirimTutari != "0" ? "-$indirimTutari ₺" : "-",
            90,
            isCenter: true,
            textColor: Colors.red.shade600,
          ),
          SizedBox(
            width: 150,
            child: Align(alignment: Alignment.centerLeft, child: durumDropdown),
          ),
          SizedBox(width: 160, child: aksiyonButonlari),
        ],
      ),
    );
  }

  Widget _cell(
    String text,
    double width, {
    bool isCenter = false,
    Color? textColor,
    bool isBold = false,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          textAlign: isCenter ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: 13,
            color: textColor ?? Colors.grey.shade800,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _actionButton(
    Color bgColor,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Color _getDurumColor(String durum) {
    if (durum == "Kabul Edildi" || durum == "Onaylandı") {
      return Colors.green.shade600;
    }
    if (durum == "Reddedildi") return Colors.red.shade600;
    return Colors.orange.shade500;
  }
}
