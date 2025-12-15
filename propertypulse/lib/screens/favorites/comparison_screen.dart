import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../property/property_detail_screen.dart';

class ComparisonScreen extends StatefulWidget {
  final List<PropertyModel> properties;

  const ComparisonScreen({super.key, required this.properties});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final Set<String> _selectedProperties = {};

  @override
  void initState() {
    super.initState();
    // Select first 2 properties by default
    if (widget.properties.length >= 2) {
      _selectedProperties.add(widget.properties[0].id);
      _selectedProperties.add(widget.properties[1].id);
    } else {
      _selectedProperties.addAll(
        widget.properties.map((p) => p.id),
      );
    }
  }

  List<PropertyModel> get _selectedProps {
    return widget.properties
        .where((p) => _selectedProperties.contains(p.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProps = _selectedProps;

    if (selectedProps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Properties')),
        body: const Center(child: Text('Select at least one property to compare')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Properties'),
        actions: [
          if (selectedProps.length >= 2)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedProperties.clear();
                });
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Property selection chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: widget.properties.map((property) {
                final isSelected = _selectedProperties.contains(property.id);
                return FilterChip(
                  label: Text(property.title),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedProperties.length < 3) {
                          _selectedProperties.add(property.id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can compare up to 3 properties'),
                            ),
                          );
                        }
                      } else {
                        _selectedProperties.remove(property.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          // Comparison table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Feature')),
                    ...selectedProps.map(
                      (p) => DataColumn(
                        label: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailScreen(
                                  propertyId: p.id,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (p.imageUrls.isNotEmpty)
                                Image.network(
                                  p.imageUrls.first,
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                ),
                              Text(
                                p.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    _buildRow('Price', selectedProps.map((p) => '\$${p.price.toStringAsFixed(0)}').toList()),
                    _buildRow('Location', selectedProps.map((p) => '${p.city}, ${p.state}').toList()),
                    _buildRow('Bedrooms', selectedProps.map((p) => p.bedrooms?.toString() ?? 'N/A').toList()),
                    _buildRow('Bathrooms', selectedProps.map((p) => p.bathrooms?.toString() ?? 'N/A').toList()),
                    _buildRow('Area (sqft)', selectedProps.map((p) => p.area?.toStringAsFixed(0) ?? 'N/A').toList()),
                    _buildRow('Type', selectedProps.map((p) => p.type.toString().split('.').last).toList()),
                    _buildRow('Parking', selectedProps.map((p) => p.parkingSpaces?.toString() ?? 'N/A').toList()),
                    _buildRow('Year Built', selectedProps.map((p) => p.yearBuilt?.toString() ?? 'N/A').toList()),
                    _buildRow('Features', selectedProps.map((p) => p.features.join(', ')).toList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...values.map((value) => DataCell(Text(value))),
      ],
    );
  }
}

