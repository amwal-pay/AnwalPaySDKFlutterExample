import 'package:flutter/material.dart';

class DropdownForm<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final T? initialValue;
  final String Function(T) nameMapper;
  final String Function(T) valueMapper;
  final void Function(String?) onChanged;

  const DropdownForm({
    super.key,
    required this.title,
    required this.options,
    this.initialValue,
    required this.nameMapper,
    required this.valueMapper,
    required this.onChanged,
  });

  @override
  State<DropdownForm<T>> createState() => _DropdownFormState<T>();
}

class _DropdownFormState<T> extends State<DropdownForm<T>> {
  String? selectedValue;
  final GlobalKey _dropdownKey = GlobalKey(); // Key to get the widget position

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue != null
        ? widget.nameMapper(widget.initialValue as T)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          const SizedBox(height: 12),
          GestureDetector(
            key: _dropdownKey, // Attach the key to the widget
            onTap: () {
              _showCustomDropdown();
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  )),
              child: Text(
                selectedValue ?? 'Select an option',
                style: TextStyle(
                    color: selectedValue == null ? Colors.grey : Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Custom dropdown function using PopupMenuButton
  void _showCustomDropdown() async {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(
      Offset.zero,
    ); // Get the position of the widget

    final T? selectedItem = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx,
        0.0,
      ),
      items: widget.options.map((T option) {
        return PopupMenuItem<T>(
          value: option,
          child: SizedBox(
            width: 200, // Set a fixed width for the dropdown
            child: Text(
              widget.nameMapper(option),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
      elevation: 8.0,
    );

    if (selectedItem != null) {
      widget.onChanged(widget.valueMapper(selectedItem));
      setState(() {
        selectedValue = widget.nameMapper(selectedItem);
      });
    }
  }
}
