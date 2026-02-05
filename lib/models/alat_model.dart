class Alat {
  final int id;
  final String namaAlat;
  final int stokBarang;
  final String namaKategori;
  final String? fotoBarang;

  Alat({
    required this.id,
    required this.namaAlat,
    required this.stokBarang,
    required this.namaKategori,
    this.fotoBarang,
  });

  factory Alat.fromMap(Map<String, dynamic> map) {
    return Alat(
      id: map['Alat_ID'],
      namaAlat: map['NamaAlat'],
      stokBarang: map['Stok'],
      namaKategori: map['NamaKategori'],
      fotoBarang: map['FotoBarang'],
    );
  }
}
