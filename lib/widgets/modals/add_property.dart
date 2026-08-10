import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';

import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../custom_button.dart';

class AddPropertyModal extends StatefulWidget {
  const AddPropertyModal({super.key});

  @override
  State<AddPropertyModal> createState() => _AddPropertyModalState();
}

class _AddPropertyModalState extends State<AddPropertyModal> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _area = "Adebayo, Ado-Ekiti";
  String _citySlug = "ado-ekiti";
  double _price = 850000;
  int _beds = 2;
  int _baths = 2;
  int _sqft = 900;
  String _type = "Apartment";
  final String _status = "Verified";
  String _description = "";
  final String _imageUrl =
      "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80";

  final List<String> _cities = [
    "ado-ekiti",
    "ikere-ekiti",
    "iworoko-ekiti",
    "ikole-ekiti",
  ];
  final List<String> _types = [
    "Flat",
    "Apartment",
    "Self-contained",
    "Hostel",
    "Single Room",
    "Duplex",
    "Mini Flat",
    "Bungalow",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<UserProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkLine : AppColors.line,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.circle_plus,
                      color: AppColors.forest,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "List a New Property",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                        ),
                      ),
                      Text(
                        "Direct-from-Landlord or Verified Agent",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: isDark ? AppColors.darkLine : AppColors.line),
              const SizedBox(height: 12),

              // Title
              TextFormField(
                decoration: _inputDecoration(
                  "Property Title (e.g. Modern 2-Bed Flat)",
                  isDark,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter a title" : null,
                onSaved: (v) => _title = v ?? "",
              ),
              const SizedBox(height: 12),

              // Area / Neighborhood
              TextFormField(
                initialValue: _area,
                decoration: _inputDecoration(
                  "Area / Address (e.g. Adebayo, Ado-Ekiti)",
                  isDark,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter address" : null,
                onSaved: (v) => _area = v ?? "",
              ),
              const SizedBox(height: 12),

              // Row for City & Type dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _citySlug,
                      decoration: _inputDecoration("City", isDark),
                      items: _cities
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _citySlug = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: _inputDecoration("Property Type", isDark),
                      items: _types
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price & Sqft
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "850000",
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Annual Rent (₦)", isDark),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                      onSaved: (v) =>
                          _price = double.tryParse(v ?? "0") ?? 850000,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: "900",
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Est. Sqft", isDark),
                      onSaved: (v) => _sqft = int.tryParse(v ?? "0") ?? 900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Beds & Baths
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "2",
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Bedrooms", isDark),
                      onSaved: (v) => _beds = int.tryParse(v ?? "1") ?? 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: "2",
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Bathrooms", isDark),
                      onSaved: (v) => _baths = int.tryParse(v ?? "1") ?? 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                decoration: _inputDecoration(
                  "Property Description & Features",
                  isDark,
                ),
                maxLines: 2,
                onSaved: (v) => _description = v ?? "",
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: "Publish Listing Immediately",
                isTerracotta: true,
                width: double.infinity,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newProp = Property(
                      id: "rh-custom-${DateTime.now().millisecondsSinceEpoch}",
                      title: _title,
                      area: _area,
                      citySlug: _citySlug,
                      price: _price,
                      beds: _beds,
                      baths: _baths,
                      sqft: _sqft,
                      type: _type,
                      status: _status,
                      agent: Agent(
                        name: user.name,
                        role: "Landlord (Verified)",
                        phone: user.phone,
                      ),
                      image: _imageUrl,
                      description: _description.isEmpty
                          ? "Newly listed property direct from verified landlord. Immaculate state with continuous water and power access."
                          : _description,
                      isFeatured: true,
                    );

                    context.read<PropertyProvider>().addProperty(newProp);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.forest,
                        content: const Text(
                          "Property listed successfully!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? AppColors.darkMuted : AppColors.muted,
        fontSize: 12,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkLine : AppColors.line,
        ),
      ),
    );
  }
}
