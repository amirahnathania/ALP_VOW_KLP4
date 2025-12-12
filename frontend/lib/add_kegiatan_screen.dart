import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/kegiatan.dart';

class AddKegiatanScreen extends StatefulWidget {
  final Kegiatan? existingKegiatan;
  
  const AddKegiatanScreen({super.key, this.existingKegiatan});

  @override
  State<AddKegiatanScreen> createState() => _AddKegiatanScreenState();
}

class _AddKegiatanScreenState extends State<AddKegiatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
  
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
  
  String? selectedJenisKegiatan;
  String? selectedPestisida;
  String? selectedTarget;
  String? selectedKeterangan;
  DateTimeRange? selectedRange;
  TimeOfDay? waktuMulai;
  TimeOfDay? waktuSelesai;

  @override
  void initState() {
    super.initState();
    if (widget.existingKegiatan != null) {
      selectedJenisKegiatan = widget.existingKegiatan!.jenisPenanaman;
      selectedPestisida = widget.existingKegiatan!.jenisPestisida;
      selectedTarget = widget.existingKegiatan!.targetPenanaman;
      selectedKeterangan = widget.existingKegiatan!.keterangan;
      selectedRange = DateTimeRange(
        start: widget.existingKegiatan!.startDate,
        end: widget.existingKegiatan!.endDate,
      );
      waktuMulai = widget.existingKegiatan!.waktuMulai;
      waktuSelesai = widget.existingKegiatan!.waktuSelesai;
    } else {
      waktuMulai = const TimeOfDay(hour: 7, minute: 0);
      waktuSelesai = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final dt = DateTime(0, 1, 1, time.hour, time.minute);
    return DateFormat('HH:mm', 'id_ID').format(dt);
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Pilih rentang tanggal';
    return '${_dateFormatter.format(range.start)} - ${_dateFormatter.format(range.end)}';
  }

  // Helper method untuk cek apakah pestisida wajib (hanya untuk Penyemprotan)
  bool _isPestisidaRequired() {
    return selectedJenisKegiatan == 'Penyemprotan';
  }

  // Helper method untuk cek apakah target penanaman wajib (untuk Penanaman Padi/Jagung/Kedelai)
  bool _isTargetRequired() {
    return selectedJenisKegiatan == 'Penanaman Padi' ||
           selectedJenisKegiatan == 'Penanaman Jagung' ||
           selectedJenisKegiatan == 'Penanaman Kedelai';
  }

  // Helper method untuk cek apakah keterangan wajib (untuk Pemupukan)
  bool _isKeteranganRequired() {
    return selectedJenisKegiatan == 'Pemupukan';
  }

  void _saveKegiatan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validasi field yang selalu wajib: Jenis Kegiatan, Tanggal, dan Waktu
    if (selectedJenisKegiatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis kegiatan wajib dipilih')),
      );
      return;
    }
    
    if (selectedRange == null || waktuMulai == null || waktuSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan waktu wajib diisi')),
      );
      return;
    }
    
    // Validasi kondisional berdasarkan jenis kegiatan
    if (_isPestisidaRequired() && selectedPestisida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis pestisida wajib diisi untuk kegiatan Penyemprotan')),
      );
      return;
    }
    
    if (_isTargetRequired() && selectedTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target penanaman wajib diisi untuk kegiatan Penanaman')),
      );
      return;
    }
    
    if (_isKeteranganRequired() && selectedKeterangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keterangan wajib diisi untuk kegiatan Pemupukan')),
      );
      return;
    }

    final kegiatanBaru = Kegiatan(
      id: widget.existingKegiatan?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      keterangan: selectedKeterangan ?? '-',
      jenisPenanaman: selectedJenisKegiatan!,
      startDate: selectedRange!.start,
      endDate: selectedRange!.end,
      waktuMulai: waktuMulai!,
      waktuSelesai: waktuSelesai!,
      jenisPestisida: selectedPestisida ?? '-',
      targetPenanaman: selectedTarget ?? '-',
      buktiFoto: widget.existingKegiatan?.buktiFoto,
    );

    Navigator.pop(context, kegiatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingKegiatan == null
              ? 'Tambah Kegiatan Gapoktan'
              : 'Edit Kegiatan',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDropdownField(
              label: 'Jenis Kegiatan',
              value: selectedJenisKegiatan,
              items: _jenisKegiatanOptions,
              onChanged: (value) {
                setState(() {
                  selectedJenisKegiatan = value;
                  // Reset field opsional saat ganti jenis kegiatan
                  if (!_isPestisidaRequired()) selectedPestisida = null;
                  if (!_isTargetRequired()) selectedTarget = null;
                  if (!_isKeteranganRequired()) selectedKeterangan = null;
                });
              },
              isRequired: true,
            ),
            
            const SizedBox(height: 20),
            
            _buildDateRangeField(),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(child: _buildTimeField(true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeField(false)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildDropdownField(
              label: 'Jenis Pestisida',
              value: selectedPestisida,
              items: _jenisPestisidaOptions,
              onChanged: (value) => setState(() => selectedPestisida = value),
              isRequired: _isPestisidaRequired(),
            ),
            
            const SizedBox(height: 20),
            
            _buildDropdownField(
              label: 'Target Penanaman',
              value: selectedTarget,
              items: _targetPenanamanOptions,
              onChanged: (value) => setState(() => selectedTarget = value),
              isRequired: _isTargetRequired(),
            ),
            
            const SizedBox(height: 20),
            
            _buildDropdownField(
              label: 'Keterangan',
              value: selectedKeterangan,
              items: _keteranganOptions,
              onChanged: (value) => setState(() => selectedKeterangan = value),
              isRequired: _isKeteranganRequired(),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveKegiatan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF62903A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.existingKegiatan == null
                      ? 'Simpan Kegiatan'
                      : 'Perbarui Kegiatan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (!isRequired)
              Text(
                ' (Opsional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: 'Pilih $label',
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: isRequired ? (value) => value == null ? 'Wajib diisi' : null : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal (Rentang)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 1),
              lastDate: DateTime(DateTime.now().year + 4),
              initialDateRange: selectedRange,
              locale: const Locale('id', 'ID'),
              saveText: 'Simpan',
              helpText: 'Pilih Rentang Tanggal',
              cancelText: 'Batal',
              confirmText: 'Simpan',
              fieldStartLabelText: 'Tanggal Mulai',
              fieldEndLabelText: 'Tanggal Selesai',
              fieldStartHintText: 'dd/mm/yyyy',
              fieldEndHintText: 'dd/mm/yyyy',
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF62903A),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => selectedRange = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatRange(selectedRange),
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedRange == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey.shade700, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(bool isStart) {
    final time = isStart ? waktuMulai : waktuSelesai;
    final label = isStart ? 'Waktu Mulai' : 'Waktu Selesai';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? const TimeOfDay(hour: 7, minute: 0),
              helpText: 'Pilih Waktu',
              cancelText: 'Batal',
              confirmText: 'Simpan',
              hourLabelText: 'Jam',
              minuteLabelText: 'Menit',
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF62903A),
                      ),
                    ),
                    child: child!,
                  ),
                );
              },
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  waktuMulai = picked;
                } else {
                  waktuSelesai = picked;
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time == null ? 'Pilih waktu' : _formatTime(time),
                  style: TextStyle(
                    fontSize: 16,
                    color: time == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
                Icon(Icons.access_time, color: Colors.grey.shade700, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
