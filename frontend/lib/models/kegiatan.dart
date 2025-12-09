import 'package:flutter/material.dart';

/// Model yang merepresentasikan sebuah kegiatan Gapoktan.
class Kegiatan {
  Kegiatan({
    required this.id,
    required this.keterangan,
    required this.jenisPenanaman,
    required this.startDate,
    required this.endDate,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.jenisPestisida,
    required this.targetPenanaman,
    List<PhotoEvidence>? buktiFoto,
  }) : buktiFoto = List<PhotoEvidence>.from(buktiFoto ?? <PhotoEvidence>[]);

  final String id;
  final String keterangan;
  final String jenisPenanaman;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String jenisPestisida;
  final String targetPenanaman;
  final List<PhotoEvidence> buktiFoto;

  bool get isSingleDay => startDate.isAtSameMomentAs(_normalize(endDate));

  Duration get duration =>
      endDate.difference(startDate).abs() + const Duration(days: 1);

  Kegiatan copyWith({
    String? id,
    String? keterangan,
    String? jenisPenanaman,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? waktuMulai,
    TimeOfDay? waktuSelesai,
    String? jenisPestisida,
    String? targetPenanaman,
    List<PhotoEvidence>? buktiFoto,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      keterangan: keterangan ?? this.keterangan,
      jenisPenanaman: jenisPenanaman ?? this.jenisPenanaman,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      jenisPestisida: jenisPestisida ?? this.jenisPestisida,
      targetPenanaman: targetPenanaman ?? this.targetPenanaman,
      buktiFoto: buktiFoto ?? List<PhotoEvidence>.from(this.buktiFoto),
    );
  }

  static DateTime _normalize(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Model untuk bukti foto yang diunggah kelompok.
class PhotoEvidence {
  PhotoEvidence({
    required this.id,
    required this.uploaderName,
    required this.uploaderRole,
    required this.uploaderEmail,
    required this.uploadedAt,
    required this.imagePath,
  });

  final String id;
  final String uploaderName;
  final String uploaderRole;
  final String uploaderEmail;
  final DateTime uploadedAt;
  final String imagePath;
}
