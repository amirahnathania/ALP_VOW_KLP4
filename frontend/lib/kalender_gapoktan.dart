part of 'home_gapoktan.dart';

mixin _HomeSectionsMixin on _HomePageStateBase {
  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool hasBadge = false,
  }) {
    final color = isDestructive ? Colors.red.shade700 : _primaryBrown;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _withOpacity(color, 0.4)),
            color: _withOpacity(color, 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (hasBadge) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E0),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(
            icon: Icons.calendar_today_rounded,
            label: 'Kalender',
            isActive: _activeSection == HomeSection.calendar,
            onTap: () {
              setState(() => _activeSection = HomeSection.calendar);
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 4),
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Rumah',
            isActive: _activeSection == HomeSection.dashboard,
            onTap: () {
              setState(() => _activeSection = HomeSection.dashboard);
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 4),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profil',
            isActive: _activeSection == HomeSection.profile,
            onTap: () {
              setState(() => _activeSection = HomeSection.profile);
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF4C7B0F);
    const fgColorActive = Colors.white;
    const fgColorInactive = Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? fgColorActive : fgColorInactive,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: fgColorActive,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
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
    return RefreshIndicator(
      onRefresh: () async {
        await _loadKegiatanFromApi();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
            const SizedBox(height: 24),

            // Header Daftar Kegiatan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Kegiatan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'add-kegiatan',
                  mini: true,
                  backgroundColor: _navButton,
                  onPressed: () => _openEventForm(),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content - Empty state atau list kegiatan
            if (selectedEvents.isEmpty)
              _buildEmptyStateCalendar()
            else
              ...selectedEvents.map(_buildEventCard),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCalendar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar icon with X
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 36,
                  color: Colors.grey.shade400,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada kegiatan hari ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih tanggal lain untuk melihat kegiatan',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
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
      _buildActionChip(
        icon: Icons.info_outline,
        label: 'Detail',
        onTap: () => _showDetail(kegiatan),
      ),
      _buildActionChip(
        icon: Icons.edit_outlined,
        label: 'Edit',
        onTap: () => _openEventForm(existing: kegiatan),
      ),
      _buildActionChip(
        icon: Icons.delete_outline,
        label: 'Hapus',
        onTap: () => _confirmDelete(kegiatan),
        isDestructive: true,
      ),
      _buildActionChip(
        icon: Icons.photo_library_outlined,
        label: 'Bukti Foto',
        onTap: () => _showBuktiFoto(kegiatan),
        hasBadge: hasEvidence,
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

    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama user
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
                          ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Halo, $_profileName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Weather Widget
            _buildWeatherWidget(),

            const SizedBox(height: 20),

            // Daftar Tugas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Tugas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                FloatingActionButton(
                  heroTag: 'add-kegiatan-dashboard',
                  mini: true,
                  backgroundColor: _navButton,
                  onPressed: () => _openEventForm(),
                  child: const Icon(Icons.add, color: Colors.white),
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
      ),
    );
  }

  /// Weather Widget with real API data
  Widget _buildWeatherWidget() {
    final now = DateTime.now();
    final List<String> shortDays = [
      'Min',
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
    ];

    // Default/fallback data jika API gagal
    final currentTemp = _currentWeather?.temperature.round().toString() ?? '32';
    final currentCondition = _currentWeather?.condition ?? 'Cerah';
    final currentIcon = _currentWeather?.icon ?? Icons.wb_sunny_rounded;
    final location = _currentWeather?.location ?? 'Lokasi';

    // Build forecast data
    List<Map<String, dynamic>> weeklyForecast = [];

    if (_forecast != null && _forecast!.isNotEmpty) {
      for (int i = 0; i < _forecast!.length && i < 7; i++) {
        final f = _forecast![i];
        final dayName = i == 0 ? 'Ini' : shortDays[f.date.weekday % 7];
        weeklyForecast.add({
          'day': dayName,
          'isToday': i == 0,
          'icon': f.icon,
          'condition': f.condition,
          'temp': '${f.tempMax.round()}°',
        });
      }
    } else {
      // Fallback data dengan kondisi yang lebih detail
      final fallbackConditions = [
        {'icon': Icons.wb_sunny, 'condition': 'Cerah', 'temp': '32°'},
        {'icon': Icons.cloud_queue, 'condition': 'Berawan', 'temp': '29°'},
        {'icon': Icons.grain, 'condition': 'Gerimis', 'temp': '27°'},
        {'icon': Icons.wb_sunny, 'condition': 'Cerah', 'temp': '31°'},
        {'icon': Icons.cloud, 'condition': 'Mendung', 'temp': '28°'},
        {'icon': Icons.water_drop, 'condition': 'Hujan', 'temp': '26°'},
        {'icon': Icons.wb_sunny, 'condition': 'Cerah', 'temp': '30°'},
      ];
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dayName = i == 0 ? 'Ini' : shortDays[date.weekday % 7];
        weeklyForecast.add({
          'day': dayName,
          'isToday': i == 0,
          ...fallbackConditions[i],
        });
      }
    }

    // Determine gradient colors based on weather condition
    List<Color> _getWeatherGradient(String condition) {
      switch (condition.toLowerCase()) {
        case 'cerah':
        case 'clear':
          // Sky blue gradient - sunny day feel
          return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
        case 'berawan':
        case 'berawan tipis':
        case 'berawan tebal':
        case 'clouds':
          // Soft cloudy sky gradient
          return [const Color(0xFF89ABE3), const Color(0xFFA7C7E7)];
        case 'hujan':
        case 'hujan ringan':
        case 'hujan sedang':
        case 'hujan lebat':
        case 'gerimis':
        case 'rain':
        case 'drizzle':
          // Rainy sky gradient
          return [const Color(0xFF5B86E5), const Color(0xFF36D1DC)];
        case 'badai petir':
        case 'thunderstorm':
          // Stormy gradient
          return [const Color(0xFF373B44), const Color(0xFF4286F4)];
        case 'berkabut':
        case 'kabut':
        case 'mist':
        case 'fog':
          // Misty gradient
          return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
        default:
          // Fresh green gradient - growth feel
          return [const Color(0xFF56AB2F), const Color(0xFFA8E063)];
      }
    }

    final gradientColors = _getWeatherGradient(currentCondition);

    return Container(
      decoration: BoxDecoration(
        // Dynamic gradient based on weather
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Main shadow for depth
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          // Soft ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles for depth (glassmorphism effect)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Cuaca hari ini
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather icon - glassmorphism style
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoadingWeather
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              currentIcon,
                              color: Colors.white,
                              size: 40,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Temperature and condition
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cuaca Hari Ini',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$currentTemp°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentCondition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Location badge
                    GestureDetector(
                      onTap: _loadWeatherData, // Tap to refresh
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 70),
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Prakiraan 7 Hari label
                Text(
                  'Prakiraan 7 Hari',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 14),

                // Weekly forecast row - modern card style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weeklyForecast.map((forecast) {
                      final isToday = forecast['isToday'] == true;
                      return Column(
                        children: [
                          Text(
                            forecast['day'] as String,
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              forecast['icon'] as IconData,
                              color: Colors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            forecast['temp'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
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
    return RefreshIndicator(
      onRefresh: () async => _refreshAll(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Profil',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _showProfilePhotoActions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: _primaryBrown,
                    backgroundImage: _profilePhotoPath != null
                        ? _imageProviderFor(_profilePhotoPath!)
                        : null,
                    child: _profilePhotoPath == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                      child: Icon(Icons.edit, size: 18, color: _primaryBrown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildEditableInfoCard(
              icon: Icons.person_outline,
              title: 'Nama Pengguna',
              value: _profileName,
              onEdit: _editProfileName,
            ),
            const SizedBox(height: 16),
            _buildProfileInfoCard(
              icon: Icons.badge_outlined,
              title: 'Jabatan',
              value:
                  widget.user['jabatan'] ?? widget.user['role'] ?? 'Gapoktan',
            ),
            const SizedBox(height: 16),
            _buildProfileInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: _profileEmail,
            ),
            const SizedBox(height: 16),
            _buildProfileInfoCard(
              icon: Icons.calendar_month_outlined,
              title: 'Awal Masa Jabatan',
              value: _formatDateString(
                widget.user['awalJabatan'] ?? widget.user['awal_jabatan'],
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileInfoCard(
              icon: Icons.event_outlined,
              title: 'Akhir Masa Jabatan',
              value: _formatDateString(
                widget.user['akhirJabatan'] ?? widget.user['akhir_jabatan'],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, size: 16, color: _primaryBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
