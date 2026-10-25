import 'package:flutter/material.dart';

enum TipoIlustracion { territorio, saludos, animales, diccionario }

class IlustracionEducativa extends StatelessWidget {
  final TipoIlustracion tipo;
  final double width;
  final double height;

  const IlustracionEducativa({
    super.key,
    required this.tipo,
    this.width = 72,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _IlustracionPainter(tipo),
    );
  }
}

class _IlustracionPainter extends CustomPainter {
  final TipoIlustracion tipo;

  const _IlustracionPainter(this.tipo);

  static const Color _azul = Color(0xFF0B2C49);
  static const Color _turquesa = Color(0xFF29D6C1);
  static const Color _verde = Color(0xFF1A8777);
  static const Color _verdeClaro = Color(0xFF52C8A7);
  static const Color _crema = Color(0xFFFFF2D0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 96);
    switch (tipo) {
      case TipoIlustracion.territorio:
        _pintarTerritorio(canvas);
      case TipoIlustracion.saludos:
        _pintarSaludos(canvas);
      case TipoIlustracion.animales:
        _pintarAnimal(canvas);
      case TipoIlustracion.diccionario:
        _pintarLibro(canvas);
    }
    canvas.restore();
  }

  void _pintarTerritorio(Canvas canvas) {
    canvas.drawCircle(
      const Offset(91, 22),
      13,
      Paint()..color = const Color(0xFFFFD166),
    );
    final lomas = Path()
      ..moveTo(0, 63)
      ..quadraticBezierTo(22, 36, 43, 58)
      ..quadraticBezierTo(63, 39, 82, 57)
      ..quadraticBezierTo(103, 34, 120, 53)
      ..lineTo(120, 96)
      ..lineTo(0, 96)
      ..close();
    canvas.drawPath(lomas, Paint()..color = _verde);
    final rio = Path()
      ..moveTo(0, 72)
      ..quadraticBezierTo(31, 61, 58, 75)
      ..quadraticBezierTo(86, 89, 120, 69)
      ..lineTo(120, 96)
      ..lineTo(0, 96)
      ..close();
    canvas.drawPath(rio, Paint()..color = _azul);
    final reflejo = Paint()
      ..color = _turquesa.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(18, 81), const Offset(45, 81), reflejo);
    canvas.drawLine(const Offset(73, 87), const Offset(101, 87), reflejo);

    final tronco = Paint()
      ..color = const Color(0xFF725339)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(17, 65), const Offset(17, 84), tronco);
    canvas.drawCircle(const Offset(17, 58), 11, Paint()..color = _verdeClaro);
    canvas.drawCircle(const Offset(9, 63), 7, Paint()..color = _verde);
    canvas.drawCircle(const Offset(25, 64), 7, Paint()..color = _verdeClaro);

    final ave = Paint()
      ..color = _crema
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final vuelo = Path()
      ..moveTo(48, 33)
      ..quadraticBezierTo(56, 23, 64, 33)
      ..quadraticBezierTo(72, 23, 81, 31);
    canvas.drawPath(vuelo, ave);
  }

  void _pintarSaludos(Canvas canvas) {
    final globo = RRect.fromRectAndRadius(
      const Rect.fromLTWH(13, 12, 94, 55),
      const Radius.circular(19),
    );
    canvas.drawRRect(globo, Paint()..color = _azul);
    canvas.drawRRect(
      globo,
      Paint()
        ..color = _turquesa
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final cola = Path()
      ..moveTo(34, 63)
      ..lineTo(24, 79)
      ..lineTo(48, 66)
      ..close();
    canvas.drawPath(cola, Paint()..color = _turquesa);
    canvas.drawPath(cola, Paint()..color = _azul);

    final texto = TextPainter(
      text: const TextSpan(
        text: '¡Hola!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(canvas, Offset((120 - texto.width) / 2, 25));

    final destello = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(13, 27), const Offset(5, 22), destello);
    canvas.drawLine(const Offset(108, 74), const Offset(116, 69), destello);
    canvas.drawCircle(const Offset(96, 82), 3, Paint()..color = _turquesa);
  }

  void _pintarAnimal(Canvas canvas) {
    final sombra = Paint()..color = _azul.withOpacity(0.22);
    canvas.drawOval(
      const Rect.fromLTWH(20, 78, 80, 12),
      sombra,
    );

    final oreja = Paint()..color = const Color(0xFF9A6945);
    final orejaInterior = Paint()..color = const Color(0xFFD99D70);
    final orejaIzq = Path()
      ..moveTo(42, 39)
      ..quadraticBezierTo(24, 19, 31, 7)
      ..quadraticBezierTo(49, 12, 55, 36)
      ..close();
    final orejaDer = Path()
      ..moveTo(65, 36)
      ..quadraticBezierTo(74, 12, 92, 10)
      ..quadraticBezierTo(96, 29, 78, 44)
      ..close();
    canvas.drawPath(orejaIzq, oreja);
    canvas.drawPath(orejaDer, oreja);
    final interiorIzq = Path()
      ..moveTo(41, 31)
      ..quadraticBezierTo(35, 19, 35, 14)
      ..quadraticBezierTo(45, 20, 48, 33)
      ..close();
    final interiorDer = Path()
      ..moveTo(73, 33)
      ..quadraticBezierTo(83, 20, 89, 16)
      ..quadraticBezierTo(88, 29, 77, 38)
      ..close();
    canvas.drawPath(interiorIzq, orejaInterior);
    canvas.drawPath(interiorDer, orejaInterior);

    canvas.drawOval(
      const Rect.fromLTWH(34, 31, 53, 55),
      Paint()..color = const Color(0xFFB98255),
    );
    canvas.drawOval(
      const Rect.fromLTWH(43, 56, 42, 25),
      Paint()..color = _crema,
    );
    final ojo = Paint()..color = _azul;
    canvas.drawCircle(const Offset(49, 53), 3, ojo);
    canvas.drawCircle(const Offset(73, 53), 3, ojo);
    canvas.drawOval(
      const Rect.fromLTWH(58, 65, 13, 8),
      Paint()..color = const Color(0xFF725339),
    );
    canvas.drawCircle(const Offset(62, 68), 1.5, Paint()..color = _crema);
    canvas.drawCircle(const Offset(68, 68), 1.5, Paint()..color = _crema);
    canvas.drawArc(
      const Rect.fromLTWH(53, 69, 24, 12),
      0.15,
      2.85,
      false,
      Paint()
        ..color = _azul.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _pintarLibro(Canvas canvas) {
    final sombra = Paint()..color = _azul.withOpacity(0.2);
    canvas.drawOval(const Rect.fromLTWH(17, 79, 86, 10), sombra);

    final izquierda = Path()
      ..moveTo(17, 25)
      ..quadraticBezierTo(40, 20, 58, 34)
      ..lineTo(58, 78)
      ..quadraticBezierTo(37, 65, 17, 70)
      ..close();
    final derecha = Path()
      ..moveTo(62, 34)
      ..quadraticBezierTo(82, 20, 103, 25)
      ..lineTo(103, 70)
      ..quadraticBezierTo(80, 65, 62, 78)
      ..close();
    canvas.drawPath(izquierda, Paint()..color = Colors.white);
    canvas.drawPath(derecha, Paint()..color = _crema);
    canvas.drawPath(izquierda, Paint()..color = _turquesa);
    canvas.drawPath(derecha, Paint()..color = _turquesa);

    final linea = Paint()
      ..color = _azul.withOpacity(0.42)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var y = 43.0; y <= 59; y += 8) {
      canvas.drawLine(Offset(28, y), Offset(49, y + 5), linea);
      canvas.drawLine(Offset(71, y + 5), Offset(92, y), linea);
    }
    canvas.drawLine(
      const Offset(60, 35),
      const Offset(60, 77),
      Paint()
        ..color = _azul
        ..strokeWidth = 3,
    );

    final brote = Paint()
      ..color = _verdeClaro
      ..style = PaintingStyle.fill;
    final hojaIzq = Path()
      ..moveTo(60, 32)
      ..quadraticBezierTo(38, 17, 43, 38)
      ..quadraticBezierTo(54, 40, 60, 32)
      ..close();
    final hojaDer = Path()
      ..moveTo(60, 32)
      ..quadraticBezierTo(82, 17, 77, 38)
      ..quadraticBezierTo(66, 40, 60, 32)
      ..close();
    canvas.drawPath(hojaIzq, brote);
    canvas.drawPath(hojaDer, brote);
    canvas.drawLine(
      const Offset(60, 32),
      const Offset(60, 41),
      Paint()
        ..color = _verde
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _IlustracionPainter oldDelegate) =>
      oldDelegate.tipo != tipo;
}
