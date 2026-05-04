const express = require("express");
const cors = require("cors");
const { connectDB, sql } = require("./db");
const PORT = 3000;
const bcrypt = require("bcryptjs");
const app = express();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");

app.use(cors());
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

connectDB();
app.get("/", (req, res) => {
  res.send("Teklif API başarıyla çalışıyor!");
});

// Müşteri

app.get("/musteriler", async (req, res) => {
  try {
    const result = await sql.query(
      "SELECT * FROM Musteriler ORDER BY FirmaAdi ASC",
    );
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Veriler çekilirken bir hata oluştu.");
  }
});

app.post("/musteriler", async (req, res) => {
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
      INSERT INTO Musteriler (FirmaAdi, YetkiliKisi, Telefon, Eposta, VergiDairesi, VergiNo, Adres, Ulke, Sehir, Ilce)
      VALUES (@firmaAdi, @yetkiliKisi, @telefon, @eposta, @vergiDairesi, @vergiNo, @adres, @ulke, @sehir, @ilce)
    `);

    res.status(201).json({ mesaj: "Müşteri başarıyla eklendi." });
  } catch (err) {
    res.status(500).send("Müşteri eklenirken hata oluştu.");
  }
});

app.put("/musteriler/:id", async (req, res) => {
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
      WHERE Id = @id
    `);
    res.json({ mesaj: "Müşteri başarıyla güncellendi." });
  } catch (err) {
    res.status(500).send("Müşteri güncellenirken hata oluştu.");
  }
});

app.delete("/musteriler/:id", async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    await request.query("DELETE FROM Musteriler WHERE Id = @id");
    res.json({ mesaj: "Müşteri başarıyla silindi." });
  } catch (err) {
    if (err.number === 547)
      return res
        .status(400)
        .send("Bu müşteriye ait teklifler olduğu için silinemez.");
    res.status(500).send("Müşteri silinirken hata oluştu.");
  }
});

// Ürün

app.get("/urunler", async (req, res) => {
  try {
    const result = await sql.query(
      "SELECT * FROM Urunler ORDER BY UrunAdi ASC",
    );
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Veriler çekilirken bir hata oluştu.");
  }
});

app.post("/urunler", async (req, res) => {
  try {
    const {
      urunAdi,
      urunKodu,
      birimFiyati,
      paraBirimi,
      kdvOrani,
      aciklama,
      urunGorsel,
    } = req.body;

    if (!urunAdi || birimFiyati == null)
      return res.status(400).send("Ürün adı ve fiyat zorunludur.");

    const request = new sql.Request();
    request.input("urunAdi", sql.NVarChar(150), urunAdi);
    request.input("urunKodu", sql.VarChar(50), urunKodu || "");
    request.input("birimFiyati", sql.Decimal(18, 2), birimFiyati);
    request.input("paraBirimi", sql.VarChar(10), paraBirimi || "TRY");
    request.input("kdvOrani", sql.Int, kdvOrani || 18);
    request.input("aciklama", sql.NVarChar(sql.MAX), aciklama || "");

    request.input("urunGorsel", sql.NVarChar(sql.MAX), urunGorsel || "");

    await request.query(`
      INSERT INTO Urunler (UrunAdi, UrunKodu, BirimFiyati, ParaBirimi, KdvOrani, Aciklama, UrunGorsel) 
      VALUES (@urunAdi, @urunKodu, @birimFiyati, @paraBirimi, @kdvOrani, @aciklama, @urunGorsel)
    `);

    res.status(201).json({ mesaj: "Ürün başarıyla eklendi." });
  } catch (err) {
    res.status(500).send("Ürün eklenirken hata oluştu.");
  }
});

app.put("/urunler/:id", async (req, res) => {
  try {
    const {
      urunAdi,
      urunKodu,
      birimFiyati,
      paraBirimi,
      kdvOrani,
      aciklama,
      urunGorsel,
    } = req.body;
    const request = new sql.Request();

    request.input("id", sql.Int, req.params.id);
    request.input("urunAdi", sql.NVarChar(150), urunAdi);
    request.input("urunKodu", sql.VarChar(50), urunKodu || "");
    request.input("birimFiyati", sql.Decimal(18, 2), birimFiyati);
    request.input("paraBirimi", sql.VarChar(10), paraBirimi || "TRY");
    request.input("kdvOrani", sql.Int, kdvOrani || 18);
    request.input("aciklama", sql.NVarChar(sql.MAX), aciklama || "");
    request.input("urunGorsel", sql.NVarChar(sql.MAX), urunGorsel || "");

    await request.query(`
      UPDATE Urunler SET 
        UrunAdi = @urunAdi, UrunKodu = @UrunKodu, BirimFiyati = @birimFiyati, 
        ParaBirimi = @paraBirimi, KdvOrani = @kdvOrani, Aciklama = @aciklama, 
        UrunGorsel = @urunGorsel
      WHERE Id = @id
    `);
    res.json({ mesaj: "Ürün başarıyla güncellendi." });
  } catch (err) {
    res.status(500).send("Ürün güncellenirken hata oluştu.");
  }
});

