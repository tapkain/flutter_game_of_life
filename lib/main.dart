import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(GolApp());
}

class GolDriver {
  final Size gridSize;
  List<List<bool>> grid;

  GolDriver({this.gridSize}) {
    final r = Random();
    grid = List.generate(
      gridSize.height.toInt(),
      (_) => List.generate(
        gridSize.width.toInt(),
        (index) => r.nextDouble() >= 0.91,
      ),
    );
  }

  void iter(Function visitor, [int border = 0]) {
    for (var i = border; i < gridSize.height - border; i++) {
      for (var j = border; j < gridSize.width - border; j++) {
        visitor(i, j);
      }
    }
  }

  int _getAlive(int i, int j) {
    int res = 0;
    for (var k = -1; k <= 1; k++) {
      for (var l = -1; l <= 1; l++) {
        if (grid[i + k][j + l]) {
          res++;
        }
      }
    }

    if (grid[i][j]) {
      res--;
    }

    return res;
  }

  void tick() {
    final future = grid.toList();

    iter(
      (i, j) {
        final alive = _getAlive(i, j);
        if (grid[i][j] && (alive < 2)) {
          future[i][j] = false;
        } else if (grid[i][j] && alive > 3) {
          future[i][j] = false;
        } else if (!grid[i][j] && alive == 3) {
          future[i][j] = true;
        }
      },
      1,
    );

    grid = future;
  }
}

class GolPainter extends CustomPainter {
  final GolDriver driver;

  GolPainter({this.driver});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / driver.gridSize.width;
    final paint = Paint();
    paint.color = Colors.blue;
    driver.iter((i, j) {
      final cell = driver.grid[i][j];
      paint.style = cell ? PaintingStyle.fill : PaintingStyle.stroke;
      canvas.drawRect(
        Rect.fromLTWH(cellSize * j, cellSize * i, cellSize, cellSize),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GolApp extends StatefulWidget {
  @override
  _GolAppState createState() => _GolAppState();
}

class _GolAppState extends State<GolApp> {
  GolDriver driver;
  Timer driverTimer;

  @override
  void initState() {
    driver = GolDriver(gridSize: Size(60, 60));
    driverTimer = Timer.periodic(
      Duration(milliseconds: 100),
      (timer) => setState(() => driver.tick()),
    );
    super.initState();
  }

  @override
  void dispose() {
    driverTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GolPainter(driver: driver),
    );
  }
}
