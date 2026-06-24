const express = require("express");
const cors = require("cors");
const { connectDB, sql, config } = require("./db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(cors());
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

connectDB();

// Güvenlik duvarı

const authMiddleware = (req, res, next) => {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) return res.status(401).send("Erişim reddedildi. Token eksik.");

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "emar_offer_super_gizli_anahtar_2026!",
    );
    req.user = decoded;
    next();
  } catch (err) {
    res.status(403).send("Geçersiz veya süresi dolmuş token.");
  }
};

app.get("/", (req, res) => {
  res.send("Emar Offer API başarıyla çalışıyor! (Multi-tenant Mimarisi Aktif)");
});

// Giriş

app.post("/kullanicilar/login", async (req, res) => {
  try {
    const { firmaKodu, kullaniciBilgisi, sifre } = req.body;

    if (!firmaKodu || !kullaniciBilgisi || !sifre)
      return res
        .status(400)
        .send("Firma kodu, Kullanıcı adı ve şifre zorunludur.");

    const firmaReq = new sql.Request();
    firmaReq.input("firmaKodu", sql.NVarChar(50), firmaKodu);
    const firmaRes = await firmaReq.query(
      "SELECT Id, AktifMi FROM Firmalar WHERE FirmaKodu = @firmaKodu",
    );

    if (firmaRes.recordset.length === 0)
      return res.status(404).send("Firma bulunamadı.");
    const firma = firmaRes.recordset[0];
    if (!firma.AktifMi)
      return res.status(403).send("Firmanızın hesabı askıya alınmış.");

    const userReq = new sql.Request();
    userReq.input("kullaniciBilgisi", sql.VarChar(100), kullaniciBilgisi);
    userReq.input("firmaId", sql.Int, firma.Id);

    const result = await userReq.query(`
      SELECT u.Id, u.FirmaId, u.AdSoyad, u.Eposta, u.Sifre, u.RolId, r.RolAdi 
      FROM Kullanicilar u INNER JOIN Roller r ON u.RolId = r.Id
      WHERE (u.Eposta = @kullaniciBilgisi OR u.AdSoyad = @kullaniciBilgisi) 
      AND u.FirmaId = @firmaId
    `);

    if (result.recordset.length === 0)
      return res
        .status(401)
        .send("Bu firmaya ait böyle bir kullanıcı bulunamadı.");

    const user = result.recordset[0];

    const isMatch = await bcrypt.compare(sifre, user.Sifre);
    if (!isMatch) return res.status(401).send("Hatalı şifre.");

    const ilkGiris = sifre === "123456";

    const token = jwt.sign(
      { id: user.Id, rolId: user.RolId, firmaId: firma.Id },
      process.env.JWT_SECRET || "emar_offer_super_gizli_anahtar_2026!",
      { expiresIn: "12h" },
    );

    delete user.Sifre;
    res.json({ token, user, ilkGiris, mesaj: "Giriş başarılı." });
  } catch (err) {
    res.status(500).send("Giriş hatası.");
  }
});

app.post("/kullanicilar/sifre-degistir", authMiddleware, async (req, res) => {
  try {
    const { yeniSifre } = req.body;
    if (!yeniSifre) return res.status(400).send("Yeni şifre gerekli.");

    const hashedSifre = await bcrypt.hash(yeniSifre, 10);
    const request = new sql.Request();
    request.input("id", sql.Int, req.user.id);
    request.input("firmaId", sql.Int, req.user.firmaId);
    request.input("sifre", sql.VarChar(255), hashedSifre);

    await request.query(
      "UPDATE Kullanicilar SET Sifre = @sifre WHERE Id = @id AND FirmaId = @firmaId",
    );
    res.json({ mesaj: "Şifre başarıyla güncellendi." });
  } catch (err) {
    res.status(500).send("Şifre güncellenirken hata oluştu.");
  }
});

// Müşteriler

app.get("/musteriler", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    const result = await request.query(
      "SELECT * FROM Musteriler WHERE FirmaId = @FirmaId ORDER BY FirmaAdi ASC",
    );
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Veriler çekilirken bir hata oluştu.");
  }
});

app.post("/musteriler", authMiddleware, async (req, res) => {
  try {
    const {
      firmaAdi,
      yetkiliKisi,
      telefon,
      eposta,
      vergiDairesi,
      vergiNo,
      adres,
      ulke,
      sehir,
      ilce,
    } = req.body;
    if (!firmaAdi || !telefon)
      return res.status(400).send("Firma adı ve telefon zorunludur.");

    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("firmaAdi", sql.NVarChar(150), firmaAdi);
    request.input("yetkiliKisi", sql.NVarChar(100), yetkiliKisi || "");
    request.input("telefon", sql.VarChar(20), telefon);
    request.input("eposta", sql.VarChar(100), eposta || "");
    request.input("vergiDairesi", sql.NVarChar(50), vergiDairesi || "");
    request.input("vergiNo", sql.VarChar(50), vergiNo || "");
    request.input("adres", sql.NVarChar(sql.MAX), adres || "");
    request.input("ulke", sql.NVarChar(100), ulke || "");
    request.input("sehir", sql.NVarChar(100), sehir || "");
    request.input("ilce", sql.NVarChar(100), ilce || "");

    await request.query(`
      INSERT INTO Musteriler (FirmaId, FirmaAdi, YetkiliKisi, Telefon, Eposta, VergiDairesi, VergiNo, Adres, Ulke, Sehir, Ilce)
      VALUES (@FirmaId, @firmaAdi, @yetkiliKisi, @telefon, @eposta, @vergiDairesi, @vergiNo, @adres, @ulke, @sehir, @ilce)
    `);
    res.status(201).json({ mesaj: "Müşteri başarıyla eklendi." });
  } catch (err) {
    res.status(500).send("Müşteri eklenirken hata oluştu.");
  }
});

