import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;       // The specific form fields you want to inject
  final VoidCallback onSave;  // What happens when they click Save
  final VoidCallback? onCancel; 
  final String saveText;
  final bool isSaving;        // Controls the loading spinner on the button

  const CustomModal({
    super.key,
    required this.title,
    required this.content,
    required this.onSave,
    this.onCancel,
    this.saveText = 'Save',
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF0F8241);
    
    // Matches the light tinted background from your design
    final Color modalBgColor = const Color(0xFFF3F8F4); 

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: modalBgColor,
      insetPadding: const EdgeInsets.all(20), // Keeps it off the screen edges on mobile
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Perfectly scales for Desktop/Tablet
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrinks to fit the content
          children: [
            
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            // --- BODY (Scrollable) ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: content, // This is where your custom text fields will appear!
              ),
            ),

            // --- FOOTER (Buttons) ---
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Red Cancel Button
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : (onCancel ?? () => Navigator.pop(context)),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Green Save Button
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save, color: Colors.white, size: 18),
                    label: Text(isSaving ? 'Saving...' : saveText, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}