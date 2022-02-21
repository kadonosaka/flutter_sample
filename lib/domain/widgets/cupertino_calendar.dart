import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample/domain/utils/date_utils.dart';

late AnimationController _controller;
late Animation<double> _rotateAnimation;

class CupertinoCalendar extends StatefulWidget {
  const CupertinoCalendar({
    this.firstDate,
    this.lastDate,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onPressed;

  @override
  State<StatefulWidget> createState() => CupertinoCalendarState();
}

class CupertinoCalendarState extends State<CupertinoCalendar> {
  var currentDateTime = DateTime.now();
  var selectedDateTime = DateTime.now();
  late FixedExtentScrollController? _yearPickerController;
  late FixedExtentScrollController? _monthPickerController;
  bool monthlyMode = false;

  List<DateTime> buildDateTimeList(DateTime minDateTime, DateTime maxDateTime) {
    final _list = <DateTime>[];
    for(
      var dateTime=DateTime(minDateTime.year, minDateTime.month);
      dateTime.year != maxDateTime.year || dateTime.month != maxDateTime.month;
      dateTime=DateTime(dateTime.year, dateTime.month+1)
    ) {
      _list.add(dateTime);
    }
    return _list;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _items = buildDateTimeList(
      widget.firstDate!=null ? widget.firstDate! : DateTime(2000,1),
      widget.firstDate!=null ? widget.firstDate! : DateTime(2100,12),
    );
    final _years = _items.map((dateTime) => dateTime.year).toSet().toList();
    final _yearIndex = _years.indexWhere(
      (year) => year == selectedDateTime.year
    );
    _yearPickerController = FixedExtentScrollController(initialItem: _yearIndex);

    final _months = _items.map((dateTime) => dateTime.month).toSet().toList();
    final _monthIndex = _months.indexWhere(
      (month) => month == selectedDateTime.month
    );
    _monthPickerController = FixedExtentScrollController(initialItem: _monthIndex);
    
    return Column(
      children: [
        CalendarHeader(
          currentDateTime: currentDateTime,
          monthlyMode: monthlyMode,
          onPressed: (dateTime) {
            setState(() {
              currentDateTime = dateTime;
            });

            var __yearIndex = -1;
            if(dateTime.year > _years.last) {
              __yearIndex = 0;
            } else if(dateTime.year < _years.first) {
              __yearIndex = _years.length - 1;
            } else {
              __yearIndex = _years.indexWhere(
                (year) => year == dateTime.year
              );
            }
            _yearPickerController?.jumpToItem(
              __yearIndex >= 0 ? __yearIndex : 0,
            );

            final __monthIndex = _months.indexWhere(
              (month) => month == dateTime.month
            );
            _monthPickerController?.jumpToItem(
              __monthIndex,
            );
          },
          onChangeMode: (){
            setState(() {
              monthlyMode = !monthlyMode;
            });
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: !monthlyMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Calendar(
            currentDateTime: currentDateTime,
            onPressed: (dateTime){
              setState(() {
                selectedDateTime = dateTime;
              });
              widget.onPressed.call(dateTime);
            },
          ),
          secondChild: YearMonthPicker(
            currentDateTime: currentDateTime,
            items: _items,
            onChanged: (dateTime){
              setState(() {
                currentDateTime = dateTime;
              });
              widget.onPressed.call(dateTime);
            },
            yearController: _yearPickerController,
            monthController: _monthPickerController,
          ),
        ),
      ],
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({
    required this.currentDateTime,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final DateTime currentDateTime;
  final Function(DateTime) onPressed;

  @override
  State<StatefulWidget> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  DateTime _selectedDateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<DateTime> _buildMonthlyDays(DateTime currentDateTime){
    final _lastDate = DateTime(currentDateTime.year, currentDateTime.month+1, 0);
  
    final _days = <DateTime>[];
    for(int _day=1; _day<=_lastDate.day; _day++) {
      _days.add(
        DateTime(
          currentDateTime.year,
          currentDateTime.month,
          _day,
        )
      );
    }
  
    return _days;
  }

  List<List<DateTime>> buildMonthlyWeeks(DateTime currentDateTime) {
    final _days = _buildMonthlyDays(currentDateTime);
    final _weeks = <List<DateTime>>[];
    final _firstDate = _days[0];
    final _daysOfFirstWeek = __weekday[_firstDate.weekday]!;
    final numOfWeeks = ((DateTime.daysPerWeek - __weekday[_firstDate.weekday]! + _days.length)/DateTime.daysPerWeek).ceil();

    for(int _index=1; _index<=numOfWeeks; _index++) {
      List<DateTime> _week;
      // 1週目
      if(_index==1) {
        _week = _days
          .take(_daysOfFirstWeek)
          .toList();

      // 2週目
      } else if(_index==2) {
        _week = _days
          .skip(_daysOfFirstWeek)
          .take(DateTime.daysPerWeek)
          .toList();

      } else {
        _week = _days
          .skip(_daysOfFirstWeek + DateTime.daysPerWeek*(_index-2))
          .take(DateTime.daysPerWeek)
          .toList();
      }
      if(_week.isNotEmpty) {
        _weeks.add(_week);
      }
    }

    return _weeks;
  }

  Widget buildWeekHeaderWidget() {
    final _headers = <Widget>[];
      final _headerLabels = <String>[
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
  ];
    for(int _index=1; _index <= _headerLabels.length; _index++){
      _headers.add(buildHeaderWidget(_headerLabels[_index-1]));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _headers,
    );
  }

  Widget buildHeaderWidget(String label) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.grey),)
      ),
    );
  }

  Widget buildDayWidget(DateTime? dateTime) {
    final _day = dateTime!=null ? dateTime.day.toString() : '';
    final _selected = (dateTime != null && dateTime.isAtSameMomentAs(_selectedDateTime));
    final _decoration = _selected ? BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(22),
      ) : const BoxDecoration();

    return GestureDetector(
      onTap:(){
        setState(() {
          if(dateTime != null){
            _selectedDateTime = dateTime;
          }
        });
        widget.onPressed.call(_selectedDateTime);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: _decoration,
        child: Center(
          child: Text(_day, style: TextStyle(color: _selected ? Colors.red : Colors.black),)
        ),
      ),
    );
  }

  Widget buildWeekWidget(List<DateTime> weekday, bool firstWeek) {
    List<Widget> _days = <Widget>[];
    List<Widget> _week = <Widget>[];

    if(weekday.isEmpty){
      return Row();
    }

    final _firstDate = weekday[0];
    final _daysOfFirstWeek = DateTime.daysPerWeek - __weekday[_firstDate.weekday]!;

    final _lastDate = weekday[weekday.length-1];
    final _daysOfLastWeek = __weekday[_lastDate.weekday]!-1;

    for(int _index=1; _index <=weekday.length; _index++){
      _days.add(buildDayWidget(weekday[_index-1]));
    }

    if(firstWeek) {
      if(weekday.length<DateTime.daysPerWeek){
        final _blankDays = List.filled(_daysOfFirstWeek, buildDayWidget(null), growable: true);
        _week.addAll(_blankDays);
      }
      _week.addAll(_days);
    } else {
      _week.addAll(_days);
      if(weekday.length<DateTime.daysPerWeek){
        final _blankDays = List.filled(_daysOfLastWeek, buildDayWidget(null), growable: true);
        _week.addAll(_blankDays);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _week,
    );
  }

  List<Widget> buildMonthWidget(DateTime currentDateTime) {
    final _weeks = buildMonthlyWeeks(currentDateTime);
    final _month = <Widget>[
      buildWeekHeaderWidget()
    ];
    for(int _index=0; _index<_weeks.length; _index++) {
      final _week = _weeks[_index];
      if(_index==0) {
        _month.add(buildWeekWidget(_week, true));
      } else {
        _month.add(buildWeekWidget(_week, false));
      }
    }

    return _month;
  }

  final __weekday = {
    DateTime.monday : 6,
    DateTime.tuesday : 5,
    DateTime.wednesday : 4,
    DateTime.thursday : 3,
    DateTime.friday : 2,
    DateTime.saturday : 1,
    DateTime.sunday : 7,
  };

  @override
  Widget build(BuildContext context) {
    final _widgets = buildMonthWidget(widget.currentDateTime);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _widgets,
      );
  }
}

class CalendarHeader extends StatefulWidget {
  const CalendarHeader({
    required this.currentDateTime,
    required this.monthlyMode,
    required this.onPressed,
    required this.onChangeMode,
    Key? key,
  }) : super(key: key);