app.put("/musteriler/:id", authMiddleware, async (req, res) => {
  try {
    const {
      firmaAdi,
      yetkiliKisi,
      telefon,
      eposta,
      vergiDairesi,
      vergiNo,
      adres,
      ulke,
      sehir,
      ilce,
    } = req.body;
    const request = new sql.Request();

    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("firmaAdi", sql.NVarChar(150), firmaAdi);
    request.input("yetkiliKisi", sql.NVarChar(100), yetkiliKisi || "");
    request.input("telefon", sql.VarChar(20), telefon);
    request.input("eposta", sql.VarChar(100), eposta || "");
    request.input("vergiDairesi", sql.NVarChar(50), vergiDairesi || "");
    request.input("vergiNo", sql.VarChar(50), vergiNo || "");
    request.input("adres", sql.NVarChar(sql.MAX), adres || "");
    request.input("ulke", sql.NVarChar(100), ulke || "");
    request.input("sehir", sql.NVarChar(100), sehir || "");
    request.input("ilce", sql.NVarChar(100), ilce || "");

    await request.query(`
      UPDATE Musteriler SET 
        FirmaAdi = @firmaAdi, YetkiliKisi = @yetkiliKisi, Telefon = @telefon, 
        Eposta = @eposta, VergiDairesi = @vergiDairesi, VergiNo = @vergiNo, Adres = @adres,
        Ulke = @ulke, Sehir = @sehir, Ilce = @ilce
      WHERE Id = @id AND FirmaId = @FirmaId
    `);
    res.json({ mesaj: "Müşteri başarıyla güncellendi." });
  } catch (err) {
    res.status(500).send("Müşteri güncellenirken hata oluştu.");
  }
});

app.delete("/musteriler/:id", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    await request.query(
      "DELETE FROM Musteriler WHERE Id = @id AND FirmaId = @FirmaId",
    );
    res.json({ mesaj: "Müşteri başarıyla silindi." });
  } catch (err) {
    if (err.number === 547)
      return res
        .status(400)
        .send("Bu müşteriye ait teklifler olduğu için silinemez.");
    res.status(500).send("Müşteri silinirken hata oluştu.");
  }
});

// Ürünler

app.get("/urunler", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    const result = await request.query(
      "SELECT * FROM Urunler WHERE FirmaId = @FirmaId ORDER BY UrunAdi ASC",
    );
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Veriler çekilirken bir hata oluştu.");
  }
});

app.post("/urunler", authMiddleware, async (req, res) => {
  try {
    const {
      urunAdi,
      urunKodu,
      birimFiyati,
      paraBirimi,
      kdvOrani,
      aciklama,
      urunGorsel,
      kategori,
      altKategori,
    } = req.body;
    if (!urunAdi || birimFiyati == null)
      return res.status(400).send("Ürün adı ve fiyat zorunludur.");

    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("urunAdi", sql.NVarChar(150), urunAdi);
    request.input("urunKodu", sql.VarChar(50), urunKodu || "");
    request.input("birimFiyati", sql.Decimal(18, 2), birimFiyati);
    request.input("paraBirimi", sql.VarChar(10), paraBirimi || "TRY");
    request.input("kdvOrani", sql.Int, kdvOrani || 18);
    request.input("aciklama", sql.NVarChar(sql.MAX), aciklama || "");
    request.input("urunGorsel", sql.NVarChar(sql.MAX), urunGorsel || "");
    request.input("kategori", sql.NVarChar(100), kategori || "");
    request.input("altKategori", sql.NVarChar(100), altKategori || "");

    await request.query(`
      INSERT INTO Urunler (FirmaId, UrunAdi, UrunKodu, BirimFiyati, ParaBirimi, KdvOrani, Aciklama, UrunGorsel, Kategori, AltKategori) 
      VALUES (@FirmaId, @urunAdi, @urunKodu, @birimFiyati, @paraBirimi, @kdvOrani, @aciklama, @urunGorsel, @kategori, @altKategori)
    `);
    res.status(201).json({ mesaj: "Ürün başarıyla eklendi." });
  } catch (err) {
    res.status(500).send("Ürün eklenirken hata oluştu.");
  }
});

app.put("/urunler/:id", authMiddleware, async (req, res) => {
  try {
    const {
      urunAdi,
      urunKodu,
      birimFiyati,
      paraBirimi,
      kdvOrani,
      aciklama,
      urunGorsel,
      kategori,
      altKategori,
    } = req.body;
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);

    request.input("urunAdi", sql.NVarChar(150), urunAdi);
    request.input("urunKodu", sql.VarChar(50), urunKodu || "");
    request.input("birimFiyati", sql.Decimal(18, 2), birimFiyati);
    request.input("paraBirimi", sql.VarChar(10), paraBirimi || "TRY");
    request.input("kdvOrani", sql.Int, kdvOrani || 18);
    request.input("aciklama", sql.NVarChar(sql.MAX), aciklama || "");
    request.input("urunGorsel", sql.NVarChar(sql.MAX), urunGorsel || "");
    request.input("kategori", sql.NVarChar(100), kategori || "");
    request.input("altKategori", sql.NVarChar(100), altKategori || "");

    await request.query(`
      UPDATE Urunler SET 
        UrunAdi = @urunAdi, UrunKodu = @urunKodu, BirimFiyati = @birimFiyati, 
        ParaBirimi = @paraBirimi, KdvOrani = @kdvOrani, Aciklama = @aciklama, UrunGorsel = @urunGorsel,
        Kategori = @kategori, AltKategori = @altKategori
      WHERE Id = @id AND FirmaId = @FirmaId
    `);
    res.json({ mesaj: "Ürün güncellendi." });
  } catch (err) {
    res.status(500).send("Ürün güncellenirken hata oluştu.");
  }
});

