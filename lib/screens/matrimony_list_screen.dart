import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';
import 'matrimony_profile_detail_screen.dart';

/// List of grooms or brides from Firestore (after payment). Search + filter by City & Subcaste. Matches APK exactly.
class MatrimonyListScreen extends StatefulWidget {
  const MatrimonyListScreen({super.key, required this.isGroom});

  final bool isGroom;

  @override
  State<MatrimonyListScreen> createState() => _MatrimonyListScreenState();
}

class _MatrimonyListScreenState extends State<MatrimonyListScreen> {
  final _searchController = TextEditingController();
  final _educationController = TextEditingController();
  final _placeOtherController = TextEditingController();
  final _subcasteOtherController = TextEditingController();
  final _maritalStatusOtherController = TextEditingController();
  String? _place;
  String? _subcaste;
  String? _maritalStatus;

  static const List<String> _placeOptions = ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Sangli', 'Other'];
  static List<String> get _subcasteOptions => AppTheme.subcasteOptions;
  List<String> get _maritalStatusOptions => widget.isGroom ? AppTheme.maritalStatusOptionsGroom : AppTheme.maritalStatusOptionsBride;

  @override
  void dispose() {
    _searchController.dispose();
    _educationController.dispose();
    _placeOtherController.dispose();
    _subcasteOtherController.dispose();
    _maritalStatusOtherController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    final type = widget.isGroom ? 'groom' : 'bride';
    var result = list.where((m) => (m['type'] as String? ?? '') == type).toList();
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((m) {
        final name = (m['name'] as String? ?? '').toLowerCase();
        final education = (m['education'] as String? ?? '').toLowerCase();
        final occupation = (m['occupation'] as String? ?? '').toLowerCase();
        final city = (m['city'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            education.contains(query) ||
            occupation.contains(query) ||
            city.contains(query);
      }).toList();
    }
    if (_place != null && _place!.isNotEmpty) {
      final placeToSearch = (_place!.contains('Other') || _place!.contains('इतर')) && _placeOtherController.text.trim().isNotEmpty
          ? _placeOtherController.text.trim()
          : _place!;
      result = result.where((m) {
        final district = (m['district'] as String? ?? '').toLowerCase();
        final state = (m['state'] as String? ?? '').toLowerCase();
        final placeLower = placeToSearch.toLowerCase();
        return district.contains(placeLower) ||
            state.contains(placeLower) ||
            district == placeLower ||
            state == placeLower;
      }).toList();
    }
    if (_subcaste != null && _subcaste!.isNotEmpty) {
      final subcasteToSearch = (_subcaste!.contains('Other') || _subcaste!.contains('इतर')) && _subcasteOtherController.text.trim().isNotEmpty
          ? _subcasteOtherController.text.trim()
          : _subcaste!;
      result = result.where((m) {
        final sc = m['subcaste'] as String? ?? '';
        return sc == subcasteToSearch || sc.toLowerCase().contains(subcasteToSearch.toLowerCase());
      }).toList();
    }
    final educationQuery = _educationController.text.trim();
    if (educationQuery.isNotEmpty) {
      result = result.where((m) {
        final edu = (m['education'] as String? ?? '').toLowerCase();
        return edu.contains(educationQuery.toLowerCase());
      }).toList();
    }
    if (_maritalStatus != null && _maritalStatus!.isNotEmpty) {
      final maritalStatusToSearch = (_maritalStatus!.contains('Other') || _maritalStatus!.contains('इतर')) && _maritalStatusOtherController.text.trim().isNotEmpty
          ? _maritalStatusOtherController.text.trim()
          : _maritalStatus!;
      result = result.where((m) {
        final ms = m['maritalStatus'] as String? ?? '';
        return ms == maritalStatusToSearch || ms.toLowerCase().contains(maritalStatusToSearch.toLowerCase());
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isGroom ? 'Search Grooms / वर शोधा' : 'Search Brides / वधू शोधा';
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
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: widget.isGroom ? 'Search grooms by name, education...' : 'Search brides by name, education...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.gold, size: 22),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),
                _dropdown(
                  label: 'Place / स्थान',
                  value: _place,
                  hint: 'Select city or district',
                  items: _placeOptions,
                  onChanged: (v) {
                    setState(() {
                      _place = v;
                      if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                        _placeOtherController.clear();
                      }
                    });
                  },
                ),
                if (_place != null && (_place!.contains('Other') || _place!.contains('इतर'))) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _placeOtherController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Please specify place / कृपया स्थान निर्दिष्ट करा',
                      hintText: 'Enter place name',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Subcaste / पोटजात',
                  value: _subcaste,
                  hint: 'Select subcaste',
                  items: _subcasteOptions,
                  onChanged: (v) {
                    setState(() {
                      _subcaste = v;
                      if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                        _subcasteOtherController.clear();
                      }
                    });
                  },
                ),
                if (_subcaste != null && (_subcaste!.contains('Other') || _subcaste!.contains('इतर'))) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subcasteOtherController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Please specify subcaste / कृपया पोटजात निर्दिष्ट करा',
                      hintText: 'Enter subcaste name',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _educationController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Higher Education / उच्च शिक्षण',
                    hintText: 'e.g. B.E., M.B.A., Ph.D.',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Marital Status / वैवाहिक स्थिती',
                  value: _maritalStatus,
                  hint: 'Select marital status',
                  items: _maritalStatusOptions,
                  onChanged: (v) {
                    setState(() {
                      _maritalStatus = v;
                      if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                        _maritalStatusOtherController.clear();
                      }
                    });
                  },
                ),
                if (_maritalStatus != null && (_maritalStatus!.contains('Other') || _maritalStatus!.contains('इतर'))) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _maritalStatusOtherController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Please specify marital status / कृपया वैवाहिक स्थिती निर्दिष्ट करा',
                      hintText: 'Enter marital status',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear filters',
                      style: TextStyle(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamMatrimonyApproved(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                final list = snapshot.data ?? [];
                final filtered = _applyFilters(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty
                                ? 'No ${widget.isGroom ? 'groom' : 'bride'} profiles yet.'
                                : 'No ${widget.isGroom ? 'groom' : 'bride'} profiles match your filters.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final name = d['name'] as String? ?? '—';
                    final occupation = d['occupation'] as String? ?? '';
                    final education = d['education'] as String? ?? '';
                    final city = d['city'] as String? ?? '';
                    final photoUrl = d['photoUrl'] as String?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarFallback(name),
                                )
                              : _avatarFallback(name),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [occupation, education, city].where((e) => e.isNotEmpty).join(' • '),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MatrimonyProfileDetailScreen(profile: d),
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

  Widget _avatarFallback(String name) {
    return CircleAvatar(
      backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MatrimonyFilterSheet(
        isGroom: widget.isGroom,
        initialPlace: _place,
        initialSubcaste: _subcaste,
        initialEducation: _educationController.text.trim(),
        initialMaritalStatus: _maritalStatus,
        placeOptions: _placeOptions,
        subcasteOptions: _subcasteOptions,
        onClear: () {
          _clearFilters();
          Navigator.of(ctx).pop();
        },
        onApply: (place, subcaste, education, maritalStatus, placeOther, subcasteOther, maritalStatusOther) {
          setState(() {
            _place = place;
            _subcaste = subcaste;
            _maritalStatus = maritalStatus;
            _educationController.text = education ?? '';
            if (placeOther != null) _placeOtherController.text = placeOther;
            if (subcasteOther != null) _subcasteOtherController.text = subcasteOther;
            if (maritalStatusOther != null) _maritalStatusOtherController.text = maritalStatusOther;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value == null || value.isEmpty) ? null : value,
              isExpanded: true,
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _place = null;
      _subcaste = null;
      _maritalStatus = null;
      _searchController.clear();
      _educationController.clear();
      _placeOtherController.clear();
      _subcasteOtherController.clear();
      _maritalStatusOtherController.clear();
    });
  }
}

class _MatrimonyFilterSheet extends StatefulWidget {
  const _MatrimonyFilterSheet({
    required this.isGroom,
    required this.initialPlace,
    required this.initialSubcaste,
    required this.initialEducation,
    required this.initialMaritalStatus,
    required this.placeOptions,
    required this.subcasteOptions,
    required this.onClear,
    required this.onApply,
  });

  final bool isGroom;
  final String? initialPlace;
  final String? initialSubcaste;
  final String? initialEducation;
  final String? initialMaritalStatus;
  final List<String> placeOptions;
  final List<String> subcasteOptions;
  final VoidCallback onClear;
  final void Function(String? place, String? subcaste, String? education, String? maritalStatus, String? placeOther, String? subcasteOther, String? maritalStatusOther) onApply;

  @override
  State<_MatrimonyFilterSheet> createState() => _MatrimonyFilterSheetState();
}

class _MatrimonyFilterSheetState extends State<_MatrimonyFilterSheet> {
  late String? _place;
  late String? _subcaste;
  late String? _maritalStatus;
  final _educationController = TextEditingController();
  final _placeOtherController = TextEditingController();
  final _subcasteOtherController = TextEditingController();
  final _maritalStatusOtherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _subcaste = widget.initialSubcaste;
    _maritalStatus = widget.initialMaritalStatus;
    _educationController.text = widget.initialEducation ?? '';
  }

  @override
  void dispose() {
    _educationController.dispose();
    _placeOtherController.dispose();
    _subcasteOtherController.dispose();
    _maritalStatusOtherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters / फिल्टर',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          _buildDropdown('Place / स्थान', _place, widget.placeOptions, (v) {
            setState(() {
              _place = v;
              if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                _placeOtherController.clear();
              }
            });
          }),
          if (_place != null && (_place!.contains('Other') || _place!.contains('इतर'))) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _placeOtherController,
              decoration: InputDecoration(
                labelText: 'Please specify place / कृपया स्थान निर्दिष्ट करा',
                hintText: 'Enter place name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildDropdown('Subcaste / पोटजात', _subcaste, widget.subcasteOptions, (v) {
            setState(() {
              _subcaste = v;
              if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                _subcasteOtherController.clear();
              }
            });
          }),
          if (_subcaste != null && (_subcaste!.contains('Other') || _subcaste!.contains('इतर'))) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _subcasteOtherController,
              decoration: InputDecoration(
                labelText: 'Please specify subcaste / कृपया पोटजात निर्दिष्ट करा',
                hintText: 'Enter subcaste name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _educationController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Higher Education / उच्च शिक्षण',
              hintText: 'e.g. B.E., M.B.A., Ph.D.',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown('Marital Status / वैवाहिक स्थिती', _maritalStatus, widget.isGroom ? AppTheme.maritalStatusOptionsGroom : AppTheme.maritalStatusOptionsBride, (v) {
            setState(() {
              _maritalStatus = v;
              if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                _maritalStatusOtherController.clear();
              }
            });
          }),
          if (_maritalStatus != null && (_maritalStatus!.contains('Other') || _maritalStatus!.contains('इतर'))) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _maritalStatusOtherController,
              decoration: InputDecoration(
                labelText: 'Please specify marital status / कृपया वैवाहिक स्थिती निर्दिष्ट करा',
                hintText: 'Enter marital status',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onApply(
                    _place,
                    _subcaste,
                    _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
                    _maritalStatus,
                    _placeOtherController.text.trim().isEmpty ? null : _placeOtherController.text.trim(),
                    _subcasteOtherController.text.trim().isEmpty ? null : _subcasteOtherController.text.trim(),
                    _maritalStatusOtherController.text.trim().isEmpty ? null : _maritalStatusOtherController.text.trim(),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value == null || value.isEmpty) ? null : value,
              isExpanded: true,
              hint: Text('Select', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
