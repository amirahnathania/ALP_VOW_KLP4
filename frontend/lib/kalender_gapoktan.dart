part of 'home_gapoktan.dart';

mixin _HomeSectionsMixin on _HomePageStateBase {
  Widget _buildNavbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1D8),
          border: Border.all(color: const Color(0xFFF5F1D8), width: 2),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: _withOpacity(Colors.black, 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavButton(
              icon: Icons.calendar_month,
              label: 'Kalender',
              isActive: _activeSection == HomeSection.calendar,
              onTap: () =>
                  setState(() => _activeSection = HomeSection.calendar),
            ),
            _NavButton(
              icon: Icons.home,
              label: 'Dashboard',
              isActive: _activeSection == HomeSection.dashboard,
              onTap: () =>
                  setState(() => _activeSection = HomeSection.dashboard),
            ),
            _NavButton(
              icon: Icons.person,
              label: 'Profil',
              isActive: _activeSection == HomeSection.profile,
              onTap: () => setState(() => _activeSection = HomeSection.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_activeSection) {
      case HomeSection.calendar:
        return _buildCalendarSection();
      case HomeSection.dashboard:
        return _buildDashboardSection();
      case HomeSection.profile:
        return _buildProfileSection();
    }
  }

  Widget _buildCalendarSection() {
    final selectedEvents = _eventsOfDay(_selectedDay ?? DateTime.now());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _withOpacity(_primaryGray, 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: _withOpacity(Colors.black, 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    const SizedBox(height: 8),
                    TableCalendar<Kegiatan>(
                      locale: 'id',
                      firstDay: DateTime.utc(2018, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Bulan',
                        CalendarFormat.twoWeeks: '2 Pekan',
                        CalendarFormat.week: 'Pekan',
                      },
                      eventLoader: _eventsOfDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerVisible: false,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        selectedDecoration: BoxDecoration(
                          border: Border.all(color: _primaryBrown, width: 2),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          border: Border.all(color: _primaryGreen, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day),
                        todayBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day, highlightToday: true),
                        selectedBuilder: (context, day, focusedDay) =>
                            _buildDayCell(day, isSelected: true),
                      ),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                        _openActionsForDay(selected);
                      },
                      onPageChanged: (focused) =>
                          setState(() => _focusedDay = focused),
                      onFormatChanged: (format) =>
                          setState(() => _calendarFormat = format),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'add-kegiatan',
                  mini: true,
                  backgroundColor: _navButton,
                  onPressed: () => _openEventForm(),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SizedBox(height: 6),
          Text(
            selectedEvents.isEmpty
                ? 'Belum ada kegiatan pada tanggal ini'
                : 'Kegiatan pada ${_dateFormatter.format(_selectedDay ?? DateTime.now())}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedEvents.isEmpty ? _primaryGray : _primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...selectedEvents.map(_buildEventCard),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month - 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _monthFormatter.format(_focusedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kalender Kegiatan',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool highlightToday = false,
    bool isSelected = false,
  }) {
    final events = _eventsOfDay(day);
    final hasOverlap = events.length > 1;
    final hasEvent = events.isNotEmpty;
    LinearGradient? gradient;
    Color? fillColor;
    if (hasEvent) {
      final List<Color> colors = events.map(_colorFor).toList();
      if (hasOverlap) {
        final List<Color> uniqueColors = <Color>[];
        for (final color in colors) {
          if (!uniqueColors.any((c) => c.toARGB32() == color.toARGB32())) {
            uniqueColors.add(color);
          }
        }
        if (uniqueColors.length == 1) {
          fillColor = uniqueColors.first;
        } else {
          gradient = LinearGradient(colors: uniqueColors);
        }
      } else {
        fillColor = colors.first;
      }
    }
    final decoration = hasEvent
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            color: gradient == null ? fillColor : null,
            border: isSelected
                ? Border.all(color: Colors.black, width: 2)
                : highlightToday
                ? Border.all(color: _primaryGray, width: 1.2)
                : null,
          )
        : null;

    return Center(
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: hasEvent ? Colors.white : Colors.black,
            fontWeight: hasEvent ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Kegiatan kegiatan) {
    final accent = _colorFor(kegiatan);
    final hasEvidence = kegiatan.buktiFoto.isNotEmpty;
    final actionButtons = <Widget>[
      TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        onPressed: () => _showDetail(kegiatan),
        child: const Text('Detail'),
      ),
      TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        onPressed: () => _openEventForm(existing: kegiatan),
        child: const Text('Edit'),
      ),
      TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        onPressed: () => _confirmDelete(kegiatan),
        child: const Text('Hapus'),
      ),
      TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.black),
        onPressed: () => _showBuktiFoto(kegiatan),
        child: const Text('Bukti Foto'),
      ),
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _withOpacity(accent, 0.12),
        border: Border.all(color: _withOpacity(accent, 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (kegiatan.keterangan.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        kegiatan.keterangan,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_dateFormatter.format(kegiatan.startDate)} - ${_dateFormatter.format(kegiatan.endDate)}',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: kegiatan.jenisPenanaman),
              _Chip(
                label:
                    'Waktu ${_formatTimeRange(kegiatan.waktuMulai, kegiatan.waktuSelesai)}',
              ),
              _Chip(label: 'Target ${kegiatan.targetPenanaman}'),
              if (kegiatan.jenisPestisida.isNotEmpty)
                _Chip(label: 'Pestisida ${kegiatan.jenisPestisida}'),
            ],
          ),
          const SizedBox(height: 12),
          if (_photoReporterTarget > 0) ...[
            _buildPhotoProgressTile(kegiatan, lightBackground: true),
            if (hasEvidence) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _buildAvatarStack(
                  kegiatan,
                  size: 26,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
            const SizedBox(height: 12),
          ] else if (hasEvidence) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _buildAvatarStack(
                kegiatan,
                size: 26,
                alignment: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      for (var i = 0; i < actionButtons.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: i == actionButtons.length - 1 ? 0 : 8,
                          ),
                          child: actionButtons[i],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection() {
    final sorted = List<Kegiatan>.from(_kegiatan);
    const farmBackgroundAsset = 'assets/foto pertanian.jpg';
    const weatherLocation = 'Kabupaten Gowa';
    const weatherTemperature = '29°C';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: _withOpacity(_primaryGreen, 0.2),
                    backgroundImage: _profilePhotoPath != null
                        ? _imageProviderFor(_profilePhotoPath!)
                        : null,
                    child: _profilePhotoPath == null
                        ? Text(
                            _initialsFor(_profileName),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $_profileName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selamat datang kembali',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(farmBackgroundAsset),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                color: Colors.black.withOpacity(0.35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perkiraan Cuaca',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weatherLocation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      weatherTemperature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'To Do List Kegiatan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: _primaryBrown),
                    onPressed: () => _openEventForm(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (sorted.isEmpty)
                const Text(
                  'Belum ada rencana, tambahkan dari kalender.',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ...sorted.map(_buildTodoTile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodoTile(Kegiatan kegiatan) {
    final accent = _colorFor(kegiatan);
    final hasEvidence = kegiatan.buktiFoto.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(accent, 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDetail(kegiatan),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        kegiatan.jenisPenanaman,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimeRange(
                        kegiatan.waktuMulai,
                        kegiatan.waktuSelesai,
                      ),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_dateFormatter.format(kegiatan.startDate)} - ${_dateFormatter.format(kegiatan.endDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (_photoReporterTarget > 0) ...[
                  const SizedBox(height: 10),
                  _buildPhotoProgressTile(kegiatan),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () => _showBuktiFoto(kegiatan),
                      child: const Text('Bukti Foto'),
                    ),
                    const Spacer(),
                    if (hasEvidence)
                      _buildAvatarStack(
                        kegiatan,
                        size: 34,
                        alignment: Alignment.bottomRight,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoProgressTile(
    Kegiatan kegiatan, {
    bool lightBackground = false,
  }) {
    final progress = _photoProgressValue(kegiatan).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final uploaded = _uploadedPhotoCount(kegiatan);
    final total = _photoReporterTarget;
    final backgroundColor = lightBackground
        ? _withOpacity(Colors.black, 0.08)
        : Colors.white24;
    final valueColor = lightBackground ? _primaryBrown : Colors.white;
    final textColor = lightBackground ? Colors.black87 : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$percent% pelapor mengunggah foto ($uploaded/$total)',
          style: TextStyle(color: textColor, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    final profileItems = [
      _ProfileItem(label: 'Email', value: _profileEmail),
      _ProfileItem(
        label: 'Jabatan',
        value: widget.user['jabatan'] ?? widget.user['role'] ?? '-',
      ),
      _ProfileItem(
        label: 'Awal Masa Jabatan',
        value: widget.user['awal_jabatan'] ?? '-',
      ),
      _ProfileItem(
        label: 'Akhir Masa Jabatan',
        value: widget.user['akhir_jabatan'] ?? '-',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showProfilePhotoActions,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: _primaryGreen,
                  backgroundImage: _profilePhotoPath != null
                      ? _imageProviderFor(_profilePhotoPath!)
                      : null,
                  child: _profilePhotoPath == null
                      ? Text(
                          _initialsFor(_profileName),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 16, color: _primaryBrown),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _EditableProfileField(
            label: 'Nama Pengguna',
            value: _profileName,
            onEdit: _editProfileName,
          ),
          const SizedBox(height: 16),
          ...profileItems.map((item) => _ProfileCard(item: item)),
          const Spacer(),
        ],
      ),
    );
  }
}
