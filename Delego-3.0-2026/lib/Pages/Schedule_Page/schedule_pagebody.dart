import 'package:flutter/material.dart';
import 'package:delego/models/schedule.dart';
import 'package:delego/Pages/Schedule_Page/schedule_cards.dart';
import 'package:delego/Widgets/cards.dart';

// Widget for displaying the full day's schedule list, using theme
class SchedulePageBody extends StatelessWidget {
  final List<Schedule> schedules;

  const SchedulePageBody({required this.schedules, super.key});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Expanded(
        child: EmptyStateNote(
          icon: Icons.event_busy_rounded,
          title: 'No events scheduled for this day',
        ),
      );
    }

    return Expanded(
      child: Container(
        color: Colors.transparent,
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => ScheduleSummary(schedules[index]),
                  childCount: schedules.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
