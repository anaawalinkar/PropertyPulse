import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/tour_schedule_repository.dart';
import '../../models/tour_schedule_model.dart';

class ScheduleTourScreen extends StatefulWidget {
  final String propertyId;
  final String sellerId;

  const ScheduleTourScreen({
    super.key,
    required this.propertyId,
    required this.sellerId,
  });

  @override
  State<ScheduleTourScreen> createState() => _ScheduleTourScreenState();
}

class _ScheduleTourScreenState extends State<ScheduleTourScreen> {
  final TourScheduleRepository _tourRepository = TourScheduleRepository();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  TourType _tourType = TourType.virtual;
  List<DateTime> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final slots = await _tourRepository.getAvailableTimeSlots(
        widget.propertyId,
        _selectedDate,
        const Duration(hours: 1),
      );

      setState(() {
        _availableSlots = slots;
        _selectedTime = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load available slots: $e')),
        );
      }
    }
  }

  Future<void> _scheduleTour() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tour = TourScheduleModel(
        id: const Uuid().v4(),
        propertyId: widget.propertyId,
        sellerId: widget.sellerId,
        buyerId: currentUser.id,
        tourType: _tourType,
        scheduledDateTime: _selectedTime!,
        endDateTime: _selectedTime!.add(const Duration(hours: 1)),
        status: TourStatus.pending,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        meetingLink: _tourType == TourType.virtual
            ? 'https://meet.google.com/xxx-yyyy-zzz' // Generate actual link
            : null,
        meetingLocation: _tourType == TourType.inPerson
            ? 'Property Address' // Get from property
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _tourRepository.createTourSchedule(tour);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tour scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule tour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Tour'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Tour Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TourType>(
              segments: const [
                ButtonSegment(
                  value: TourType.virtual,
                  label: Text('Virtual'),
                  icon: Icon(Icons.video_call),
                ),
                ButtonSegment(
                  value: TourType.inPerson,
                  label: Text('In-Person'),
                  icon: Icon(Icons.location_on),
                ),
              ],
              selected: {_tourType},
              onSelectionChanged: (Set<TourType> newSelection) {
                setState(() {
                  _tourType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) {
                return day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _selectedTime = null;
                });
                _loadAvailableSlots();
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_availableSlots.isEmpty)
              const Text('No available slots for this date')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedTime != null &&
                      _selectedTime!.hour == slot.hour &&
                      _selectedTime!.minute == slot.minute;
                  return ChoiceChip(
                    label: Text(
                      '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTime = selected ? slot : null;
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            Text(
              'Additional Notes (Optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any special requests or questions...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _scheduleTour,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Schedule Tour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

