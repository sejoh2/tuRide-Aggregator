import 'package:flutter/material.dart';

class ScheduleRideTile extends StatelessWidget {
  const ScheduleRideTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Clock Icon in light box
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.access_time, color: Colors.black54),
          ),
          const SizedBox(width: 12),

          // Text Column
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule a ride",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Text(
                  "Plan ahead for your trip",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),

          // Arrow Icon
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
        ],
      ),
    );
  }
}