app.put("/urunler/:id", authMiddleware, async (req, res) => {
  try {
    const {
      urunAdi,
      urunKodu,
      birimFiyati,
      paraBirimi,
      kdvOrani,
      aciklama,
      urunGorsel,
      kategori,
      altKategori,
    } = req.body;
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);

    request.input("urunAdi", sql.NVarChar(150), urunAdi);
    request.input("urunKodu", sql.VarChar(50), urunKodu || "");
    request.input("birimFiyati", sql.Decimal(18, 2), birimFiyati);
    request.input("paraBirimi", sql.VarChar(10), paraBirimi || "TRY");
    request.input("kdvOrani", sql.Int, kdvOrani || 18);
    request.input("aciklama", sql.NVarChar(sql.MAX), aciklama || "");
    request.input("urunGorsel", sql.NVarChar(sql.MAX), urunGorsel || "");
    request.input("kategori", sql.NVarChar(100), kategori || "");
    request.input("altKategori", sql.NVarChar(100), altKategori || "");

    await request.query(`
      UPDATE Urunler SET 
        UrunAdi = @urunAdi, UrunKodu = @urunKodu, BirimFiyati = @birimFiyati, 
        ParaBirimi = @paraBirimi, KdvOrani = @kdvOrani, Aciklama = @aciklama, UrunGorsel = @urunGorsel,
        Kategori = @kategori, AltKategori = @altKategori
      WHERE Id = @id AND FirmaId = @FirmaId
    `);
    res.json({ mesaj: "Ürün güncellendi." });
  } catch (err) {
    res.status(500).send("Ürün güncellenirken hata oluştu.");
  }
});

app.delete("/urunler/:id", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    await request.query(
      "DELETE FROM Urunler WHERE Id = @id AND FirmaId = @FirmaId",
    );
    res.json({ mesaj: "Ürün silindi." });
  } catch (err) {
    if (err.number === 547)
      return res.status(400).send("Bu ürün kullanıldığı için silinemez.");
    res.status(500).send("Ürün silinirken hata oluştu.");
  }
});

// Teklifler

app.get("/teklifler", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);

    const result = await request.query(`
      SELECT 
        t.*, 
        m.FirmaAdi, m.YetkiliKisi, m.Telefon, m.Eposta, m.Adres, m.Sehir, m.Ilce, m.Ulke,  
        k.AdSoyad as OlusturanKisi,
        DATEDIFF(day, t.OlusturmaTarihi, t.GecerlilikTarihi) AS GecerlilikGunu
      FROM Teklifler t 
      INNER JOIN Musteriler m ON t.MusteriId = m.Id
      LEFT JOIN Kullanicilar k ON t.KullaniciId = k.Id
      WHERE t.FirmaId = @FirmaId
      ORDER BY t.OlusturmaTarihi DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Teklifler getirilirken hata oluştu.");
  }
});

app.get("/teklifler/:id/detay", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("teklifId", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);

    const result = await request.query(`
      SELECT 
        td.Id, td.TeklifId, td.UrunId, u.UrunAdi, u.UrunGorsel, 
        td.Miktar, td.BirimFiyat, td.IskontoYuzdesi, td.KdvOrani
      FROM TeklifDetaylari td 
      INNER JOIN Urunler u ON td.UrunId = u.Id
      INNER JOIN Teklifler t ON td.TeklifId = t.Id
      WHERE td.TeklifId = @teklifId AND t.FirmaId = @FirmaId
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Teklif detayları getirilirken hata oluştu.");
  }
});

