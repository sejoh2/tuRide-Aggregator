import 'package:flutter/material.dart';

class FilterTabs extends StatefulWidget {
  const FilterTabs({super.key});

  @override
  State<FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> {
  String activeTab = "Standard"; // default active tab

  final List<String> tabs = ["All", "Standard", "Premium", "Female"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          return GestureDetector(
            onTap: () {
              setState(() {
                activeTab = tab;
              });
            },
            child: FilterTab(label: tab, active: activeTab == tab),
          );
        }).toList(),
      ),
    );
  }
}

class FilterTab extends StatelessWidget {
  final String label;
  final bool active;

  const FilterTab({super.key, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.deepPurple : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
