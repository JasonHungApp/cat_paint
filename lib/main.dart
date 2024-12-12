import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const CatPaintApp());
}

class CatPaintApp extends StatelessWidget {
  const CatPaintApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Paint App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CatPaintHomePage(),
    );
  }
}

class CatPaintHomePage extends StatefulWidget {
  const CatPaintHomePage({Key? key}) : super(key: key);

  @override
  _CatPaintHomePageState createState() => _CatPaintHomePageState();
}

class _CatPaintHomePageState extends State<CatPaintHomePage> {
  final GlobalKey _paintKey = GlobalKey();
  List<Offset> _points = [];
  Color _selectedColor = Colors.black;
  double _inkLevel = 1.0; // 墨水初始為 100%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ink And Cat Paint App'),
      ),
      body: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox box =
                      _paintKey.currentContext!.findRenderObject() as RenderBox;
                  _points.add(box.globalToLocal(details.globalPosition));
                  _inkLevel = (_inkLevel - 0.003).clamp(0.0, 1.0);
                });
              },
              onPanEnd: (details) => _points.add(Offset.zero),
              child: CustomPaint(
                key: _paintKey,
                size: Size.infinite,
                painter: SketchPainter(_points, _selectedColor),
              ),
            ),
          ),
          _buildInkAndCats(),
        ],
      ),
      bottomNavigationBar: _buildToolBar(),
    );
  }

  Widget _buildToolBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.brush, color: Colors.black),
            onPressed: () => setState(() => _selectedColor = Colors.black),
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () => setState(() => _points.clear()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () => setState(() {
              _points.clear();
              _inkLevel = 1.0;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInkAndCats() {
    return Container(
      width: 80,
      height: 380,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 筆外框
          Column(
            children: [
              // 筆套
              Container(
                height: 30,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
              // 筆芯外層
              Container(
                height: 315,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.black),
                                    borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    //筆芯
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 300,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(10, (index) {
                          return Opacity(
                            opacity:
                                (_inkLevel * 10).ceil() > index ? 1.0 : 1.0,
                            child: Image.asset(
                              'assets/cat_${index + 1}.png', // 預先準備好10隻貓咪圖案
                              height: 30,
                              width: 30,
                            ),
                          );
                        }),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 300 * _inkLevel, // 高度依據墨水量比例動態調整
                        width: 40,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 筆尖
              Container(
                height: 20,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  border: Border.all(color: Colors.black),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(38)),
                ),
              ),
              // 筆頭
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  SketchPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
