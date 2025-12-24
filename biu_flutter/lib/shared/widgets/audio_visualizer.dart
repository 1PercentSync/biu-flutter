import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A simulated audio visualizer widget.
///
/// Since just_audio doesn't provide real-time FFT data, this widget
/// creates an animated visualization that responds to playback state.
/// This is a common approach used by many music apps to provide
/// visual feedback without actual audio analysis.
///
/// Source concept: biu/src/components/audio-waveform/index.tsx
/// Note: Source uses Web Audio API's AnalyserNode for real FFT data.
/// Flutter implementation uses animation simulation due to just_audio limitations.
class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({
    super.key,
    this.isPlaying = false,
    this.barCount = 32,
    this.barWidth = 3.0,
    this.barSpacing = 2.0,
    this.minHeight = 0.1,
    this.maxHeight = 1.0,
    this.primaryColor,
    this.secondaryColor,
    this.style = AudioVisualizerStyle.bars,
  });

  /// Whether audio is currently playing
  final bool isPlaying;

  /// Number of bars to display
  final int barCount;

  /// Width of each bar
  final double barWidth;

  /// Spacing between bars
  final double barSpacing;

  /// Minimum bar height as fraction (0.0 to 1.0)
  final double minHeight;

  /// Maximum bar height as fraction (0.0 to 1.0)
  final double maxHeight;

  /// Primary color for bars
  final Color? primaryColor;

  /// Secondary color for gradient effect
  final Color? secondaryColor;

  /// Visual style
  final AudioVisualizerStyle style;

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

/// Visual styles for the audio visualizer
enum AudioVisualizerStyle {
  /// Vertical bars
  bars,

  /// Circular/radial pattern
  circular,

  /// Wave line
  wave,
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _barHeights;
  late List<double> _targetHeights;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => widget.minHeight);
    _targetHeights = List.generate(widget.barCount, (_) => widget.minHeight);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(_updateBars);

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
    if (widget.barCount != oldWidget.barCount) {
      _barHeights = List.generate(widget.barCount, (_) => widget.minHeight);
      _targetHeights = List.generate(widget.barCount, (_) => widget.minHeight);
    }
  }

  void _startAnimation() {
    _generateTargetHeights();
    _controller.repeat();
  }

  void _stopAnimation() {
    _controller.stop();
    // Animate bars down to minimum
    setState(() {
      _targetHeights = List.generate(widget.barCount, (_) => widget.minHeight);
    });
  }

  void _generateTargetHeights() {
    for (var i = 0; i < widget.barCount; i++) {
      _targetHeights[i] = widget.minHeight +
          _random.nextDouble() * (widget.maxHeight - widget.minHeight);
    }
  }

  void _updateBars() {
    if (!mounted) return;

    setState(() {
      for (var i = 0; i < widget.barCount; i++) {
        // Smooth interpolation towards target
        final diff = _targetHeights[i] - _barHeights[i];
        _barHeights[i] += diff * 0.3;
      }
    });

    // Generate new targets periodically
    if (_controller.value > 0.9) {
      _generateTargetHeights();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? AppColors.primary;
    final secondary = widget.secondaryColor ?? primary.withValues(alpha: 0.5);

    switch (widget.style) {
      case AudioVisualizerStyle.bars:
        return _buildBars(primary, secondary);
      case AudioVisualizerStyle.circular:
        return _buildCircular(primary, secondary);
      case AudioVisualizerStyle.wave:
        return _buildWave(primary, secondary);
    }
  }

  Widget _buildBars(Color primary, Color secondary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (index) {
            final height = _barHeights[index] * availableHeight;
            return Container(
              width: widget.barWidth,
              height: height.clamp(2.0, availableHeight),
              margin: EdgeInsets.symmetric(horizontal: widget.barSpacing / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [primary, secondary],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCircular(Color primary, Color secondary) {
    return CustomPaint(
      painter: _CircularVisualizerPainter(
        barHeights: _barHeights,
        primaryColor: primary,
        secondaryColor: secondary,
      ),
    );
  }

  Widget _buildWave(Color primary, Color secondary) {
    return CustomPaint(
      painter: _WaveVisualizerPainter(
        barHeights: _barHeights,
        primaryColor: primary,
        secondaryColor: secondary,
      ),
    );
  }
}

class _CircularVisualizerPainter extends CustomPainter {
  _CircularVisualizerPainter({
    required this.barHeights,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<double> barHeights;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;
    final barCount = barHeights.length;
    final angleStep = 2 * pi / barCount;

    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < barCount; i++) {
      final angle = i * angleStep - pi / 2;
      final barLength = radius * 0.5 * barHeights[i];

      final startX = center.dx + radius * cos(angle);
      final startY = center.dy + radius * sin(angle);
      final endX = center.dx + (radius + barLength) * cos(angle);
      final endY = center.dy + (radius + barLength) * sin(angle);

      paint.color =
          Color.lerp(primaryColor, secondaryColor, barHeights[i]) ?? primaryColor;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(_CircularVisualizerPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights;
  }
}

class _WaveVisualizerPainter extends CustomPainter {
  _WaveVisualizerPainter({
    required this.barHeights,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<double> barHeights;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (barHeights.isEmpty) return;

    final path = Path();
    final barCount = barHeights.length;
    final stepX = size.width / (barCount - 1);
    final midY = size.height / 2;

    path.moveTo(0, midY - barHeights[0] * midY);

    for (var i = 1; i < barCount; i++) {
      final x = i * stepX;
      final y = midY - barHeights[i] * midY;
      final prevX = (i - 1) * stepX;
      final prevY = midY - barHeights[i - 1] * midY;

      // Smooth curve using quadratic bezier
      final controlX = (prevX + x) / 2;
      path.quadraticBezierTo(prevX, prevY, controlX, (prevY + y) / 2);
    }

    // Complete to last point
    path.lineTo(size.width, midY - barHeights.last * midY);

    // Mirror for bottom half
    for (var i = barCount - 1; i >= 0; i--) {
      final x = i * stepX;
      final y = midY + barHeights[i] * midY;
      path.lineTo(x, y);
    }

    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor, secondaryColor, primaryColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveVisualizerPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights;
  }
}

/// Compact visualizer for use in playbar/mini player.
class MiniAudioVisualizer extends StatelessWidget {
  const MiniAudioVisualizer({
    super.key,
    this.isPlaying = false,
    this.size = 24,
    this.color,
  });

  final bool isPlaying;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AudioVisualizer(
        isPlaying: isPlaying,
        barCount: 4,
        barWidth: size / 8,
        barSpacing: size / 16,
        minHeight: 0.2,
        primaryColor: color ?? AppColors.primary,
      ),
    );
  }
}
