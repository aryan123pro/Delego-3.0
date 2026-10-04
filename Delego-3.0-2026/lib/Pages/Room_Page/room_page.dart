import 'package:flutter/material.dart';
import 'package:delego/constants/backend.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // For Future/async operations
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/cards.dart';
import 'package:delego/Widgets/buttons.dart';
import 'package:delego/Widgets/page_header.dart';

// --- BACKEND AND CLIENT SETUP ---

// 1. Real HTTP Client
final http.Client httpClient = http.Client();

// 2. Real SharedPreferences Instance Getter
Future<SharedPreferences> getSharedPreferencesInstance() => SharedPreferences.getInstance();

// Mock implementations removed

// --- DATA MODEL (remains the same) ---

class Room {
  final String id;
  final String committeeName;
  final String roomCode;
  final String floor;

  Room({
    required this.id,
    required this.committeeName,
    required this.roomCode,
    required this.floor,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      committeeName: json['committee_name'] as String,
      roomCode: json['room_code'] as String,
      floor: json['floor'] as String,
    );
  }
}

class RoomPage extends StatefulWidget {
  final bool embedded;
  const RoomPage({super.key, this.embedded = false});
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  static const String _cacheKey = 'allotedRoomsData';
  static const String _timestampKey = 'allotedRoomsTimestamp';
  static const int _cacheDurationMs = 120 * 60 * 1000;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getString(_timestampKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    bool cacheValid = false;
    if (cachedData != null && cacheTimestamp != null) {
      final lastFetched = int.tryParse(cacheTimestamp) ?? 0;
      if (now - lastFetched < _cacheDurationMs) {
        _rooms = _parseRooms(cachedData);
        cacheValid = true;
        setState(() { _isLoading = false; });
        return;
      }
    }
    try {
      final url = Uri.parse('${Backend.baseUrl}/rooms');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = response.body;
        _rooms = _parseRooms(responseBody);
        await prefs.setString(_cacheKey, responseBody);
        await prefs.setString(_timestampKey, now.toString());
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Server error: Status Code ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (_rooms.isEmpty) {
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      } else {
        _error = 'Could not update data. Displaying cached information. Error: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Network failed.'}';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Room> _parseRooms(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } catch (_) { return []; }
  }

  static const _accents = [AppColors.magenta, AppColors.violet, AppColors.hotPink, AppColors.goldDeep];

  Widget _buildRoomCard(Room room, int index) {
    return ListRowCard(
      icon: Icons.location_on_rounded,
      accent: _accents[index % _accents.length],
      title: room.committeeName,
      subtitle: '${room.roomCode} · ${room.floor}',
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading && _rooms.isEmpty) {
      content = const Center(child: CircularProgressIndicator(color: AppColors.hotPink));
    } else if (_rooms.isEmpty && _error != null) {
      content = EmptyStateNote(
        icon: Icons.error_outline_rounded,
        title: 'Could not load rooms',
        message: _error,
        action: SizedBox(
          width: 160,
          child: PrimaryButton(label: 'Retry', onPressed: _fetchRooms, icon: Icons.refresh_rounded),
        ),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: _rooms.length,
        itemBuilder: (context, index) => _buildRoomCard(_rooms[index], index),
      );
    }

    // Show snackBar for stale cache after widget build
    if (_error != null && !_isLoading && _rooms.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    return AppScaffoldBackdrop(
      standalone: !widget.embedded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: SectionHeaderBar(title: 'Allotted Rooms'),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: PlainSectionHeader(
              eyebrow: 'FIND YOUR COMMITTEE',
              title: 'Allotted Rooms',
              accent: AppColors.magenta,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}





