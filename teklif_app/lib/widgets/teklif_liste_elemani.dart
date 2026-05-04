import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String _tarihFormatla(String? isoTarih) {
    if (isoTarih == null || isoTarih.isEmpty) return "-";
    try {
      final tarih = DateTime.parse(isoTarih);
      return DateFormat('dd.MM.yyyy').format(tarih);
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final teklifNo =
        teklif["TeklifNo"]?.toString() ?? teklif["Baslik"]?.toString() ?? "-";
    final firma = teklif["FirmaAdi"]?.toString() ?? "-";
    final yetkili = teklif["YetkiliKisi"]?.toString() ?? "";
    final doviz = teklif["Doviz"]?.toString() ?? "TRY";
    final toplam = teklif["GenelToplam"]?.toString() ?? "0";
    final durum = teklif["Durum"]?.toString() ?? "Bekliyor";
    final indirimTutari = teklif["ToplamIndirim"]?.toString() ?? "0";
    final olusturan = teklif["OlusturanKisi"]?.toString() ?? "Bilinmiyor";
    final olusturmaTarihi = _tarihFormatla(
      teklif["OlusturmaTarihi"]?.toString(),
    );
    final gecerlilikTarihi = _tarihFormatla(
      teklif["GecerlilikTarihi"]?.toString(),
    );

    bool sureDoldu = false;
    if (teklif["GecerlilikTarihi"] != null && durum == "Bekliyor") {
      try {
        final bitisTarihi = DateTime.parse(teklif["GecerlilikTarihi"]);
        if (DateTime.now().isAfter(bitisTarihi.add(const Duration(days: 1)))) {
          sureDoldu = true;
        }
      } catch (_) {}
    }

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
                        if (yetkili.isNotEmpty)
                          Text(
                            " $yetkili",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              olusturmaTarihi,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timer,
                              size: 12,
                              color: sureDoldu ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sureDoldu
                                  ? "$gecerlilikTarihi (Süresi Doldu)"
                                  : gecerlilikTarihi,
                              style: TextStyle(
                                color: sureDoldu
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
                          "$toplam $doviz",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (indirimTutari != "0" && indirimTutari != "0.00")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "İndirim",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "-$indirimTutari $doviz",
                            style: const TextStyle(
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
          SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    firma,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (yetkili.isNotEmpty)
                    Text(
                      " $yetkili",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          _cell(olusturan, 110, textColor: Colors.grey.shade600),
          SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 11,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        olusturmaTarihi,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        sureDoldu ? Icons.warning_amber_rounded : Icons.timer,
                        size: 11,
                        color: sureDoldu ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gecerlilikTarihi,
                        style: TextStyle(
                          fontSize: 11,
                          color: sureDoldu ? Colors.red : Colors.grey.shade500,
                          fontWeight: sureDoldu
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _cell("$toplam $doviz", 130, isBold: true),
          _cell(
            indirimTutari != "0" && indirimTutari != "0.00"
                ? "-$indirimTutari $doviz"
                : "-",
            90,
            isCenter: true,
            textColor: Colors.red.shade600,
          ),
          SizedBox(
            width: 140,
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
    if (durum == "Kabul Edildi" || durum == "Onaylandı")
      return Colors.green.shade600;
    if (durum == "Reddedildi") return Colors.red.shade600;
    return Colors.orange.shade500;
  }
}
