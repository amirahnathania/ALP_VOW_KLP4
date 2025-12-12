part of 'home_gapoktan.dart';

mixin _HomeModalsMixin on _HomePageStateBase {
  // Data dummy untuk dropdown
  final List<String> _jenisKegiatanOptions = [
    'Penanaman Padi',
    'Penanaman Jagung',
    'Penanaman Kedelai',
    'Pemupukan',
    'Penyemprotan',
    'Panen',
    'Pengairan',
  ];
  
  final List<String> _jenisPestisidaOptions = [
    'Pestisida Organik',
    'Pestisida Kimia Tipe A',
    'Pestisida Kimia Tipe B',
    'Fungisida',
    'Herbisida',
    'Insektisida',
    'Tidak Menggunakan Pestisida',
  ];
  
  final List<String> _targetPenanamanOptions = [
    '100 - 500 kg',
    '500 - 1000 kg',
    '1000 - 2000 kg',
    '2000 - 5000 kg',
    'Lebih dari 5000 kg',
  ];
  
  final List<String> _keteranganOptions = [
    'Kegiatan rutin',
    'Kegiatan musiman',
    'Kegiatan khusus',
    'Program pemerintah',
    'Kerjasama kelompok tani',
    'Pelatihan dan pendampingan',
  ];

  @override
  Future<void> _openEventForm({Kegiatan? existing}) async {
    final result = await Navigator.push<Kegiatan>(
      context,
      MaterialPageRoute(
        builder: (context) => AddKegiatanScreen(existingKegiatan: existing),
      ),
    );
    
    if (result == null || !mounted) return;
    
    setState(() {
      final idx = _kegiatan.indexWhere((k) => k.id == result.id);
      if (idx >= 0) {
        _kegiatan[idx] = result;
      } else {
        _kegiatan.insert(0, result);
      }
      _colorFor(result);
      _reindexEvents();
    });
    return;
    
    // OLD CODE - Keep for reference but unused
    final formKey = GlobalKey<FormState>();
    
    String? selectedJenisKegiatan = existing?.jenisPenanaman;
    String? selectedPestisida = existing?.jenisPestisida;
    String? selectedTarget = existing?.targetPenanaman;
    String? selectedKeterangan = existing?.keterangan;
    
    DateTimeRange? range = existing != null
        ? DateTimeRange(start: existing.startDate, end: existing.endDate)
        : null;
    TimeOfDay? waktuMulai =
        existing?.waktuMulai ?? const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay? waktuSelesai =
        existing?.waktuSelesai ?? const TimeOfDay(hour: 9, minute: 0);

    int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

    TimeOfDay _addMinutes(TimeOfDay time, int deltaMinutes) {
      final base = DateTime(
        2000,
        1,
        1,
        time.hour,
        time.minute,
      ).add(Duration(minutes: deltaMinutes));
      final capped = base.day > 1 ? DateTime(2000, 1, 1, 23, 59) : base;
      return TimeOfDay(hour: capped.hour, minute: capped.minute);
    }

    bool isEndAfterStart(TimeOfDay start, TimeOfDay end) =>
        minutesOf(end) > minutesOf(start);

    TimeOfDay ensureValidEnd(TimeOfDay start, TimeOfDay? endCandidate) {
      if (endCandidate == null) return _addMinutes(start, 60);
      return isEndAfterStart(start, endCandidate)
          ? endCandidate
          : _addMinutes(start, 60);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + viewInsets),
                child: StatefulBuilder(
                  builder: (context, setSheetState) {
                    final overlapWarning =
                        range != null &&
                        _isRangeClashing(
                          range!.start,
                          range!.end,
                          exceptId: existing?.id,
                        );
                    return SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existing == null
                                  ? 'Tambah Kegiatan Gapoktan'
                                  : 'Edit Kegiatan',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Jenis Kegiatan',
                              value: selectedJenisKegiatan,
                              items: _jenisKegiatanOptions,
                              onChanged: (value) {
                                setSheetState(() => selectedJenisKegiatan = value);
                              },
                            ),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(DateTime.now().year - 1),
                                  lastDate: DateTime(DateTime.now().year + 4),
                                  initialDateRange: range,
                                );
                                if (picked != null) {
                                  setSheetState(() => range = picked);
                                }
                              },
                              child: _PickerField(
                                label: 'Tanggal (Rentang)',
                                value: _formatRange(range),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            waktuMulai ??
                                            const TimeOfDay(hour: 7, minute: 0),
                                      );
                                      if (picked != null) {
                                        setSheetState(() {
                                          waktuMulai = picked;
                                          waktuSelesai = ensureValidEnd(
                                            picked,
                                            waktuSelesai,
                                          );
                                        });
                                      }
                                    },
                                    child: _PickerField(
                                      label: 'Waktu Mulai',
                                      value: waktuMulai == null
                                          ? 'Pilih waktu mulai'
                                          : _formatTime(waktuMulai!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            waktuSelesai ??
                                            (waktuMulai ??
                                                const TimeOfDay(
                                                  hour: 9,
                                                  minute: 0,
                                                )),
                                      );
                                      if (picked != null) {
                                        final startForCheck =
                                            waktuMulai ?? picked;
                                        if (!isEndAfterStart(
                                          startForCheck,
                                          picked,
                                        )) {
                                          setSheetState(() {
                                            waktuMulai = startForCheck;
                                            waktuSelesai = ensureValidEnd(
                                              startForCheck,
                                              picked,
                                            );
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Waktu selesai disesuaikan agar setelah waktu mulai',
                                              ),
                                            ),
                                          );
                                        } else {
                                          setSheetState(
                                            () => waktuSelesai = picked,
                                          );
                                        }
                                      }
                                    },
                                    child: _PickerField(
                                      label: 'Waktu Selesai',
                                      value: waktuSelesai == null
                                          ? 'Pilih waktu selesai'
                                          : _formatTime(waktuSelesai!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown(
                              label: 'Jenis Pestisida',
                              value: selectedPestisida,
                              items: _jenisPestisidaOptions,
                              onChanged: (value) {
                                setSheetState(() => selectedPestisida = value);
                              },
                            ),
                            _buildDropdown(
                              label: 'Target Penanaman',
                              value: selectedTarget,
                              items: _targetPenanamanOptions,
                              onChanged: (value) {
                                setSheetState(() => selectedTarget = value);
                              },
                            ),
                            _buildDropdown(
                              label: 'Keterangan',
                              value: selectedKeterangan,
                              items: _keteranganOptions,
                              onChanged: (value) {
                                setSheetState(() => selectedKeterangan = value);
                              },
                            ),
                            if (overlapWarning)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF617F59),
                                      Color(0xFF7B5B18),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Rentang tanggal ini bertabrakan dengan kegiatan lain. Tinjau kembali jadwal atau biarkan jika memang direncanakan.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _navButton,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: () {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                if (range == null ||
                                    waktuMulai == null ||
                                    waktuSelesai == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tanggal dan waktu wajib diisi',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (selectedJenisKegiatan == null ||
                                    selectedPestisida == null ||
                                    selectedTarget == null ||
                                    selectedKeterangan == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Semua field dropdown wajib diisi',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (!isEndAfterStart(
                                  waktuMulai!,
                                  waktuSelesai!,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Waktu selesai harus setelah waktu mulai',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final currentRange = range!;
                                final kegiatanBaru = Kegiatan(
                                  id:
                                      existing?.id ??
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  keterangan: selectedKeterangan!,
                                  jenisPenanaman: selectedJenisKegiatan!,
                                  startDate: currentRange.start,
                                  endDate: currentRange.end,
                                  waktuMulai: waktuMulai!,
                                  waktuSelesai: waktuSelesai!,
                                  jenisPestisida: selectedPestisida!,
                                  targetPenanaman: selectedTarget!,
                                  buktiFoto: existing?.buktiFoto,
                                );
                                if (!mounted) return;
                                setState(() {
                                  final idx = _kegiatan.indexWhere(
                                    (k) => k.id == kegiatanBaru.id,
                                  );
                                  if (idx >= 0) {
                                    _kegiatan[idx] = kegiatanBaru;
                                  } else {
                                    _kegiatan.insert(0, kegiatanBaru);
                                  }
                                  _colorFor(kegiatanBaru);
                                  _reindexEvents();
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                existing == null
                                    ? 'Simpan Kegiatan'
                                    : 'Perbarui Kegiatan',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Wajib diisi' : null,
            decoration: InputDecoration(
              hintText: hint ?? 'Masukkan $label',
              filled: true,
              fillColor: const Color(0xFFF7F7F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F7F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: Text('Pilih $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) => value == null ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  @override
  void _openActionsForDay(DateTime day) {
    final events = _eventsOfDay(day);
    Kegiatan? selected = events.isNotEmpty ? events.first : null;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateFormatter.format(day),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (events.length > 1)
                    DropdownMenu<Kegiatan>(
                      initialSelection: selected,
                      dropdownMenuEntries: events
                          .map(
                            (e) => DropdownMenuEntry(
                              value: e,
                              label: e.keterangan,
                            ),
                          )
                          .toList(),
                      onSelected: (value) =>
                          setSheetState(() => selected = value),
                      label: const Text('Pilih kegiatan'),
                    ),
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Belum ada kegiatan, tambah sekarang.',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Tambah Kegiatan'),
                    onTap: () {
                      Navigator.pop(context);
                      _openEventForm();
                    },
                  ),
                  if (selected != null) ...[
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Detail Kegiatan'),
                      onTap: () {
                        Navigator.pop(context);
                        _showDetail(selected!);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: const Text('Edit Kegiatan'),
                      onTap: () {
                        Navigator.pop(context);
                        _openEventForm(existing: selected);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('Bukti Foto'),
                      onTap: () {
                        Navigator.pop(context);
                        _showBuktiFoto(selected!);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Hapus Kegiatan'),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDelete(selected!);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void _showDetail(Kegiatan kegiatan) {
    final accent = _colorFor(kegiatan);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _withOpacity(accent, 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _withOpacity(accent, 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 10, top: 4),
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kegiatan.jenisPenanaman,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    kegiatan.keterangan,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_dateFormatter.format(kegiatan.startDate)} - ${_dateFormatter.format(kegiatan.endDate)} • ${_formatTimeRange(kegiatan.waktuMulai, kegiatan.waktuSelesai)}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.handshake,
                        label: 'Jenis Kegiatan',
                        value: kegiatan.jenisPenanaman,
                        accent: accent,
                      ),
                      _DetailRow(
                        icon: Icons.date_range,
                        label: 'Tanggal',
                        value:
                            '${_dateFormatter.format(kegiatan.startDate)} - ${_dateFormatter.format(kegiatan.endDate)}',
                        accent: accent,
                      ),
                      _DetailRow(
                        icon: Icons.schedule,
                        label: 'Waktu',
                        value: _formatTimeRange(
                          kegiatan.waktuMulai,
                          kegiatan.waktuSelesai,
                        ),
                        accent: accent,
                      ),
                      _DetailRow(
                        icon: Icons.pest_control,
                        label: 'Jenis Pestisida',
                        value: kegiatan.jenisPestisida,
                        accent: accent,
                      ),
                      _DetailRow(
                        icon: Icons.flag,
                        label: 'Target Penanaman',
                        value: kegiatan.targetPenanaman,
                        accent: accent,
                      ),
                      _DetailRow(
                        icon: Icons.notes,
                        label: 'Keterangan',
                        value: kegiatan.keterangan,
                        accent: accent,
                      ),
                      if (kegiatan.buktiFoto.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Bukti Foto Kegiatan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: kegiatan.buktiFoto.length,
                          itemBuilder: (context, index) {
                            final foto = kegiatan.buktiFoto[index];
                            final isRemote = _isRemoteImage(foto.imagePath);
                            return GestureDetector(
                              onTap: () {
                                // Tampilkan foto fullscreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => _ImagePreviewScreen(
                                      path: foto.imagePath,
                                      isRemote: isRemote,
                                      title: 'Bukti Foto ${index + 1}',
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isRemote
                                    ? Image.network(
                                        foto.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          );
                                        },
                                      )
                                    : File(foto.imagePath).existsSync()
                                        ? Image.file(
                                            File(foto.imagePath),
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          ),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Tombol Ambil Foto
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await PhotoService.captureDirectly();
                          if (file != null && mounted) {
                            setState(() {
                              kegiatan.buktiFoto.add(
                                PhotoEvidence(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  imagePath: file.path,
                                  uploaderName: 'User',
                                  uploaderRole: 'Gapoktan',
                                  uploaderEmail: widget.user['email'] ?? '',
                                  uploadedAt: DateTime.now(),
                                ),
                              );
                            });
                            Navigator.pop(context); // Tutup modal
                            _showDetail(kegiatan); // Buka kembali dengan data baru
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto berhasil ditambahkan'),
                                backgroundColor: Color(0xFF62903A),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Ambil Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  @override
  void _showBuktiFoto(Kegiatan kegiatan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bukti = kegiatan.buktiFoto;
        final accent = _colorFor(kegiatan);
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: bukti.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada bukti foto yang diunggah.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: bukti.length,
                              itemBuilder: (context, index) {
                                final item = bukti[index];
                                final isRemote = _isRemoteImage(item.imagePath);
                                final localFile =
                                    !isRemote && item.imagePath.isNotEmpty
                                    ? File(item.imagePath)
                                    : null;
                                final hasLocal =
                                    localFile?.existsSync() ?? false;

                                void handleOpen() {
                                  _openEvidenceViewer(
                                    evidence: item,
                                    isRemote: isRemote,
                                    file: hasLocal ? localFile : null,
                                  );
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: handleOpen,
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: _buildEvidenceImage(
                                            item,
                                            isRemote: isRemote,
                                            file: hasLocal ? localFile : null,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: _primaryGreen,
                                          child: Text(
                                            item.uploaderName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        title: Text(item.uploaderName),
                                        subtitle: Text(
                                          '${item.uploaderRole} • ${_dateTimeFormatter.format(item.uploadedAt)}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.open_in_new),
                                          onPressed: handleOpen,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openEvidenceViewer({
    required PhotoEvidence evidence,
    required bool isRemote,
    File? file,
  }) {
    if (!isRemote) {
      if (file == null || !file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File bukti tidak tersedia di perangkat ini.'),
          ),
        );
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImagePreviewScreen(
          path: isRemote ? evidence.imagePath : file!.path,
          isRemote: isRemote,
          title: evidence.uploaderName,
        ),
      ),
    );
  }

  Widget _buildEvidenceImage(
    PhotoEvidence evidence, {
    required bool isRemote,
    File? file,
  }) {
    if (isRemote) {
      return Image.network(
        evidence.imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _photoPlaceholder(),
      );
    }
    if (file != null && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(),
      );
    }
    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.photo, color: Colors.black38, size: 40),
      ),
    );
  }

  @override
  void _confirmDelete(Kegiatan kegiatan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kegiatan'),
          content: Text('Hapus ${kegiatan.keterangan}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _kegiatan.removeWhere((k) => k.id == kegiatan.id);
                  _removeColor(kegiatan.id);
                  _reindexEvents();
                });
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
