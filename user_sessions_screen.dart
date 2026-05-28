import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'firebase.dart';
import 'ui.dart';
import 'app_localizations.dart';

class UserSessionsScreen extends StatefulWidget {
  const UserSessionsScreen({Key? key}) : super(key: key);

  @override
  _UserSessionsScreenState createState() => _UserSessionsScreenState();
}

class _UserSessionsScreenState extends State<UserSessionsScreen> {
  List<Map<String, dynamic>> _allSessions = [];
  List<Map<String, dynamic>> _filteredSessions = [];
  bool _isLoading = true;
  String? _userId;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _categories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n?.translate('all') ?? 'All',
      l10n?.translate('relaxation') ?? 'Relaxation',
      l10n?.translate('exposure') ?? 'Exposure',
      l10n?.translate('mindfulness') ?? 'Mindfulness'
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadUserSessions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getEnglishCategory(String localizedCategory) {
    final l10n = AppLocalizations.of(context);

    if (localizedCategory == l10n?.translate('all')) return 'All';
    if (localizedCategory == l10n?.translate('relaxation')) return 'Relaxation';
    if (localizedCategory == l10n?.translate('exposure')) return 'Exposure';
    if (localizedCategory == l10n?.translate('mindfulness'))
      return 'Mindfulness';

    return 'All';
  }

  String _getTranslatedType(String type) {
    final l10n = AppLocalizations.of(context);

    switch (type.toLowerCase()) {
      case 'relaxation':
        return l10n?.translate('relaxation') ?? 'Relaxation';
      case 'exposure':
        return l10n?.translate('exposure') ?? 'Exposure';
      case 'mindfulness':
        return l10n?.translate('mindfulness') ?? 'Mindfulness';
      default:
        return type;
    }
  }

  void _applyFilters() {
    setState(() {
      final englishCategory = _getEnglishCategory(_selectedCategory);

      _filteredSessions = _allSessions.where((session) {
        final matchesSearch = session['title']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            session['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesCategory = englishCategory == 'All' ||
            session['type'].toString().toLowerCase() ==
                englishCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadUserSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseService.getCurrentUser();

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _allSessions = [];
          _filteredSessions = [];
        });
        return;
      }

      _userId = currentUser.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('userId', isEqualTo: _userId)
          .orderBy('date', descending: true)
          .get();

      final sessions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final type = data['type'] ?? 'unknown';

        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled Session',
          'description': data['description'] ?? 'No description',
          'type': type,
          'category': data['category'] ?? 'General',
          'duration': data['duration'] ?? 0,
          'date': date,
          'imageAsset': _getImageAssetForType(type, data['videoAssetPath']),
          'formattedDate': DateFormat('dd MMM yyyy').format(date),
          'formattedTime': DateFormat('HH:mm').format(date),
          'durationText': _formatDuration(data['duration'] ?? 0),
          'translatedType': _getTranslatedType(type),
        };
      }).toList();

      setState(() {
        _allSessions = sessions;
        _filteredSessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print(' Error: $e');
      setState(() {
        _isLoading = false;
        _allSessions = [];
        _filteredSessions = [];
      });
    }
  }

  String _getImageAssetForType(String type, String? videoPath) {
    if (videoPath != null) {
      if (videoPath.contains('1')) return 'assets/1.png';
      if (videoPath.contains('2')) return 'assets/2.png';
      if (videoPath.contains('3')) return 'assets/3.png';
      if (videoPath.contains('4')) return 'assets/4.png';
      if (videoPath.contains('5')) return 'assets/5.png';
    }

    switch (type.toLowerCase()) {
      case 'relaxation':
        return 'assets/1.png';
      case 'exposure':
        return 'assets/2.png';
      case 'mindfulness':
        return 'assets/3.png';
      default:
        return 'assets/5.png';
    }
  }

  String _formatDuration(int seconds) {
    final l10n = AppLocalizations.of(context);
    final minutes = seconds ~/ 60;
    return '${l10n?.translate('duration_minutes').replaceFirst('{minutes}', '$minutes') ?? '$minutes min'}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppUI.appBar(
        title: l10n?.translate('my_sessions') ?? 'My Sessions',
        useGradient: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserSessions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderAndSearch(context),
          _buildCategoryFilter(context),
          Expanded(
            child: _isLoading
                ? AppUI.loadingIndicator()
                : _filteredSessions.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _filteredSessions.length,
                        itemBuilder: (context, index) {
                          return _buildSessionRow(
                              _filteredSessions[index], context);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndSearch(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppUI.purplePrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.translate('complete_history') ?? 'Complete History',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppUI.purpleLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_allSessions.length} ${l10n?.translate('sessions') ?? 'Sessions'}',
                      style: const TextStyle(
                        color: AppUI.purplePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: l10n?.translate('search_sessions') ??
                    'Search for a session...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, color: AppUI.purplePrimary),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _applyFilters();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppUI.purplePrimary, AppUI.purpleSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionRow(Map<String, dynamic> session, BuildContext context) {
    AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSessionDetails(session, context),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: AssetImage(session['imageAsset']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              session['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          Text(
                            session['formattedDate'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppUI.purplePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session['translatedType'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppUI.purplePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            session['formattedTime'],
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            session['durationText'],
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Icon(Icons.check_circle_outline,
                              size: 16, color: AppUI.successColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetails(Map<String, dynamic> session, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AppUI.showCustomDialog(
      context: context,
      title: session['title'],
      content:
          '${l10n?.translate('session_details_completed_on') ?? 'Details of the session completed on'} ${session['formattedDate']}\n\n'
          '${l10n?.translate('type') ?? 'Type'}: ${session['translatedType']}\n'
          '${l10n?.translate('duration') ?? 'Duration'}: ${session['durationText']}\n'
          '${l10n?.translate('note') ?? 'Note'}: ${l10n?.translate('successfully_completed') ?? 'Successfully completed'}',
      confirmText: l10n?.translate('close') ?? 'Close',
      useGradient: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n?.translate('no_sessions_found') ?? 'No sessions found',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
