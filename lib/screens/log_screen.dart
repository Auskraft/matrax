import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/mattress_model.dart';
import '../providers/app_provider.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final log = provider.log;
    final scheme = Theme.of(context).colorScheme;

    final bgColor = isDark ? const Color(0xFF04050B) : const Color(0xFFF0EAD9);
    final cardColor = isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.55);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.055)
        : const Color(0xFF3C2D19).withOpacity(0.1);
    final t1 = isDark ? const Color(0xFFE2EAF8) : const Color(0xFF2A1F12);
    final t2 = isDark ? const Color(0xFF4E5A78) : const Color(0xFF8A7A60);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Журнал',
                    style: GoogleFonts.syne(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: t1,
                    ),
                  ),
                  const Spacer(),
                  if (log.isNotEmpty)
                    Text(
                      '${log.length} записей',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: t2,
                      ),
                    ),
                ],
              ),
            ),

            // List
            Expanded(
              child: log.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 48, color: t2),
                    const SizedBox(height: 12),
                    Text(
                      'Журнал пуст',
                      style: GoogleFonts.syne(color: t2, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Подтверди первую смену',
                      style: GoogleFonts.jetBrainsMono(
                          color: t2.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: log.length,
                itemBuilder: (context, index) {
                  final entry = log[index];
                  return _LogCard(
                    entry: entry,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    t1: t1,
                    t2: t2,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final LogEntry entry;
  final Color cardColor;
  final Color borderColor;
  final Color t1;
  final Color t2;
  final bool isDark;

  const _LogCard({
    required this.entry,
    required this.cardColor,
    required this.borderColor,
    required this.t1,
    required this.t2,
    required this.isDark,
  });

  String _dirLabel(Direction d) {
    switch (d) {
      case Direction.north: return 'С';
      case Direction.east: return 'В';
      case Direction.south: return 'Ю';
      case Direction.west: return 'З';
    }
  }

  String _sideLabel(Side s) => s == Side.a ? 'A' : 'B';

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy', 'ru').format(entry.timestamp);
    final time = DateFormat('HH:mm').format(entry.timestamp);
    final green = isDark ? const Color(0xFF00E5A0) : const Color(0xFF058F5F);
    final orange = isDark ? const Color(0xFFFF8C00) : const Color(0xFFB84A00);
    final blue = isDark ? const Color(0xFF4F8EF7) : const Color(0xFF1E5BC9);

    final actions = <Widget>[];
    if (entry.flipped) {
      actions.add(_ActionChip(label: 'flip', color: orange));
    }
    if (entry.rotated) {
      actions.add(_ActionChip(label: 'rotate', color: blue));
    }
    if (entry.turned) {
      actions.add(_ActionChip(label: 'turn', color: blue));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                date,
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: t1,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: t2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StateChip(
                side: _sideLabel(entry.fromSide),
                dir: _dirLabel(entry.fromDir),
                t1: t1,
                t2: t2,
                isDark: isDark,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16, color: green),
              ),
              _StateChip(
                side: _sideLabel(entry.toSide),
                dir: _dirLabel(entry.toDir),
                t1: t1,
                t2: t2,
                isDark: isDark,
              ),
              const Spacer(),
              ...actions,
            ],
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String side;
  final String dir;
  final Color t1;
  final Color t2;
  final bool isDark;

  const _StateChip({
    required this.side,
    required this.dir,
    required this.t1,
    required this.t2,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$side·$dir',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: t1,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}