app.delete("/urunler/:id", async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    await request.query("DELETE FROM Urunler WHERE Id = @id");
    res.json({ mesaj: "Ürün başarıyla silindi." });
  } catch (err) {
    if (err.number === 547)
      return res
        .status(400)
        .send("Bu ürün geçmiş tekliflerde kullanıldığı için silinemez.");
    res.status(500).send("Ürün silinirken bir hata oluştu.");
  }
});

// Teklif

app.get("/teklifler", async (req, res) => {
  try {
    const result = await sql.query(`
      SELECT 
        t.*, 
        m.FirmaAdi, 
        m.YetkiliKisi,
        m.Telefon,
        m.Eposta,
        m.Adres,
        m.Sehir, -- YENİ EKLENDİ
        m.Ilce,  -- YENİ EKLENDİ
        m.Ulke,  -- YENİ EKLENDİ
        k.AdSoyad as OlusturanKisi,
        DATEDIFF(day, t.OlusturmaTarihi, t.GecerlilikTarihi) AS GecerlilikGunu
      FROM Teklifler t 
      INNER JOIN Musteriler m ON t.MusteriId = m.Id
      LEFT JOIN Kullanicilar k ON t.KullaniciId = k.Id
      ORDER BY t.OlusturmaTarihi DESC
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Teklifler getirilirken hata oluştu.");
  }
});

app.get("/teklifler/:id/detay", async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("teklifId", sql.Int, req.params.id);

    const result = await request.query(`
  SELECT 
    td.Id, td.TeklifId, td.UrunId, 
    u.UrunAdi, u.UrunGorsel, 
    td.Miktar, td.BirimFiyat, td.IskontoYuzdesi, 
    td.KdvOrani -- <-- YENİ EKLENEN KISIM
  FROM TeklifDetaylari td 
  INNER JOIN Urunler u ON td.UrunId = u.Id
  WHERE td.TeklifId = @teklifId
`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Teklif detayları getirilirken bir hata oluştu.");
  }
});

app.post("/teklifler", async (req, res) => {
  try {
    const {
      teklifNo,
      kullaniciId,
      musteriId,
      yeniFirmaAdi,
      yeniTelefon,
      yeniEposta,
      yeniAdres,
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
      musteriReq.input("firmaAdi", sql.NVarChar(150), yeniFirmaAdi);
      musteriReq.input(
        "yetkiliKisi",
        sql.NVarChar(100),
        req.body.yeniYetkiliKisi || "",
      );
      musteriReq.input(
        "telefon",
        sql.VarChar(20),
        yeniTelefon || "Belirtilmedi",
      );
      musteriReq.input("eposta", sql.VarChar(100), yeniEposta || "");
      musteriReq.input(
        "vergiDairesi",
        sql.NVarChar(50),
        req.body.yeniVergiDairesi || "",
      );
      musteriReq.input("vergiNo", sql.VarChar(50), req.body.yeniVergiNo || "");
      musteriReq.input("adres", sql.NVarChar(sql.MAX), yeniAdres || "");

      const musteriRes = await musteriReq.query(`
        INSERT INTO Musteriler (FirmaAdi, YetkiliKisi, Telefon, Eposta, VergiDairesi, VergiNo, Adres) 
        OUTPUT INSERTED.Id 
        VALUES (@firmaAdi, @yetkiliKisi, @telefon, @eposta, @vergiDairesi, @vergiNo, @adres)
      `);
      finalMusteriId = musteriRes.recordset[0].Id;
    }

    const transaction = new sql.Transaction();
    await transaction.begin();

    try {
      const teklifReq = new sql.Request(transaction);
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
        INSERT INTO Teklifler (TeklifNo, KullaniciId, MusteriId, OlusturmaTarihi, GecerlilikTarihi, AraToplam, ToplamIndirim, GenelToplam, Durum, GenelNot, Doviz, OdemeTuru)
        OUTPUT INSERTED.Id
        VALUES (@teklifNo, @kullaniciId, @musteriId, GETDATE(), DATEADD(day, @gecerlilikGunu, GETDATE()), @araToplam, @toplamIndirim, @genelToplam, 'Bekliyor', @genelNot, @doviz, @odemeTuru)
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

app.post("/teklifler/:id/guncelle", async (req, res) => {
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
          TeklifNo = @teklifNo, 
          MusteriId = @musteriId, 
          AraToplam = @araToplam, 
          ToplamIndirim = @toplamIndirim, 
          GenelToplam = @genelToplam, 
          GenelNot = @genelNot, 
          GecerlilikTarihi = DATEADD(day, @gecerlilikGunu, OlusturmaTarihi),
          Doviz = @doviz,
          OdemeTuru = @odemeTuru -- <-- SQL UPDATE
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

app.put("/teklifler/:id/durum", async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    request.input("durum", sql.NVarChar(50), req.body.durum);

    await request.query("UPDATE Teklifler SET Durum = @durum WHERE Id = @id");
    res.json({ mesaj: "Durum güncellendi." });
  } catch (err) {
    res.status(500).send("Durum güncellenirken hata oluştu.");
  }
});

app.delete("/teklifler/:id", async (req, res) => {
  try {
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
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    cb(null, uuidv4() + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });

app.post("/teklifler/pdf-yukle", upload.single("pdf"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send("Dosya yüklenemedi.");
    }
    const fileUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;

    res.status(200).json({ url: fileUrl });
  } catch (err) {
    res.status(500).send("PDF yüklenirken hata oluştu.");
  }
});

// Çalışan - Kullanıcı

app.get("/roller", async (req, res) => {
  try {
    const result = await sql.query("SELECT * FROM Roller");
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Roller çekilemedi.");
  }
});

app.get("/kullanicilar", async (req, res) => {
  try {
    const result = await sql.query(`
      SELECT u.Id, u.AdSoyad, u.Eposta, u.Sifre, u.RolId, r.RolAdi 
      FROM Kullanicilar u INNER JOIN Roller r ON u.RolId = r.Id
    `);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Kullanıcılar getirilemedi.");
  }
});

app.put("/kullanicilar/:id", async (req, res) => {
  try {
    const { adSoyad, eposta, sifre, rolId } = req.body;
    const request = new sql.Request();

    request.input("id", sql.Int, req.params.id);
    request.input("adSoyad", sql.NVarChar(100), adSoyad);
    request.input("eposta", sql.VarChar(100), eposta);
    request.input("rolId", sql.Int, rolId);

    let query = "";
    if (sifre && sifre.trim() !== "") {
      request.input("sifre", sql.VarChar(255), sifre);
      query = `UPDATE Kullanicilar SET AdSoyad = @adSoyad, Eposta = @eposta, Sifre = @sifre, RolId = @rolId WHERE Id = @id`;
    } else {
      query = `UPDATE Kullanicilar SET AdSoyad = @adSoyad, Eposta = @eposta, RolId = @rolId WHERE Id = @id`;
    }

    await request.query(query);
    res.json({ mesaj: "Kullanıcı güncellendi." });
  } catch (err) {
    res.status(500).send("Kullanıcı güncellenirken hata oluştu.");
  }
});

app.delete("/kullanicilar/:id", async (req, res) => {
  try {
    const request = new sql.Request();
    request.input("id", sql.Int, req.params.id);
    await request.query("DELETE FROM Kullanicilar WHERE Id = @id");
    res.json({ mesaj: "Kullanıcı silindi." });
  } catch (err) {
    if (err.number === 547)
      return res
        .status(400)
        .send("Bu kullanıcıya ait işlemler olduğu için silinemez.");
    res.status(500).send("Kullanıcı silinirken hata oluştu.");
  }
});

app.post("/kullanicilar", async (req, res) => {
  try {
    const { adSoyad, eposta, sifre, rolId } = req.body;
    const hashedSifre = await bcrypt.hash(sifre, 10);
    const request = new sql.Request();
    request.input("adSoyad", sql.NVarChar(100), adSoyad);
    request.input("eposta", sql.VarChar(100), eposta);
    request.input("sifre", sql.VarChar(255), hashedSifre);
    request.input("rolId", sql.Int, rolId);

    await request.query(
      `INSERT INTO Kullanicilar (AdSoyad, Eposta, Sifre, RolId) VALUES (@adSoyad, @eposta, @sifre, @rolId)`,
    );
    res.status(201).json({ mesaj: "Başarılı" });
  } catch (err) {
    res.status(500).send("Hata.");
  }
});

// Giriş yapma

app.post("/kullanicilar/login", async (req, res) => {
  try {
    const { kullaniciBilgisi, sifre } = req.body;

    if (!kullaniciBilgisi || !sifre)
      return res.status(400).send("E-posta/Kullanıcı adı ve şifre zorunludur.");

    const request = new sql.Request();
    request.input("kullaniciBilgisi", sql.VarChar(100), kullaniciBilgisi);

    const result = await request.query(`
      SELECT u.Id, u.AdSoyad, u.Eposta, u.Sifre, u.RolId, r.RolAdi 
      FROM Kullanicilar u INNER JOIN Roller r ON u.RolId = r.Id
      WHERE u.Eposta = @kullaniciBilgisi OR u.AdSoyad = @kullaniciBilgisi
    `);

    if (result.recordset.length === 0)
      return res.status(401).send("Kullanıcı bulunamadı.");

    const user = result.recordset[0];
    const isMatch = await bcrypt.compare(sifre, user.Sifre);
    if (!isMatch) return res.status(401).send("Hatalı şifre.");

    delete user.Sifre;
    res.json(user);
  } catch (err) {
    res.status(500).send("Giriş hatası.");
  }
});

// Dashboard

app.get("/dashboard-stats", async (req, res) => {
  try {
    const urunler = await sql.query("SELECT COUNT(*) as Toplam FROM Urunler");
    const musteriler = await sql.query(
      "SELECT COUNT(*) as Toplam FROM Musteriler",
    );
    const teklifler = await sql.query(`
  SELECT COUNT(*) as Toplam 
  FROM Teklifler 
  WHERE TeklifNo IS NOT NULL 
    AND TeklifNo != '' 
    AND Durum != 'Silindi'
    AND Durum != 'Taslak'
`);
    const gelir = await sql.query(
      "SELECT SUM(GenelToplam) as ToplamGelir FROM Teklifler WHERE Durum = 'Kabul Edildi'",
    );

    const grafik = await sql.query(`
      SELECT 
        CAST(OlusturmaTarihi AS DATE) as Tarih, 
        COUNT(*) as Sayi 
      FROM Teklifler 
      WHERE OlusturmaTarihi >= DATEADD(day, -6, CAST(GETDATE() AS DATE))
      GROUP BY CAST(OlusturmaTarihi AS DATE)
    `);

    const son7Gun = [];
    const gunAdlari = ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"];

    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const tarihStr = d.toISOString().split("T")[0];
      const gunAdi = gunAdlari[d.getDay()];

      const dataRow = grafik.recordset.find((r) => {
        const dbTarih = new Date(r.Tarih).toISOString().split("T")[0];
        return dbTarih === tarihStr;
      });

      son7Gun.push({
        tarih: tarihStr,
        gunAdi: gunAdi,
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
    console.error("Dashboard İstatistik Hatası:", err);
    res.status(500).send("İstatistikler getirilemedi.");
  }
});

// Şirket Ayarları

app.get("/sirket", async (req, res) => {
  try {
    const result = await sql.query("SELECT TOP 1 * FROM SirketAyarlari");
    res.json(result.recordset.length > 0 ? result.recordset[0] : {});
  } catch (err) {
    res.status(500).send("Şirket ayarları çekilirken hata oluştu.");
  }
});

app.put("/api/sirket", async (req, res) => {
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

    const query = `
            UPDATE SirketAyarlari 
            SET SirketAdi = @SirketAdi, 
                Yetkili = @Yetkili, 
                Telefon = @Telefon, 
                Eposta = @Eposta, 
                WebSitesi = @WebSitesi, 
                VergiDairesi = @VergiDairesi, 
                VergiNo = @VergiNo, 
                BankaBilgileri = @BankaBilgileri, 
                Adres = @Adres, 
                Logo = @Logo 
            WHERE Id = (SELECT TOP 1 Id FROM SirketAyarlari)
        `;

    await request.query(query);

    res
      .status(200)
      .json({ message: "Şirket bilgileri başarıyla güncellendi!" });
  } catch (error) {
    console.error("Şirket güncellenirken MSSQL hatası:", error);
    res.status(500).json({ error: "Sunucu hatası: " + error.message });
  }
});

app.listen(PORT, () =>
  console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor...`),
);
