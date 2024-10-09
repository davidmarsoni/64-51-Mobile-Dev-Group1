import 'package:flutter/material.dart';

class PaymentOption extends StatelessWidget {
  final String title;
  final String pngPath;
  final VoidCallback onSelect;
  final bool isSelected;
  final bool isViewing; 
  final Widget? child;

  const PaymentOption({
    required this.title,
    required this.pngPath,
    required this.onSelect,
    required this.isSelected,
    required this.isViewing,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(pngPath),
            ),
            title: Text(title, style: const TextStyle(fontSize: 18)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: onSelect, 
          ),
          if (isViewing && child != null) child!,
        ],
      ),
    );
  }
}