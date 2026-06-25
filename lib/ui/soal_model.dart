class Soal {
  final String pertanyaan;
  final String a;
  final String b;
  final String c;
  final String d;

  Soal({
    required this.pertanyaan,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });

  factory Soal.fromJson(Map<String, dynamic> json) {
    return Soal(
      pertanyaan: (json['pertanyaan'] ?? json['Pertanyaan'] ?? '').toString(),
      a: (json['opsi_a'] ?? '').toString(),
      b: (json['opsi_b'] ?? '').toString(),
      c: (json['opsi_c'] ?? '').toString(),
      d: (json['opsi_d'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pertanyaan': pertanyaan,
      'opsi_a': a,
      'opsi_b': b,
      'opsi_c': c,
      'opsi_d': d,
    };
  }
}