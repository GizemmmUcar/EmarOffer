import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import 'sablon_listesi_ekrani.dart';
import '../widgets/teklif_pdf_sol_panel.dart';

class TeklifPdfOnizlemeEkrani extends StatefulWidget {
  final Map<String, dynamic> teklif;
  const TeklifPdfOnizlemeEkrani({super.key, required this.teklif});

  @override
  State<TeklifPdfOnizlemeEkrani> createState() =>
      _TeklifPdfOnizlemeEkraniState();
}

class _TeklifPdfOnizlemeEkraniState extends State<TeklifPdfOnizlemeEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _seciliDil = 'TR';
  List<dynamic> _sablonlar = [];
  dynamic _seciliSablon;
  Map<String, dynamic> _sirketBilgileri = {};
  List<dynamic> _teklifDetaylari = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    try {
      final sablonlar = await _apiService.getSablonlar();
      final sirket = await _apiService.getSirketBilgileri();
      final detaylar = await _apiService.getTeklifDetaylari(
        widget.teklif["Id"],
      );

      if (mounted) {
        setState(() {
          _sablonlar = sablonlar;
          _sirketBilgileri = sirket ?? {};
          _teklifDetaylari = detaylar;

          if (_sablonlar.isNotEmpty) {
            try {
              _seciliSablon = _sablonlar.firstWhere(
                (s) => s['VarsayilanMi'] == true || s['VarsayilanMi'] == 1,
              );
            } catch (e) {
              _seciliSablon = _sablonlar.first;
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _indir() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );
    try {
      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: widget.teklif,
        urunler: _teklifDetaylari,
        sirket: _sirketBilgileri,
        dil: _seciliDil,
        sablon: _seciliSablon,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "${widget.teklif['TeklifNo'] ?? 'Teklif'}.pdf",
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _yazdir() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );
    try {
      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: widget.teklif,
        urunler: _teklifDetaylari,
        sirket: _sirketBilgileri,
        dil: _seciliDil,
        sablon: _seciliSablon,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: "${widget.teklif['TeklifNo'] ?? 'Teklif'}.pdf",
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _paylas(bool isWhatsapp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );
    try {
      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: widget.teklif,
        urunler: _teklifDetaylari,
        sirket: _sirketBilgileri,
        dil: _seciliDil,
        sablon: _seciliSablon,
      );
      final link = await _apiService.uploadPdfVeLinkAl(
        pdfBytes,
        widget.teklif["TeklifNo"] ?? "Teklif_Belgesi",
      );

      if (!mounted) return;
      Navigator.pop(context);

      final firma = widget.teklif["FirmaAdi"] ?? "Müşterimiz";
      final eposta =
          widget.teklif["Eposta"]?.toString() ??
          widget.teklif["Email"]?.toString() ??
          "";
      final no = widget.teklif["TeklifNo"] ?? "";
      String mesaj = _seciliDil == 'TR'
          ? "Merhaba $firma,\n\n$no numaralı teklif dosyanıza aşağıdaki bağlantıdan ulaşabilirsiniz:\n$link\n\nİyi çalışmalar dileriz."
          : "Hello $firma,\n\nYou can access your quote $no from the link below:\n$link\n\nBest regards.";

      if (isWhatsapp) {
        final Uri url = Uri.parse(
          "https://wa.me/?text=${Uri.encodeComponent(mesaj)}",
        );
        if (await canLaunchUrl(url)) await launchUrl(url);
      } else {
        if (eposta.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bu müşteriye ait e-posta adresi bulunamadı!"),
              backgroundColor: Color(0xFFF59E0B),
            ),
          );
        }
        final String konu = _seciliDil == 'TR'
            ? "$firma - $no Numaralı Teklif"
            : "$firma - Quote No: $no";
        final String gmailUrl =
            "https://mail.google.com/mail/?view=cm&fs=1&to=$eposta&su=${Uri.encodeComponent(konu)}&body=${Uri.encodeComponent(mesaj)}";
        try {
          await launchUrl(
            Uri.parse(gmailUrl),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tarayıcı ayarlarınızı kontrol edin."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }

    final bool isMobilWidth = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: isMobilWidth
          ? Drawer(
              child: SafeArea(
                child: TeklifPdfSolPanel(
                  sablonlar: _sablonlar,
                  seciliSablon: _seciliSablon,
                  onSablonSecildi: (s) {
                    setState(() => _seciliSablon = s);
                    Navigator.pop(context);
                  },
                  seciliDil: _seciliDil,
                  onDilSecildi: (val) {
                    setState(() => _seciliDil = val);
                    Navigator.pop(context);
                  },
                  onSablonYonetimiTiklandi: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SablonListesiEkrani(),
                      ),
                    ).then((_) => _verileriYukle());
                  },
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(
          "${widget.teklif['TeklifNo']} Önizleme",
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: isMobilWidth
            ? [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.palette_outlined, size: 22),
                    tooltip: "Şablon Seç",
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.print_outlined, size: 20),
                  tooltip: "Yazdır",
                  onPressed: _yazdir,
                  color: const Color(0xFF475569),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  tooltip: "İndir",
                  onPressed: _indir,
                  color: const Color(0xFF475569),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                  tooltip: "WhatsApp",
                  onPressed: () => _paylas(true),
                  color: const Color(0xFF10B981),
                ),
                IconButton(
                  icon: const Icon(Icons.mail_outline_rounded, size: 20),
                  tooltip: "E-Posta Gönder",
                  onPressed: () => _paylas(false),
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 4),
              ]
            : [
                TextButton.icon(
                  onPressed: _yazdir,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: Text(
                    "Yazdır",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _indir,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    "İndir",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _paylas(true),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: Text(
                    "WhatsApp",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _paylas(false),
                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                  label: Text(
                    "E-Posta Gönder",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobil = constraints.maxWidth < 850;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isMobil)
                TeklifPdfSolPanel(
                  sablonlar: _sablonlar,
                  seciliSablon: _seciliSablon,
                  onSablonSecildi: (s) => setState(() => _seciliSablon = s),
                  seciliDil: _seciliDil,
                  onDilSecildi: (val) => setState(() => _seciliDil = val),
                  onSablonYonetimiTiklandi: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SablonListesiEkrani(),
                      ),
                    ).then((_) => _verileriYukle());
                  },
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  child: PdfPreview(
                    build: (format) => PdfService.teklifPdfOlustur(
                      teklif: widget.teklif,
                      urunler: _teklifDetaylari,
                      sirket: _sirketBilgileri,
                      dil: _seciliDil,
                      sablon: _seciliSablon,
                    ),
                    useActions: false,
                    maxPageWidth: isMobil ? constraints.maxWidth : 700,
                    padding: EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: isMobil ? 8 : 40,
                    ),
                    pdfFileName: "${widget.teklif['TeklifNo']}.pdf",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
