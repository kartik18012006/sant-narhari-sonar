import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app_theme.dart';
import '../widgets/responsive_wrapper.dart';
import 'view_all_news_screen.dart';

/// News search screen with location filters
class NewsSearchScreen extends StatefulWidget {
  const NewsSearchScreen({super.key});

  @override
  State<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends State<NewsSearchScreen> {
  String? _country;
  String? _state;
  String? _district;
  String? _taluka;
  String? _village;

  // Location options - these would typically come from a service or database
  static const List<String> _countryOptions = ['India', 'Other'];
  static const List<String> _stateOptions = ['Maharashtra', 'Gujarat', 'Karnataka', 'Other'];
  static const List<String> _districtOptions = ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Other'];
  static const List<String> _talukaOptions = ['Pune City', 'Pimpri-Chinchwad', 'Other'];
  static const List<String> _villageOptions = ['Pune', 'Mumbai', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'News / बातम्या',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        maxWidth: kIsWeb ? 600 : double.infinity,
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 24 : 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select a location to find news about the Sonar community. The filters will populate as you make selections.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                'Country / देश',
                'Select Country',
                _country,
                _countryOptions,
                (value) {
                  setState(() {
                    _country = value;
                    if (value == null) {
                      _state = null;
                      _district = null;
                      _taluka = null;
                      _village = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_country != null) ...[
                _buildDropdown(
                  'State / राज्य',
                  'Select State',
                  _state,
                  _stateOptions,
                  (value) {
                    setState(() {
                      _state = value;
                      if (value == null) {
                        _district = null;
                        _taluka = null;
                        _village = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (_state != null) ...[
                _buildDropdown(
                  'District / जिल्हा',
                  'Select District',
                  _district,
                  _districtOptions,
                  (value) {
                    setState(() {
                      _district = value;
                      if (value == null) {
                        _taluka = null;
                        _village = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (_district != null) ...[
                _buildDropdown(
                  'Taluka / तालुका',
                  'Select Taluka',
                  _taluka,
                  _talukaOptions,
                  (value) {
                    setState(() {
                      _taluka = value;
                      if (value == null) {
                        _village = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (_taluka != null) ...[
                _buildDropdown(
                  'Village / गाव',
                  'Select Village',
                  _village,
                  _villageOptions,
                  (value) {
                    setState(() => _village = value);
                  },
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: AppTheme.buttonHeight,
                child: FilledButton.icon(
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search, size: 22, color: Colors.white),
                  label: const Text(
                    '🔎 Search News',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String hint,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  hint,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              ...items.map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  )),
            ],
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  void _onSearch() {
    // Navigate to news list (filters can be applied later in ViewAllNewsScreen)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ViewAllNewsScreen(),
      ),
    );
  }
}
