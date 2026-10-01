import 'package:flutter/material.dart';

class MoveLegend extends StatelessWidget {
  const MoveLegend({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'CHÚ THÍCH KÝ HIỆU',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Đóng chú thích',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'CÁC MẶT',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1670D2),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              Text('U = Mặt trên'),
              Text('D = Mặt dưới'),
              Text('R = Mặt phải'),
              Text('L = Mặt trái'),
              Text('F = Mặt trước'),
              Text('B = Mặt sau'),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'CÁCH XOAY',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1670D2),
            ),
          ),
          const SizedBox(height: 12),
          const _Turn(
            'R',
            Icons.rotate_right,
            'Xoay mặt phải 90° theo chiều kim đồng hồ.',
          ),
          const _Turn(
            "R'",
            Icons.rotate_left,
            'Xoay mặt phải 90° ngược chiều kim đồng hồ.',
          ),
          const _Turn('R2', Icons.sync, 'Xoay mặt phải 180°.'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Chiều xoay được tính khi nhìn thẳng vào chính mặt đang xoay.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF24466F),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Turn extends StatelessWidget {
  const _Turn(this.symbol, this.icon, this.description);
  final String symbol;
  final IconData icon;
  final String description;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
        ),
        Icon(icon, color: const Color(0xFF1670D2)),
        const SizedBox(width: 12),
        Expanded(child: Text(description)),
      ],
    ),
  );
}
