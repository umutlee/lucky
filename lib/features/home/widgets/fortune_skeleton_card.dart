import 'package:flutter/material.dart';

class FortuneSkeleton extends StatefulWidget {
  final String type;

  const FortuneSkeleton({
    super.key,
    required this.type,
  });

  @override
  State<FortuneSkeleton> createState() => _FortuneSkeletonState();
}

class _FortuneSkeletonState extends State<FortuneSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildShimmer(24, 24), // Icon
                    const SizedBox(width: 8),
                    _buildShimmer(80, 24), // Title
                  ],
                ),
                _buildShimmer(48, 24), // Score
              ],
            ),
            const SizedBox(height: 16),
            _buildShimmer(double.infinity, 16), // Description line 1
            const SizedBox(height: 8),
            _buildShimmer(200, 16), // Description line 2
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildShimmer(60, 16), // Label
                const SizedBox(width: 8),
                _buildShimmer(120, 16), // Value
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildShimmer(60, 16), // Label
                const SizedBox(width: 8),
                _buildShimmer(100, 16), // Value
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(double width, double height) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox.shrink(),
        );
      },
    );
  }
} 