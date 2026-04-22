import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/mattress_model.dart';
import '../providers/app_provider.dart';

class MattressScreen extends StatefulWidget {
  const MattressScreen({super.key});

  @override
  State<MattressScreen> createState() => _MattressScreenState();
}

class _MattressScreenState extends State<MattressScreen>
    with SingleTickerProviderStateMixin {
  double _rotateY = 0.3;
  double _startDragX = 0;
  double _startRotateY = 0;
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    _returnController.stop();
    _startDragX = d.localPosition.dx;
    _startRotateY = _rotateY;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _rotateY = (_startRotateY + (d.localPosition.dx - _startDragX) / 120)
          .clamp(-1.2, 1.2);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    _returnAnimation = Tween<double>(begin: _rotateY, end: 0.3).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.elasticOut),
    )..addListener(() => setState(() => _rotateY = _returnAnimation.value));
    _returnController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final state = provider.state;

    final bgColor = isDark ? const Color(0xFF04050B) : const Color(0xFFF0EAD9);
    final t1 = isDark ? const Color(0xFFE2EAF8) : const Color(0xFF2A1F12);
    final t2 = isDark ? const Color(0xFF4E5A78) : const Color(0xFF8A7A60);
    final cardColor = isDark
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.55);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.055)
        : const Color(0xFF3C2D19).withOpacity(0.1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Text('Matrax',
                      style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: t1)),
                  const Spacer(),
                  GestureDetector(
                    onTap: provider.toggleTheme,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: t2,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ShapeButton(
                    label: 'Квадратный\nX×X',
                    isActive: state.shape == MattressShape.square,
                    onTap: () => provider.setShape(MattressShape.square),
                    t1: t1, t2: t2,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _ShapeButton(
                    label: 'Прямоугольный\nX×Y',
                    isActive: state.shape == MattressShape.rect,
                    onTap: () => provider.setShape(MattressShape.rect),
                    t1: t1, t2: t2,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Center(
                  child: _Mattress3D(
                    state: state,
                    rotateY: _rotateY,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Compass(direction: state.direction, isDark: isDark, t1: t1, t2: t2),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Сторона', value: state.side == Side.a ? 'A' : 'B', t1: t1, t2: t2),
                    Container(width: 1, height: 32, color: borderColor),
                    _StatItem(label: 'Изголовье', value: _dirShort(state.direction), t1: t1, t2: t2),
                    Container(width: 1, height: 32, color: borderColor),
                    _StatItem(label: 'Шаг', value: '${state.step}/${state.maxSteps}', t1: t1, t2: t2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dirShort(Direction d) {
    switch (d) {
      case Direction.north: return 'С';
      case Direction.east:  return 'В';
      case Direction.south: return 'Ю';
      case Direction.west:  return 'З';
    }
  }
}

// ─── 3D Mattress ─────────────────────────────────────────────────────────────

class _Mattress3D extends StatelessWidget {
  final MattressState state;
  final double rotateY;
  final bool isDark;

  const _Mattress3D({
    required this.state,
    required this.rotateY,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSquare = state.shape == MattressShape.square;
    final isSideA  = state.side == Side.a;

    final w     = isSquare ? 190.0 : 165.0;
    final h     = isSquare ? 190.0 : 220.0;
    const depth = 36.0;

    final topA = isDark
        ? [const Color(0xFF2a2438), const Color(0xFF1a1828)]
        : [const Color(0xFFe8dcc0), const Color(0xFFc9b790)];
    final topB = isDark
        ? [const Color(0xFF2d1f1a), const Color(0xFF1d1410)]
        : [const Color(0xFFf0cc8a), const Color(0xFFd9a65a)];

    final sideTopColor = isDark ? const Color(0xFF15182a) : const Color(0xFFb8a880);
    final sideBotColor = isDark ? const Color(0xFF07080f) : const Color(0xFF8a7050);
    final sideLtColor  = isDark ? const Color(0xFF1a1d30) : const Color(0xFFc0a870);
    final sideRtColor  = isDark ? const Color(0xFF0d0f1e) : const Color(0xFF907850);

    final topColors  = isSideA ? topA : topB;
    final labelColor = isSideA
        ? (isDark ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.55))
        : (isDark ? const Color(0xFFFFB464).withOpacity(0.9) : const Color(0xFF8B3700));

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0008)
      ..rotateX(0.28)
      ..rotateY(rotateY);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: SizedBox(
        width:  w + 80,
        height: h + depth + 60,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // Bottom (front) depth face
            Positioned(
              left: 40,
              bottom: 10,
              child: Transform(
                transform: Matrix4.identity()..rotateX(1.5708),
                alignment: Alignment.topCenter,
                child: Container(
                  width: w,
                  height: depth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [sideTopColor, sideBotColor],
                    ),
                  ),
                ),
              ),
            ),

            // Right depth face
            Positioned(
              right: 18,
              top: 30,
              child: Transform(
                transform: Matrix4.identity()..rotateY(-1.5708),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: depth,
                  height: h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [sideLtColor, sideRtColor],
                    ),
                  ),
                ),
              ),
            ),

            // Top face
            Positioned(
              left: 40,
              top: 30,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: topColors,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.55 : 0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _QuiltPainter(isDark: isDark),
                        size: Size(w, h),
                      ),
                      Center(
                        child: Text(
                          isSideA ? 'A' : 'B',
                          style: GoogleFonts.syne(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: labelColor,
                          ),
                        ),
                      ),
                      // HEAD
                      Positioned(
                        top: 10, left: 0, right: 0,
                        child: Center(child: _FaceLabel('HEAD')),
                      ),
                      // FOOT
                      Positioned(
                        bottom: 10, left: 0, right: 0,
                        child: Center(child: _FaceLabel('FOOT')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceLabel extends StatelessWidget {
  final String text;
  const _FaceLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.45),
        ),
      ),
    );
  }
}

