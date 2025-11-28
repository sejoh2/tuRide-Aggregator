import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PlatformDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;

  const PlatformDropdown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          hint: const Text(
            "Select platform",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          value: value,
          items: const [
            DropdownMenuItem(value: "Uber", child: Text("Uber")),
            DropdownMenuItem(value: "Bolt", child: Text("Bolt")),
            DropdownMenuItem(value: "Faras", child: Text("Faras")),
            DropdownMenuItem(value: "Yego", child: Text("Yego (Motorbike)")),
            DropdownMenuItem(value: "Little", child: Text("Little")),
          ],
          onChanged: onChanged,
          isExpanded: false,

          // Button styling
          buttonStyleData: ButtonStyleData(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
          ),

          // Dropdown styling
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            offset: const Offset(200, 0), // move dropdown to the right
            // direction: DropdownDirection.right, // optional, ensures right alignment
          ),
        ),
      ),
    );
  }
}
