const sql = require("mssql");
require("dotenv").config();

const isProduction = process.env.NODE_ENV === "production";

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,

  options: {
    encrypt: true,

    trustServerCertificate: !isProduction,
  },
};

const connectDB = async () => {
  try {
    await sql.connect(config);

    console.log(
      `MSSQL Veritabanına bağlanıldı! (Mod: ${isProduction ? "CANLI / PRODUCTION " : "LOKAL / DEVELOPMENT "})`,
    );
  } catch (err) {
    console.error("Veritabanı bağlantı hatası:", err.message);
  }
};

module.exports = { sql, connectDB };