app.post("/teklifler", authMiddleware, async (req, res) => {
  try {
    const {
      teklifNo,
      kullaniciId,
      musteriId,
      yeniFirmaAdi,
      araToplam,
      toplamIndirim,
      genelToplam,
      genelNot,
      gecerlilikGunu,
      urunler,
      doviz,
      odemeTuru,
    } = req.body;
    let finalMusteriId = musteriId;

    if (yeniFirmaAdi) {
      const musteriReq = new sql.Request();
      musteriReq.input("FirmaId", sql.Int, req.user.firmaId);
      musteriReq.input("firmaAdi", sql.NVarChar(150), yeniFirmaAdi);
      musteriReq.input(
        "yetkiliKisi",
        sql.NVarChar(100),
        req.body.yeniYetkiliKisi || "",
      );
      musteriReq.input(
        "telefon",
        sql.VarChar(20),
        req.body.yeniTelefon || "Belirtilmedi",
      );
      musteriReq.input("eposta", sql.VarChar(100), req.body.yeniEposta || "");
      musteriReq.input(
        "vergiDairesi",
        sql.NVarChar(50),
        req.body.yeniVergiDairesi || "",
      );
      musteriReq.input("vergiNo", sql.VarChar(50), req.body.yeniVergiNo || "");
      musteriReq.input(
        "adres",
        sql.NVarChar(sql.MAX),
        req.body.yeniAdres || "",
      );

      const musteriRes = await musteriReq.query(`
        INSERT INTO Musteriler (FirmaId, FirmaAdi, YetkiliKisi, Telefon, Eposta, VergiDairesi, VergiNo, Adres) 
        OUTPUT INSERTED.Id 
        VALUES (@FirmaId, @firmaAdi, @yetkiliKisi, @telefon, @eposta, @vergiDairesi, @vergiNo, @adres)
      `);
      finalMusteriId = musteriRes.recordset[0].Id;
    }

    const transaction = new sql.Transaction();
    await transaction.begin();

    try {
      const teklifReq = new sql.Request(transaction);
      teklifReq.input("FirmaId", sql.Int, req.user.firmaId);
      teklifReq.input("teklifNo", sql.VarChar(20), teklifNo);
      teklifReq.input("kullaniciId", sql.Int, kullaniciId);
      teklifReq.input("musteriId", sql.Int, finalMusteriId);
      teklifReq.input("araToplam", sql.Decimal(18, 2), araToplam);
      teklifReq.input("toplamIndirim", sql.Decimal(18, 2), toplamIndirim);
      teklifReq.input("genelToplam", sql.Decimal(18, 2), genelToplam);
      teklifReq.input("genelNot", sql.NVarChar(sql.MAX), genelNot || "");
      teklifReq.input("gecerlilikGunu", sql.Int, gecerlilikGunu || 7);
      teklifReq.input("doviz", sql.VarChar(10), doviz || "TRY");
      teklifReq.input(
        "odemeTuru",
        sql.VarChar(20),
        odemeTuru || "Belirtilmedi",
      );

      const teklifRes = await teklifReq.query(`
        INSERT INTO Teklifler (FirmaId, TeklifNo, KullaniciId, MusteriId, OlusturmaTarihi, GecerlilikTarihi, AraToplam, ToplamIndirim, GenelToplam, Durum, GenelNot, Doviz, OdemeTuru)
        OUTPUT INSERTED.Id
        VALUES (@FirmaId, @teklifNo, @kullaniciId, @musteriId, GETDATE(), DATEADD(day, @gecerlilikGunu, GETDATE()), @araToplam, @toplamIndirim, @genelToplam, 'Bekliyor', @genelNot, @doviz, @odemeTuru)
      `);

      const yeniTeklifId = teklifRes.recordset[0].Id;

      if (urunler && urunler.length > 0) {
        for (const urun of urunler) {
          const detayReq = new sql.Request(transaction);
          detayReq.input("teklifId", sql.Int, yeniTeklifId);
          detayReq.input("urunId", sql.Int, urun.urunId);
          detayReq.input("miktar", sql.Decimal(18, 2), urun.miktar);
          detayReq.input("birimFiyat", sql.Decimal(18, 2), urun.birimFiyat);
          detayReq.input(
            "iskontoYuzdesi",
            sql.Decimal(5, 2),
            urun.iskontoYuzdesi || 0.0,
          );
          detayReq.input("kdvOrani", sql.Decimal(5, 2), urun.kdvOrani || 0.0);

          await detayReq.query(`
            INSERT INTO TeklifDetaylari (TeklifId, UrunId, Miktar, BirimFiyat, IskontoYuzdesi, KdvOrani)
            VALUES (@teklifId, @urunId, @miktar, @birimFiyat, @iskontoYuzdesi, @kdvOrani)
          `);
        }
      }

      await transaction.commit();
      res.status(201).json({ mesaj: "Teklif başarıyla kaydedildi." });
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  } catch (err) {
    res.status(500).send("Teklif kaydedilirken hata oluştu.");
  }
});

app.post("/teklifler/:id/guncelle", authMiddleware, async (req, res) => {
  try {
    const {
      teklifNo,
      musteriId,
      araToplam,
      toplamIndirim,
      genelToplam,
      genelNot,
      gecerlilikGunu,
      urunler,
      doviz,
      odemeTuru,
    } = req.body;
    const teklifId = req.params.id;

    const checkReq = new sql.Request();
    checkReq.input("id", sql.Int, teklifId);
    checkReq.input("FirmaId", sql.Int, req.user.firmaId);
    const checkRes = await checkReq.query(
      "SELECT Id FROM Teklifler WHERE Id = @id AND FirmaId = @FirmaId",
    );
    if (checkRes.recordset.length === 0)
      return res.status(403).send("Bu işlem için yetkiniz yok.");

    const transaction = new sql.Transaction();
    await transaction.begin();

    try {
      const updateHeaderReq = new sql.Request(transaction);
      updateHeaderReq.input("teklifId", sql.Int, teklifId);
      updateHeaderReq.input("teklifNo", sql.VarChar(20), teklifNo);
      updateHeaderReq.input("musteriId", sql.Int, musteriId);
      updateHeaderReq.input("araToplam", sql.Decimal(18, 2), araToplam);
      updateHeaderReq.input("toplamIndirim", sql.Decimal(18, 2), toplamIndirim);
      updateHeaderReq.input("genelToplam", sql.Decimal(18, 2), genelToplam);
      updateHeaderReq.input("genelNot", sql.NVarChar(sql.MAX), genelNot || "");
      updateHeaderReq.input("gecerlilikGunu", sql.Int, gecerlilikGunu || 7);
      updateHeaderReq.input("doviz", sql.VarChar(10), doviz || "TRY");
      updateHeaderReq.input(
        "odemeTuru",
        sql.VarChar(20),
        odemeTuru || "Belirtilmedi",
      );

      await updateHeaderReq.query(`
        UPDATE Teklifler SET 
          TeklifNo = @teklifNo, MusteriId = @musteriId, AraToplam = @araToplam, 
          ToplamIndirim = @toplamIndirim, GenelToplam = @genelToplam, GenelNot = @genelNot, 
          GecerlilikTarihi = DATEADD(day, @gecerlilikGunu, OlusturmaTarihi), Doviz = @doviz, OdemeTuru = @odemeTuru 
        WHERE Id = @teklifId
      `);

      const deleteDetailsReq = new sql.Request(transaction);
      deleteDetailsReq.input("teklifId", sql.Int, teklifId);
      await deleteDetailsReq.query(
        "DELETE FROM TeklifDetaylari WHERE TeklifId = @teklifId",
      );

      if (urunler && urunler.length > 0) {
        for (const urun of urunler) {
          const detayReq = new sql.Request(transaction);
          detayReq.input("teklifId", sql.Int, teklifId);
          detayReq.input("urunId", sql.Int, urun.urunId);
          detayReq.input("miktar", sql.Decimal(18, 2), urun.miktar);
          detayReq.input("birimFiyat", sql.Decimal(18, 2), urun.birimFiyat);
          detayReq.input(
            "iskontoYuzdesi",
            sql.Decimal(5, 2),
            urun.iskontoYuzdesi || 0.0,
          );
          detayReq.input("kdvOrani", sql.Decimal(5, 2), urun.kdvOrani || 0.0);

          await detayReq.query(`
            INSERT INTO TeklifDetaylari (TeklifId, UrunId, Miktar, BirimFiyat, IskontoYuzdesi, KdvOrani)
            VALUES (@teklifId, @urunId, @miktar, @birimFiyat, @iskontoYuzdesi, @kdvOrani)
          `);
        }
      }

      await transaction.commit();
      res.json({ mesaj: "Teklif başarıyla güncellendi." });
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  } catch (err) {
    res.status(500).send("Teklif güncellenirken hata oluştu.");
  }
});

app.put("/teklifler/:id/durum", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("durum", sql.NVarChar(50), req.body.durum);

    await request.query(
      "UPDATE Teklifler SET Durum = @durum WHERE Id = @id AND FirmaId = @FirmaId",
    );
    res.json({ mesaj: "Durum güncellendi." });
  } catch (err) {
    res.status(500).send("Durum güncellenirken hata oluştu.");
  }
});