  final DateTime currentDateTime;
  final bool monthlyMode;
  final Function(DateTime) onPressed;
  final Function() onChangeMode;

  @override
  State<StatefulWidget> createState() => CalendarHeaderState();
}

class CalendarHeaderState extends State<CalendarHeader> {
  late DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentDateTime = widget.currentDateTime;
    return Row(
      children: [
        Expanded(
          child: MonthlyPickerButton(
            currentDateTime: _currentDateTime,
            onPressed: widget.onChangeMode,
          )
        ),
        Visibility(
          visible: !widget.monthlyMode,
          child: GestureDetector(
            onTap: (){
              final _dateTime = DateTime(
                _currentDateTime.year,
                _currentDateTime.month-1,
                _currentDateTime.day);
              setState(() {
                _currentDateTime = _dateTime;
              });
              widget.onPressed.call(_dateTime);
            },
            child: const Icon(Icons.keyboard_arrow_left, color: Colors.red,)
          ),
        ),
        Visibility(
          visible: !widget.monthlyMode,
          child: GestureDetector(
            onTap: (){
              final _dateTime = DateTime(
                _currentDateTime.year,
                _currentDateTime.month+1,
                _currentDateTime.day);
              setState(() {
                _currentDateTime = _dateTime;
              });
              widget.onPressed.call(_dateTime);
            },
            child: const Icon(Icons.keyboard_arrow_right, color: Colors.red,),
          ),
        ),
      ],
    );
  }
}

