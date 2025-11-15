import 'package:flutter/material.dart';

class SuggestionTile extends StatelessWidget {
  final Function(int)? onTap;
  final int selectedIndex;

  const SuggestionTile({super.key, this.onTap, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      {'label': 'Rides', 'icon': Icons.directions_car},
      {'label': 'Schedule', 'icon': Icons.access_time},
      {'label': 'Motorbike', 'icon': Icons.pedal_bike},
      {'label': 'Food', 'icon': Icons.fastfood},
      {'label': 'Groceries', 'icon': Icons.inventory_2},
      {'label': 'Drinks', 'icon': Icons.wine_bar},
    ];

    return SizedBox(
      height: 100, // Set a fixed height for tiles
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tiles.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                if (onTap != null) onTap!(index);
              },
              child: Container(
                width: 80, // Width for each tile so 4 fit at a time
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.limeAccent : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tiles[index]['icon'] as IconData,
                      size: 28,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tiles[index]['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
