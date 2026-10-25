import 'package:flutter/material.dart';

/// Sunny — the app mascot. A little orange friend with a leaf.
/// [mood] from 1 (sad) to 5 (very happy) changes the face.
class Mascot extends StatefulWidget {
  const Mascot({super.key, this.size = 100, this.mood = 4});

  final double size;
  final int mood;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -widget.size * 0.04 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _MascotPainter(widget.mood),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.mood);

  final int mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final body = Paint()..color = const Color(0xFFFF8A3D);
    final belly = Paint()..color = const Color(0xFFFFB57E);
    final leaf = Paint()..color = const Color(0xFF6CBF4B);
    final dark = Paint()..color = const Color(0xFF3B2A20);
    final white = Paint()..color = Colors.white;
    final cheek = Paint()..color = const Color(0x66F2557A);

    // Shadow on the ground
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s * 0.5, s * 0.96), width: s * 0.5, height: s * 0.06),
      Paint()..color = const Color(0x22000000),
    );

    // Stem and leaf
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s * 0.5, s * 0.17), width: s * 0.04, height: s * 0.1),
        Radius.circular(s * 0.02),
      ),
      leaf,
    );
    canvas.save();
    canvas.translate(s * 0.6, s * 0.12);
    canvas.rotate(-0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 0.22, height: s * 0.11), leaf);
    canvas.restore();

    // Body
    canvas.drawCircle(Offset(s * 0.5, s * 0.56), s * 0.38, body);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s * 0.5, s * 0.72), width: s * 0.46, height: s * 0.28),
      belly,
    );

    // Eyes
    for (final x in [0.39, 0.61]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s * x, s * 0.5), width: s * 0.085, height: s * 0.115),
        dark,
      );
      canvas.drawCircle(Offset(s * (x + 0.012), s * 0.48), s * 0.016, white);
    }

    // Cheeks
    canvas.drawCircle(Offset(s * 0.3, s * 0.6), s * 0.045, cheek);
    canvas.drawCircle(Offset(s * 0.7, s * 0.6), s * 0.045, cheek);

    // Mouth
    final mouth = Paint()
      ..color = const Color(0xFF3B2A20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    final path = Path();
    if (mood >= 4) {
      final depth = mood == 5 ? 0.72 : 0.68;
      path.moveTo(s * 0.43, s * 0.62);
      path.quadraticBezierTo(s * 0.5, s * depth, s * 0.57, s * 0.62);
    } else if (mood == 3) {
      path.moveTo(s * 0.44, s * 0.645);
      path.lineTo(s * 0.56, s * 0.645);
    } else {
      path.moveTo(s * 0.43, s * 0.67);
      path.quadraticBezierTo(s * 0.5, s * 0.6, s * 0.57, s * 0.67);
    }
    canvas.drawPath(path, mouth);
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) => oldDelegate.mood != mood;
}