class MonthlyPickerButton extends StatefulWidget {
  const MonthlyPickerButton({
    required this.currentDateTime,
    this.primaryColor = Colors.black,
    this.secondaryColor = Colors.red,
    required this.onPressed,
    Key? key
  }) : super(key: key);

  final DateTime currentDateTime;
  final Color primaryColor;
  final Color secondaryColor;
  final Function() onPressed;

  @override
  State<StatefulWidget> createState() => MonthlyPickerButtonState();
}

class MonthlyPickerButtonState extends State<MonthlyPickerButton> with SingleTickerProviderStateMixin {
  void _animationChange() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    widget.onPressed.call();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this
    );

    _controller.addListener(() {
      setState(() {});
    });

    _rotateAnimation = Tween<double> (
      begin: 0,
      end: pi / 2,
    ).animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    JapaneseDateFormat _df = JapaneseDateFormat('Gyy年MM月');
    return GestureDetector(
      onTap:_animationChange,
      child: Row(
        children: [
          Text(
            _df.format(widget.currentDateTime, abbreviation: false),
            style: TextStyle(
              color: _controller.status != AnimationStatus.completed ? widget.primaryColor : widget.secondaryColor
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => child!,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: widget.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class YearMonthPicker extends StatefulWidget {
  const YearMonthPicker({
    required this.currentDateTime,
    required this.items,
    required this.onChanged,
    this.yearController,
    this.monthController,
    Key? key,
  }) : super(key: key);

  final DateTime currentDateTime;
  final List<DateTime> items;
  final Function(DateTime) onChanged;
  final FixedExtentScrollController? yearController;
  final FixedExtentScrollController? monthController;

  @override
  State<StatefulWidget> createState() => YearMonthPickerState();
}

class YearMonthPickerState extends State<YearMonthPicker> {
  late DateTime _currentDateTime;
  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentDateTime = widget.currentDateTime;
    final _years = widget.items.map((dateTime) => dateTime.year).toSet().toList();
    final _months = widget.items.map((dateTime) => dateTime.month).toSet().toList();

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 140),
            child: Row(
              children: [
                Expanded(
                  child: YearPicker(
                    items: _years,
                    onSelectedItemChanged: (index){
                      setState(() {
                        _year = _years[index];
                        _currentDateTime = DateTime(_year, _month, _currentDateTime.day);
                      });
                      widget.onChanged.call(_currentDateTime);
                    },
                    controller: widget.yearController,
                  ),
                ),
                Expanded(
                  child: MonthPicker(
                    items: _months,
                    onSelectedItemChanged: (index){
                      setState(() {
                        _month = _months[index];
                        _currentDateTime = DateTime(_year, _month, _currentDateTime.day);
                      });
                      widget.onChanged.call(_currentDateTime);
                    },
                    controller: widget.monthController,
                  ),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}

class YearPicker extends StatefulWidget {
  const YearPicker({
    required this.items,
    this.onSelectedItemChanged,
    this.controller,
    Key? key,
  }) : super(key: key);

  final List items;
  final Function(int)? onSelectedItemChanged;
  final ScrollController? controller;

  @override
  State<StatefulWidget> createState() => YearPickerState();
}

class YearPickerState extends State<YearPicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: widget.controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: widget.onSelectedItemChanged,
      childDelegate: ListWheelChildLoopingListDelegate(
        children: widget.items.map((year) => Center(child: Text('$year年'))).toList(),
      ),
    );
  }
}

class MonthPicker extends StatefulWidget {
  const MonthPicker({
    required this.items,
    this.onSelectedItemChanged,
    this.controller,
    Key? key,
  }) : super(key: key);

  final List items;
  final Function(int)? onSelectedItemChanged;
  final ScrollController? controller;

  @override
  State<StatefulWidget> createState() => MonthPickerState();
}

class MonthPickerState extends State<MonthPicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: widget.controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: widget.onSelectedItemChanged,
      childDelegate: ListWheelChildLoopingListDelegate(
        children: widget.items.map((month) => Center(child: Text('$month月'))).toList(),
      ),
    );
  }

}
