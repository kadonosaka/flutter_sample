import 'package:intl/intl.dart';

class JapaneseDateFormat {
  JapaneseDateFormat(this.pattern);

  final String pattern;

  final _japaneseCalendarList = <JapaneseCalendar>[
    JapaneseCalendar(
      era: '令和',
      abbreviation: 'R',
      startDate: DateTime(2019, 5, 1),
      endDate: DateTime(9999, 12, 31),
    ),
    JapaneseCalendar(
      era: '平成',
      abbreviation: 'H',
      startDate: DateTime(1989, 1, 8),
      endDate: DateTime(2019, 4, 30),
    ),
    JapaneseCalendar(
      era: '昭和',
      abbreviation: 'S',
      startDate: DateTime(1926, 12, 25),
      endDate: DateTime(1989, 1, 7),
    ),
    JapaneseCalendar(
      era: '大正',
      abbreviation: 'T',
      startDate: DateTime(1912, 7, 30),
      endDate: DateTime(1926, 12, 24),
    ),
    JapaneseCalendar(
      era: '明治',
      abbreviation: 'M',
      startDate: DateTime(1868, 1, 25),
      endDate: DateTime(1912, 7, 29),
    ),
  ];

  String buildJapaneseEra(DateTime dateTime, JapaneseCalendar era, bool abbreviation, int padding){
    String _year='元';
    for(
      var _dateTime=era.startDate, __year=1;
      _dateTime.year<=dateTime.year;
      _dateTime=DateTime(_dateTime.year+1), __year++
    ){
      _year = __year == 1 ? '元' : '$__year'.padLeft(padding, '0');
    }
    return (abbreviation ? era.abbreviation ?? era.era : era.era) + _year;
  }

  String format(DateTime dateTime, {bool abbreviation = false}) {
    // 該当する元号を探す
    final _index = _japaneseCalendarList.indexWhere(
      (era) {
        DateFormat _df = DateFormat('yyyyMMdd');
        return int.parse(_df.format(era.startDate)) <= int.parse(_df.format(dateTime)) &&
          int.parse(_df.format(era.endDate)) >= int.parse(_df.format(dateTime));
      }
    );

    // 該当がない場合は西暦を戻す
    if(_index==-1) {
      DateFormat _df = DateFormat('yyyy/MM');
      return _df.format(dateTime);
    }

    final _era = _japaneseCalendarList[_index];
    final _year = buildJapaneseEra(dateTime, _era, abbreviation, pattern.lastIndexOf('y') - pattern.indexOf('y') + 1);
    final _month = '${dateTime.month}'.padLeft(pattern.lastIndexOf('M') - pattern.indexOf('M') + 1, '0');
    // final _day = '${dateTime.day}'.padLeft(pattern.lastIndexOf('d') - pattern.indexOf('d') + 1, '0');

    // 'Gy年MM月dd日'
    return '$_year年$_month月';
  }
}

class JapaneseCalendar {
  JapaneseCalendar({
    required this.era,
    this.abbreviation,
    required this.startDate,
    required this.endDate,
  });

  String era;
  String? abbreviation;
  DateTime startDate;
  DateTime endDate;
}