class _QuiltPainter extends CustomPainter {
  final bool isDark;
  _QuiltPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawRect(Rect.fromLTWH(x + 3, y + 3, step - 6, step - 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_QuiltPainter old) => old.isDark != isDark;
}

// ─── Compass ─────────────────────────────────────────────────────────────────

class _Compass extends StatelessWidget {
  final Direction direction;
  final bool isDark;
  final Color t1, t2;

  const _Compass({
    required this.direction,
    required this.isDark,
    required this.t1,
    required this.t2,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.6);
    final active = isDark ? const Color(0xFF4F8EF7) : const Color(0xFF1E5BC9);
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _CLabel('С', Alignment.topCenter,    direction == Direction.north, active, t2),
          _CLabel('В', Alignment.centerRight,  direction == Direction.east,  active, t2),
          _CLabel('Ю', Alignment.bottomCenter, direction == Direction.south, active, t2),
          _CLabel('З', Alignment.centerLeft,   direction == Direction.west,  active, t2),
          Container(width: 5, height: 5,
              decoration: BoxDecoration(color: t2, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class _CLabel extends StatelessWidget {
  final String label;
  final Alignment alignment;
  final bool isActive;
  final Color activeColor, inactiveColor;

  const _CLabel(this.label, this.alignment, this.isActive,
      this.activeColor, this.inactiveColor);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            )),
      ),
    );
  }
}

// ─── Shape button ─────────────────────────────────────────────────────────────

class _ShapeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color t1, t2, cardColor, borderColor;
  final bool isDark;

  const _ShapeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.t1,
    required this.t2,
    required this.cardColor,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active = isDark ? const Color(0xFF4F8EF7) : const Color(0xFF1E5BC9);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? active.withOpacity(0.12) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? active.withOpacity(0.4) : borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? active : t2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat item ────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color t1, t2;

  const _StatItem({
    required this.label,
    required this.value,
    required this.t1,
    required this.t2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.syne(
                fontSize: 20, fontWeight: FontWeight.w800, color: t1)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: t2)),
      ],
    );
  }
}