function doGet(e) {
  var action = e.parameter.action;
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();

  if (action === "login") {
    // 1. Ambil input login dan bersihkan dari spasi/kapital (Case Insensitive)
    var usernameInput = (e.parameter.username || "").toString().trim().toLowerCase();
    var passwordInput = (e.parameter.password || "").toString().trim();

    // 2. Membuka sheet "hasil"
    var hasilSheet = spreadsheet.getSheetByName("hasil");
    if (hasilSheet) {
      var dataHasil = hasilSheet.getDataRange().getValues();
      
      // 3. Lakukan pengecekan baris demi baris
      for (var i = 1; i < dataHasil.length; i++) {
        // Ambil username di Kolom B, ubah ke string, hapus spasi, dan kecilkan hurufnya
        var usernameHasil = dataHasil[i][1].toString().trim().toLowerCase();
        
        // Cek apakah sama dengan input login
        if (usernameHasil === usernameInput && usernameInput !== "") {
          // Jika COCOK, langsung hentikan fungsi dan return "sudah_ujian"
          return ContentService.createTextOutput(JSON.stringify({
            "status": "sudah_ujian",
            "message": "Akun ini sudah menyelesaikan ujian!"
          })).setMimeType(ContentService.MimeType.JSON);
        }
      }
    }

    // --- DI BAWAH INI ADALAH LOGIKA LOGIN UTAMA YANG SUDAH ADA ---
    // (Gunakan variabel `usernameInput` dan `passwordInput` untuk mencocokkan dengan sheet "peserta/users")
  }
}