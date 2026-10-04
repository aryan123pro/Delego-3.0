import 'package:flutter/material.dart';
import 'package:delego/Pages/Schedule_Page/schedule_pagebody.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/constants/backend.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/backgrounds.dart';
import 'package:delego/Widgets/buttons.dart';
import 'package:delego/Widgets/cards.dart';
import 'package:delego/Widgets/page_header.dart';

class SchedulePage extends StatefulWidget {
  final bool embedded;
  const SchedulePage({super.key, this.embedded = false});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const String _cacheKey = 'fullScheduleData';
  static const String _timestampKey = 'fullScheduleTimestamp';
  static const int _cacheDurationMs = 90 * 60 * 1000;

  List<ConferenceDay> _days = [];
  List<Schedule> _allEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFullSchedule();
  }

  void _parseAndSetSchedule(String responseBody) {
    final Map<String, dynamic> data = jsonDecode(responseBody);

    final List<ConferenceDay> daysList =
    (data['conference_days'] as List)
        .map((json) => ConferenceDay.fromJson(json))
        .toList();

    final List<Schedule> eventsList =
    (data['events'] as List)
        .map((json) => Schedule.fromJson(json))
        .toList();

    setState(() {
      _days = daysList;
      _allEvents = eventsList;
      _isLoading = false;
    });
  }

  Future<void> _fetchFullSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getInt(_timestampKey);
    bool cacheValid = false;

    if (cachedData != null && cacheTimestamp != null) {
      if (now - cacheTimestamp < _cacheDurationMs) {
        _parseAndSetSchedule(cachedData);
        cacheValid = true;
        return;
      }
    }

    try {
      final url = Uri.parse('${Backend.baseUrl}/schedule');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        _parseAndSetSchedule(responseBody);
        await prefs.setString(_cacheKey, responseBody);
        await prefs.setInt(_timestampKey, now);
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['detail'] ?? 'Server error: Status ${response.statusCode}');
      }
    } catch (e) {
      if (cachedData != null && _days.isEmpty) {
        _parseAndSetSchedule(cachedData);
        _error = 'Could not update data. Displaying cached schedule.';
      } else if (_days.isEmpty) {
        _error = 'Data not available: ${e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception: ', '') : 'Please check your connection.'}';
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppScaffoldBackdrop(
        standalone: !widget.embedded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: SectionHeaderBar(title: 'Schedule'),
            ),
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)),
            ),
          ],
        ),
      );
    }

    if (_error != null && _days.isEmpty) {
      return AppScaffoldBackdrop(
        standalone: !widget.embedded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: SectionHeaderBar(title: 'Schedule'),
            ),
            Expanded(
              child: EmptyStateNote(
                icon: Icons.error_outline_rounded,
                title: 'Could not load the schedule',
                message: _error,
                action: SizedBox(
                  width: 160,
                  child: PrimaryButton(
                      label: 'Retry', onPressed: _fetchFullSchedule, icon: Icons.refresh_rounded),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
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

    return DefaultTabController(
      length: _days.length,
      child: AppScaffoldBackdrop(
        standalone: !widget.embedded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: SectionHeaderBar(title: 'Schedule'),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.hotPink,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  tabs: _days.map((day) => Tab(text: day.dayKey)).toList(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.zero,
                child: TabBarView(
                  children: _days.map((day) {
                    final filteredEvents =
                        _allEvents.where((event) => event.day == day.dayKey).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _DayLabel(day.displayDate),
                        SchedulePageBody(schedules: filteredEvents),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String title;
  const _DayLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: AppType.numeral(AppColors.textPrimary, size: 20)),
      ),
    );
  }
}