app.delete("/teklifler/:id", authMiddleware, async (req, res) => {
  try {
    const checkReq = new sql.Request();
    checkReq.input("id", sql.Int, req.params.id);
    checkReq.input("FirmaId", sql.Int, req.user.firmaId);
    const checkRes = await checkReq.query(
      "SELECT Id FROM Teklifler WHERE Id = @id AND FirmaId = @FirmaId",
    );

    if (checkRes.recordset.length === 0)
      return res.status(403).send("Bu işlem için yetkiniz yok.");

    const transaction = new sql.Transaction();
    await transaction.begin();
    try {
      const reqDetails = new sql.Request(transaction);
      reqDetails.input("id", sql.Int, req.params.id);
      await reqDetails.query(
        "DELETE FROM TeklifDetaylari WHERE TeklifId = @id",
      );

      const reqHeader = new sql.Request(transaction);
      reqHeader.input("id", sql.Int, req.params.id);
      await reqHeader.query("DELETE FROM Teklifler WHERE Id = @id");

      await transaction.commit();
      res.json({ mesaj: "Teklif başarıyla silindi." });
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  } catch (err) {
    res.status(500).send("Teklif silinirken hata oluştu.");
  }
});

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = "./uploads";
    if (!fs.existsSync(dir)) fs.mkdirSync(dir);
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + "-" + file.originalname);
  },
});
const upload = multer({ storage: storage });

app.post(
  "/teklifler/pdf-yukle",
  authMiddleware,
  upload.single("pdf"),
  (req, res) => {
    try {
      if (!req.file) return res.status(400).send("Dosya yüklenemedi.");
      const fileUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;
      res.status(200).json({ url: fileUrl });
    } catch (err) {
      res.status(500).send("PDF yüklenirken hata oluştu.");
    }
  },
);

// Dashbord ve İstatistikler

app.get("/dashboard-stats", authMiddleware, async (req, res) => {
  try {
    const r = new sql.Request();
    r.input("FirmaId", sql.Int, req.user.firmaId);

    const urunler = await r.query(
      "SELECT COUNT(*) as Toplam FROM Urunler WHERE FirmaId = @FirmaId",
    );
    const musteriler = await r.query(
      "SELECT COUNT(*) as Toplam FROM Musteriler WHERE FirmaId = @FirmaId",
    );
    const teklifler = await r.query(`
      SELECT COUNT(*) as Toplam FROM Teklifler 
      WHERE Durum != 'Silindi' AND Durum != 'Taslak' AND FirmaId = @FirmaId
    `);
    const gelir = await r.query(
      "SELECT SUM(GenelToplam) as ToplamGelir FROM Teklifler WHERE Durum = 'Kabul Edildi' AND FirmaId = @FirmaId",
    );

    const grafik = await r.query(`
      SELECT CAST(OlusturmaTarihi AS DATE) as Tarih, COUNT(*) as Sayi 
      FROM Teklifler 
      WHERE OlusturmaTarihi >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) AND FirmaId = @FirmaId
      GROUP BY CAST(OlusturmaTarihi AS DATE)
    `);

    const son7Gun = [];
    const gunAdlari = ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"];

    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const tarihStr = d.toISOString().split("T")[0];
      const dataRow = grafik.recordset.find(
        (r) => new Date(r.Tarih).toISOString().split("T")[0] === tarihStr,
      );
      son7Gun.push({
        tarih: tarihStr,
        gunAdi: gunAdlari[d.getDay()],
        sayi: dataRow ? dataRow.Sayi : 0,
      });
    }

    res.json({
      urunSayisi: urunler.recordset[0].Toplam || 0,
      musteriSayisi: musteriler.recordset[0].Toplam || 0,
      teklifSayisi: teklifler.recordset[0].Toplam || 0,
      toplamGelir: gelir.recordset[0].ToplamGelir
        ? gelir.recordset[0].ToplamGelir.toFixed(2) + " ₺"
        : "0.00 ₺",
      grafikVerisi: son7Gun,
    });
  } catch (err) {
    res.status(500).send("İstatistikler getirilemedi.");
  }
});

