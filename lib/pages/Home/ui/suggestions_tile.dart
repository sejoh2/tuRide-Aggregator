import 'package:flutter/material.dart';

class SuggestionTile extends StatefulWidget {
  final Function(int)? onTap;
  const SuggestionTile({super.key, this.onTap});

  @override
  State<SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<SuggestionTile> {
  int selectedIndex = 0; // track selected tile

  final tiles = [
    {'label': 'Rides', 'icon': Icons.directions_car},
    {'label': 'Schedule', 'icon': Icons.access_time},
    {'label': 'Motorbike', 'icon': Icons.pedal_bike},
    {'label': 'Food', 'icon': Icons.fastfood},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tiles.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index; // update selected tile
                });
                if (widget.onTap != null) widget.onTap!(index);
              },
              child: Container(
                width: 80,
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
