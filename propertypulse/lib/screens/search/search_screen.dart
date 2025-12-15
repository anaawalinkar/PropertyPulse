import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../property/property_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCity;
  String? _selectedState;
  PropertyType? _selectedType;
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  int? _minBathrooms;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.searchProperties(
      city: _selectedCity,
      state: _selectedState,
      type: _selectedType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minBedrooms: _minBedrooms,
      minBathrooms: _minBathrooms,
      searchQuery: _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Enter keywords, location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Filters',
                          icon: Icons.tune,
                          onTap: () => _showFilterDialog(),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedCity != null)
                          _FilterChip(
                            label: _selectedCity!,
                            onTap: () {
                              setState(() {
                                _selectedCity = null;
                                _performSearch();
                              });
                            },
                          ),
                        if (_selectedType != null) ...[
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: _selectedType.toString().split('.').last,
                            onTap: () {
                              setState(() {
                                _selectedType = null;
                                _performSearch();
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, propertyProvider, _) {
                if (propertyProvider.properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No properties found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: propertyProvider.properties.length,
                  itemBuilder: (context, index) {
                    final property = propertyProvider.properties[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: property.imageUrls.isNotEmpty
                            ? Image.network(
                                property.imageUrls.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              )
                            : const Icon(Icons.home),
                        title: Text(property.title),
                        subtitle: Text(
                          '${property.city}, ${property.state}\n\$${property.price.toStringAsFixed(0)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(
                                propertyId: property.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: const InputDecoration(labelText: 'City'),
                items: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']
                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
              ),
              DropdownButtonFormField<PropertyType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Property Type'),
                items: PropertyType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Min Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minPrice = value.isEmpty ? null : double.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Max Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxPrice = value.isEmpty ? null : double.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Min Bedrooms'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minBedrooms = value.isEmpty ? null : int.tryParse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Min Bathrooms'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minBathrooms = value.isEmpty ? null : int.tryParse(value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCity = null;
                _selectedState = null;
                _selectedType = null;
                _minPrice = null;
                _maxPrice = null;
                _minBedrooms = null;
                _minBathrooms = null;
              });
              Navigator.of(context).pop();
              _performSearch();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSearch();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
    );
  }
}