// Şirket ayarları

app.get("/sirket", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    const result = await request.query(
      "SELECT * FROM SirketAyarlari WHERE FirmaId = @FirmaId",
    );
    res.json(result.recordset.length > 0 ? result.recordset[0] : {});
  } catch (err) {
    res.status(500).send("Şirket ayarları çekilirken hata oluştu.");
  }
});

app.put("/api/sirket", authMiddleware, async (req, res) => {
  try {
    const {
      SirketAdi,
      Yetkili,
      Telefon,
      Eposta,
      WebSitesi,
      VergiDairesi,
      VergiNo,
      BankaBilgileri,
      Adres,
      Logo,
    } = req.body;
    const request = new sql.Request();

    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("SirketAdi", sql.NVarChar, SirketAdi || "");
    request.input("Yetkili", sql.NVarChar, Yetkili || "");
    request.input("Telefon", sql.NVarChar, Telefon || "");
    request.input("Eposta", sql.NVarChar, Eposta || "");
    request.input("WebSitesi", sql.NVarChar, WebSitesi || "");
    request.input("VergiDairesi", sql.NVarChar, VergiDairesi || "");
    request.input("VergiNo", sql.NVarChar, VergiNo || "");
    request.input("BankaBilgileri", sql.NVarChar, BankaBilgileri || "");
    request.input("Adres", sql.NVarChar, Adres || "");
    request.input("Logo", sql.NVarChar(sql.MAX), Logo || "");

    await request.query(`
      UPDATE SirketAyarlari 
      SET SirketAdi = @SirketAdi, Yetkili = @Yetkili, Telefon = @Telefon, Eposta = @Eposta, 
          WebSitesi = @WebSitesi, VergiDairesi = @VergiDairesi, VergiNo = @VergiNo, 
          BankaBilgileri = @BankaBilgileri, Adres = @Adres, Logo = @Logo 
      WHERE FirmaId = @FirmaId
    `);

    res
      .status(200)
      .json({ message: "Şirket bilgileri başarıyla güncellendi!" });
  } catch (error) {
    res.status(500).json({ error: "Sunucu hatası: " + error.message });
  }
});

// Kullanıcılar ve Roller

app.get("/roller", authMiddleware, async (req, res) => {
  try {
    const result = await sql.query("SELECT * FROM Roller");
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Roller çekilemedi.");
  }
});

