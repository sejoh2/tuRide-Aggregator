import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turide_aggregator/pages/Home/Maps/logic/logic/places_logic.dart';

class LocationTextField extends StatefulWidget {
  final String hintText;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Function(PlaceDetails)? onPlaceSelected;

  const LocationTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.obscureText,
    this.controller,
    this.onPlaceSelected,
  });

  @override
  State<LocationTextField> createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {
  final FocusNode _focusNode = FocusNode();
  List<PlaceSuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus) {
      _clearSuggestions();
    }
  }

  void _clearSuggestions() {
    setState(() {
      _suggestions = [];
    });
  }

  void _searchPlaces(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _clearSuggestions();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading = true;
      });

      final suggestions = await PlacesLogic.searchPlaces(query);

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            obscureText: widget.obscureText,
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: _searchPlaces,
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
                borderRadius: BorderRadius.circular(15),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
          ),
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(
                      suggestion.mainText,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: suggestion.secondaryText.isNotEmpty
                        ? Text(suggestion.secondaryText)
                        : null,
                    onTap: () async {
                      if (widget.controller != null) {
                        widget.controller!.text = suggestion.description;
                      }
                      _focusNode.unfocus();

                      // Get place details if callback provided
                      if (widget.onPlaceSelected != null) {
                        final details = await PlacesLogic.getPlaceDetails(
                          suggestion.placeId,
                        );
                        if (details != null) {
                          widget.onPlaceSelected!(details);
                        }
                      }

                      _clearSuggestions();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
