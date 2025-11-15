import 'package:flutter/material.dart';

class SortFilterBar extends StatefulWidget {
  const SortFilterBar({super.key});

  @override
  State<SortFilterBar> createState() => _SortFilterBarState();
}

class _SortFilterBarState extends State<SortFilterBar> {
  bool isCheapestSelected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left icon
          const Icon(Icons.sync, color: Colors.purple, size: 24),

          // Centered toggle bar
          Expanded(child: Center(child: _buildToggleBar())),

          // Right filter icon
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.purple),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBar() {
    return GestureDetector(
      onTap: () {
        setState(() => isCheapestSelected = !isCheapestSelected);
      },
      child: Container(
        width: 180,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated sliding background (pill)
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isCheapestSelected
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 90,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Labels (arrow removed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLabel("Cheapest", isCheapestSelected),
                _buildLabel("Fastest", !isCheapestSelected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool selected) {
    return Text(
      text,
      style: TextStyle(
        color: selected ? Colors.purple : Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