app.get("/kullanicilar", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    const result = await request.query(`
      SELECT u.Id, u.AdSoyad, u.Eposta, u.Sifre, u.RolId, r.RolAdi 
      FROM Kullanicilar u INNER JOIN Roller r ON u.RolId = r.Id
      WHERE u.FirmaId = @FirmaId
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Kullanıcılar getirilemedi.");
  }
});

app.post("/kullanicilar", authMiddleware, async (req, res) => {
  try {
    const { adSoyad, eposta, sifre, rolId } = req.body;
    const hashedSifre = await bcrypt.hash(sifre, 10);
    const request = new sql.Request();

    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("adSoyad", sql.NVarChar(100), adSoyad);
    request.input("eposta", sql.VarChar(100), eposta);
    request.input("sifre", sql.VarChar(255), hashedSifre);
    request.input("rolId", sql.Int, rolId);

    await request.query(`
      INSERT INTO Kullanicilar (FirmaId, AdSoyad, Eposta, Sifre, RolId) 
      VALUES (@FirmaId, @adSoyad, @eposta, @sifre, @rolId)
    `);
    res.status(201).json({ mesaj: "Kullanıcı eklendi" });
  } catch (err) {
    res.status(500).send("Kullanıcı eklenirken hata.");
  }
});

app.put("/kullanicilar/:id", authMiddleware, async (req, res) => {
  try {
    const { adSoyad, eposta, sifre, rolId } = req.body;
    const request = new sql.Request();

    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("adSoyad", sql.NVarChar(100), adSoyad);
    request.input("eposta", sql.VarChar(100), eposta);
    request.input("rolId", sql.Int, rolId);

    let query = "";
    if (sifre && sifre.trim() !== "") {
      const hashedSifre = await bcrypt.hash(sifre, 10);
      request.input("sifre", sql.VarChar(255), hashedSifre);
      query = `UPDATE Kullanicilar SET AdSoyad = @adSoyad, Eposta = @eposta, Sifre = @sifre, RolId = @rolId WHERE Id = @id AND FirmaId = @FirmaId`;
    } else {
      query = `UPDATE Kullanicilar SET AdSoyad = @adSoyad, Eposta = @eposta, RolId = @rolId WHERE Id = @id AND FirmaId = @FirmaId`;
    }

    await request.query(query);
    res.json({ mesaj: "Kullanıcı güncellendi." });
  } catch (err) {
    res.status(500).send("Kullanıcı güncellenirken hata oluştu.");
  }
});

app.delete("/kullanicilar/:id", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    await request.query(
      "DELETE FROM Kullanicilar WHERE Id = @id AND FirmaId = @FirmaId",
    );
    res.json({ mesaj: "Kullanıcı silindi." });
  } catch (err) {
    if (err.number === 547)
      return res
        .status(400)
        .send("Bu kullanıcıya ait işlemler olduğu için silinemez.");
    res.status(500).send("Kullanıcı silinirken hata oluştu.");
  }
});

// PDF Şablonları

app.get("/sablonlar", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("FirmaId", sql.Int, req.user.firmaId);
    const result = await request.query(
      "SELECT * FROM PdfSablonlari WHERE FirmaId = @FirmaId ORDER BY Id ASC",
    );
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Şablonlar getirilemedi.");
  }
});

app.post("/sablonlar", authMiddleware, async (req, res) => {
  try {
    const {
      SablonAdi,
      AnaRenk,
      IkinciRenk,
      YaziTipi,
      LogoGoster,
      TabloTasarimi,
      AltBilgiMetni,
      BlokSiralamasi,
      BlokAyarlari,
    } = req.body;
    const request = new sql.Request();

    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("SablonAdi", sql.NVarChar(100), SablonAdi);
    request.input("AnaRenk", sql.VarChar(20), AnaRenk);
    request.input("IkinciRenk", sql.VarChar(20), IkinciRenk);
    request.input("YaziTipi", sql.VarChar(50), YaziTipi);
    request.input("LogoGoster", sql.Bit, LogoGoster);
    request.input("TabloTasarimi", sql.VarChar(50), TabloTasarimi);
    request.input("AltBilgiMetni", sql.NVarChar(sql.MAX), AltBilgiMetni);
    request.input("BlokSiralamasi", sql.NVarChar(sql.MAX), BlokSiralamasi);
    request.input("BlokAyarlari", sql.NVarChar(sql.MAX), BlokAyarlari);

    await request.query(`
      INSERT INTO PdfSablonlari (FirmaId, SablonAdi, AnaRenk, IkinciRenk, YaziTipi, LogoGoster, TabloTasarimi, AltBilgiMetni, BlokSiralamasi, BlokAyarlari)
      VALUES (@FirmaId, @SablonAdi, @AnaRenk, @IkinciRenk, @YaziTipi, @LogoGoster, @TabloTasarimi, @AltBilgiMetni, @BlokSiralamasi, @BlokAyarlari)
    `);
    res.status(201).json({ mesaj: "Şablon başarıyla eklendi." });
  } catch (err) {
    res.status(500).send("Şablon oluşturulamadı.");
  }
});

app.put("/sablonlar/:id", authMiddleware, async (req, res) => {
  try {
    const {
      SablonAdi,
      AnaRenk,
      IkinciRenk,
      YaziTipi,
      LogoGoster,
      TabloTasarimi,
      AltBilgiMetni,
      BlokSiralamasi,
      BlokAyarlari,
    } = req.body;
    const request = new sql.Request();

    request.input("Id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    request.input("SablonAdi", sql.NVarChar(100), SablonAdi);
    request.input("AnaRenk", sql.VarChar(20), AnaRenk);
    request.input("IkinciRenk", sql.VarChar(20), IkinciRenk);
    request.input("YaziTipi", sql.VarChar(50), YaziTipi);
    request.input("LogoGoster", sql.Bit, LogoGoster);
    request.input("TabloTasarimi", sql.VarChar(50), TabloTasarimi);
    request.input("AltBilgiMetni", sql.NVarChar(sql.MAX), AltBilgiMetni);
    request.input("BlokSiralamasi", sql.NVarChar(sql.MAX), BlokSiralamasi);
    request.input("BlokAyarlari", sql.NVarChar(sql.MAX), BlokAyarlari);

    await request.query(`
      UPDATE PdfSablonlari 
      SET SablonAdi = @SablonAdi, AnaRenk = @AnaRenk, IkinciRenk = @IkinciRenk, 
          YaziTipi = @YaziTipi, LogoGoster = @LogoGoster, TabloTasarimi = @TabloTasarimi, 
          AltBilgiMetni = @AltBilgiMetni, BlokSiralamasi = @BlokSiralamasi, BlokAyarlari = @BlokAyarlari
      WHERE Id = @Id AND FirmaId = @FirmaId
    `);
    res.json({ mesaj: "Şablon başarıyla güncellendi." });
  } catch (err) {
    res.status(500).send("Şablon güncellenemedi.");
  }
});

app.delete("/sablonlar/:id", authMiddleware, async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("Id", sql.Int, req.params.id);
    request.input("FirmaId", sql.Int, req.user.firmaId);
    await request.query(
      "DELETE FROM PdfSablonlari WHERE Id = @Id AND FirmaId = @FirmaId",
    );
    res.json({ mesaj: "Şablon başarıyla silindi." });
  } catch (err) {
    res.status(500).send("Şablon silinemedi.");
  }
});

app.put("/sablonlar/:id/varsayilan", authMiddleware, async (req, res) => {
  try {
    const transaction = new sql.Transaction();
    await transaction.begin();

    try {
      const req1 = new sql.Request(transaction);
      req1.input("FirmaId", sql.Int, req.user.firmaId);
      await req1.query(
        "UPDATE PdfSablonlari SET VarsayilanMi = 0 WHERE FirmaId = @FirmaId",
      );

      const req2 = new sql.Request(transaction);
      req2.input("Id", sql.Int, req.params.id);
      req2.input("FirmaId", sql.Int, req.user.firmaId);
      await req2.query(
        "UPDATE PdfSablonlari SET VarsayilanMi = 1 WHERE Id = @Id AND FirmaId = @FirmaId",
      );

      await transaction.commit();
      res.json({ mesaj: "Varsayılan şablon güncellendi." });
    } catch (err) {
      await transaction.rollback();
      throw err;
    }
  } catch (err) {
    res.status(500).send("Varsayılan şablon güncellenemedi.");
  }
});

// Firma Yönetimi

const firmaYonetimiMiddleware = (req, res, next) => {
  if (req.user.firmaId !== 1) {
    return res
      .status(403)
      .send("Bu işlem için Firma Yönetimi yetkisi gereklidir.");
  }
  next();
};

app.get(
  "/firmalar",
  authMiddleware,
  firmaYonetimiMiddleware,
  async (req, res) => {
    try {
      const result = await sql.query("SELECT * FROM Firmalar ORDER BY Id DESC");
      res.json(result.recordset);
    } catch (err) {
      res.status(500).send("Firmalar getirilemedi.");
    }
  },
);

app.post(
  "/firmalar",
  authMiddleware,
  firmaYonetimiMiddleware,
  async (req, res) => {
    try {
      const { firmaKodu, firmaAdi } = req.body;

      const checkReq = new sql.Request();
      checkReq.input("FirmaKodu", sql.NVarChar(50), firmaKodu);
      const checkRes = await checkReq.query(
        "SELECT Id FROM Firmalar WHERE FirmaKodu = @FirmaKodu",
      );
      if (checkRes.recordset.length > 0)
        return res.status(400).send("Bu firma kodu zaten kullanılıyor.");

      const transaction = new sql.Transaction();
      await transaction.begin();

      try {
        const insertFirma = new sql.Request(transaction);
        insertFirma.input("FirmaKodu", sql.NVarChar(50), firmaKodu);
        insertFirma.input("FirmaAdi", sql.NVarChar(100), firmaAdi);
        const firmaRes = await insertFirma.query(`
        INSERT INTO Firmalar (FirmaKodu, FirmaAdi, AktifMi) 
        OUTPUT INSERTED.Id 
        VALUES (@FirmaKodu, @FirmaAdi, 1)
      `);

        const yeniFirmaId = firmaRes.recordset[0].Id;
        const varsayilanSifre = "123456";
        const hashedSifre = await bcrypt.hash(varsayilanSifre, 10);
        const kullaniciAdi = `admin_${firmaKodu.toLowerCase()}`;

        const insertUser = new sql.Request(transaction);
        insertUser.input("FirmaId", sql.Int, yeniFirmaId);
        insertUser.input("AdSoyad", sql.NVarChar(100), kullaniciAdi);
        insertUser.input("Eposta", sql.VarChar(100), "");
        insertUser.input("Sifre", sql.VarChar(255), hashedSifre);

        await insertUser.query(`
        INSERT INTO Kullanicilar (FirmaId, AdSoyad, Eposta, Sifre, RolId) 
        VALUES (@FirmaId, @AdSoyad, @Eposta, @Sifre, 1)
      `);

        const insertAyarlar = new sql.Request(transaction);
        insertAyarlar.input("FirmaId", sql.Int, yeniFirmaId);
        insertAyarlar.input("SirketAdi", sql.NVarChar(100), firmaAdi);
        await insertAyarlar.query(`
        INSERT INTO SirketAyarlari (FirmaId, SirketAdi) 
        VALUES (@FirmaId, @SirketAdi)
      `);

        await transaction.commit();

        res.status(201).json({
          mesaj: "Firma oluşturuldu",
          kullaniciAdi: kullaniciAdi,
          sifre: varsayilanSifre,
        });
      } catch (err) {
        await transaction.rollback();
        throw err;
      }
    } catch (err) {
      res.status(500).send("Firma eklenirken hata oluştu.");
    }
  },
);

app.put(
  "/firmalar/:id",
  authMiddleware,
  firmaYonetimiMiddleware,
  async (req, res) => {
    try {
      if (req.params.id == 1)
        return res.status(403).send("Merkez firma (Emar) değiştirilemez.");

      const { firmaAdi, aktifMi } = req.body;
      const request = new sql.Request();
      request.input("Id", sql.Int, req.params.id);
      request.input("FirmaAdi", sql.NVarChar(100), firmaAdi);
      request.input("AktifMi", sql.Bit, aktifMi);

      await request.query(`
      UPDATE Firmalar SET FirmaAdi = @FirmaAdi, AktifMi = @AktifMi WHERE Id = @Id
    `);
      res.json({ mesaj: "Firma güncellendi." });
    } catch (err) {
      res.status(500).send("Firma güncellenirken hata oluştu.");
    }
  },
);

app.delete(
  "/firmalar/:id",
  authMiddleware,
  firmaYonetimiMiddleware,
  async (req, res) => {
    try {
      const firmaId = req.params.id;
      if (firmaId == 1)
        return res.status(403).send("Merkez firma (Emar) silinemez.");

      const transaction = new sql.Transaction();
      await transaction.begin();

      try {
        const reqDel = new sql.Request(transaction);
        reqDel.input("FirmaId", sql.Int, firmaId);

        await reqDel.query(
          "DELETE FROM TeklifDetaylari WHERE TeklifId IN (SELECT Id FROM Teklifler WHERE FirmaId = @FirmaId)",
        );
        await reqDel.query("DELETE FROM Teklifler WHERE FirmaId = @FirmaId");
        await reqDel.query("DELETE FROM Urunler WHERE FirmaId = @FirmaId");
        await reqDel.query("DELETE FROM Musteriler WHERE FirmaId = @FirmaId");
        await reqDel.query(
          "DELETE FROM PdfSablonlari WHERE FirmaId = @FirmaId",
        );
        await reqDel.query(
          "DELETE FROM SirketAyarlari WHERE FirmaId = @FirmaId",
        );
        await reqDel.query("DELETE FROM Kullanicilar WHERE FirmaId = @FirmaId");
        await reqDel.query("DELETE FROM Firmalar WHERE Id = @FirmaId");

        await transaction.commit();
        res.json({
          mesaj: "Firma ve firmaya ait tüm veriler başarıyla silindi.",
        });
      } catch (err) {
        await transaction.rollback();
        throw err;
      }
    } catch (err) {
      console.error("Firma silinirken hata:", err);
      res.status(500).send("Firma silinirken bir hata oluştu.");
    }
  },
);

app.listen(PORT, () =>
  console.log(
    `Sunucu http://localhost:${PORT} adresinde çalışıyor... (Güvenlik Katmanı Aktif)`,
  ),
);
