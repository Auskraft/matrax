import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mattress_model.dart';
import '../providers/app_provider.dart';

class ChangeScreen extends StatelessWidget {
  const ChangeScreen({super.key});

  String _dirName(Direction d) {
    switch (d) {
      case Direction.north: return 'Север';
      case Direction.east: return 'Восток';
      case Direction.south: return 'Юг';
      case Direction.west: return 'Запад';
    }
  }

  String _sideName(Side s) => s == Side.a ? 'Сторона A' : 'Сторона B';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final state = provider.state;
    final next = state.nextStep();

    final bgColor = isDark ? const Color(0xFF04050B) : const Color(0xFFF0EAD9);
    final cardColor = isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.55);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.055)
        : const Color(0xFF3C2D19).withOpacity(0.1);
    final t1 = isDark ? const Color(0xFFE2EAF8) : const Color(0xFF2A1F12);
    final t2 = isDark ? const Color(0xFF4E5A78) : const Color(0xFF8A7A60);
    final green = isDark ? const Color(0xFF00E5A0) : const Color(0xFF058F5F);
    final orange = isDark ? const Color(0xFFFF8C00) : const Color(0xFFB84A00);

    final flipped = state.side != next.side;
    final rotated = state.shape == MattressShape.square &&
        state.direction != next.direction;
    final turned = state.shape == MattressShape.rect &&
        state.direction != next.direction;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Смена',
                style: GoogleFonts.syne(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: t1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Рекомендация на следующую ротацию',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: t2),
              ),
              const SizedBox(height: 24),

              // Current state card
              _InfoCard(
                title: 'Сейчас',
                content: '${_sideName(state.side)} · ${_dirName(state.direction)}',
                cardColor: cardColor,
                borderColor: borderColor,
                t1: t1,
                t2: t2,
              ),
              const SizedBox(height: 12),

              // Arrow
              Center(
                child: Icon(Icons.arrow_downward, color: green, size: 28),
              ),
              const SizedBox(height: 12),

              // Next state card
              _InfoCard(
                title: 'Следующий шаг',
                content: '${_sideName(next.side)} · ${_dirName(next.direction)}',
                cardColor: cardColor,
                borderColor: borderColor,
                t1: t1,
                t2: t2,
                highlight: green,
              ),
              const SizedBox(height: 20),

              // Actions description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что нужно сделать:',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (flipped)
                      _ActionRow(
                        icon: Icons.flip,
                        label: 'Перевернуть матрас на другую сторону',
                        color: orange,
                      ),
                    if (rotated)
                      _ActionRow(
                        icon: Icons.rotate_right,
                        label: 'Повернуть на 90° вправо',
                        color: isDark
                            ? const Color(0xFF4F8EF7)
                            : const Color(0xFF1E5BC9),
                      ),
                    if (turned)
                      _ActionRow(
                        icon: Icons.swap_vert,
                        label: 'Развернуть изголовье ↔ ногами',
                        color: isDark
                            ? const Color(0xFF4F8EF7)
                            : const Color(0xFF1E5BC9),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.confirmChange();
                    HapticFeedback.mediumImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Смена подтверждена!',
                            style: GoogleFonts.syne(),
                          ),
                          backgroundColor: green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Подтвердить смену',
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary buttons
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Экспорт JSON',
                      icon: Icons.upload_outlined,
                      t1: t1,
                      borderColor: borderColor,
                      cardColor: cardColor,
                      onTap: () {
                        final json = provider.exportJson();
                        Share.share(json, subject: 'Matrax export');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Сброс',
                      icon: Icons.restart_alt_outlined,
                      t1: const Color(0xFFFF5E5E),
                      borderColor: const Color(0xFFFF5E5E).withOpacity(0.3),
                      cardColor: const Color(0xFFFF5E5E).withOpacity(0.06),
                      onTap: () => _confirmReset(context, provider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Сброс', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('Сбросить все данные и начать заново?', style: GoogleFonts.syne()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: GoogleFonts.syne()),
          ),
          TextButton(
            onPressed: () {
              provider.resetAll();
              Navigator.pop(ctx);
            },
            child: Text(
              'Сбросить',
              style: GoogleFonts.syne(color: const Color(0xFFFF5E5E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Color cardColor;
  final Color borderColor;
  final Color t1;
  final Color t2;
  final Color? highlight;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.cardColor,
    required this.borderColor,
    required this.t1,
    required this.t2,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight != null ? highlight!.withOpacity(0.3) : borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: t2)),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: highlight ?? t1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.syne(fontSize: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color t1;
  final Color borderColor;
  final Color cardColor;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.t1,
    required this.borderColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: t1),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}