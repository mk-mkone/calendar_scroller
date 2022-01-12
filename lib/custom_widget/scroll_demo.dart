import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RealizedBody extends StatefulWidget {
  const RealizedBody({Key? key}) : super(key: key);

  @override
  _RealizedBodyState createState() => _RealizedBodyState();
}

class _RealizedBodyState extends State<RealizedBody> {
  late Map<int, DateTime> months;
  late AutoScrollController _controller;
  final scrollDirection = Axis.vertical;
  int _activateButton = 5;
  List<Widget> _calendarButton = [];

  @override
  void initState() {
    super.initState();
    months = {};
    DateTime now = DateTime.now();
    for (var i = 5; i >= 0; i--) {
      months[i] = DateTime(now.year, now.month - i, now.day);
    }

    _controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection
    );
  }

  Future _scrollToIndex(int indexToJump) async {
    await _controller.scrollToIndex(indexToJump, preferPosition: AutoScrollPosition.begin);
  }

  @override
  Widget build(BuildContext context) {
    double bottomDistance = (MediaQuery.of(context).padding.bottom + kToolbarHeight);

    _generateCalendarNavigator();
    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.fromLTRB(25, 5, 25, 190),
          scrollDirection: scrollDirection,
          controller: _controller,
          shrinkWrap: true,
          children: <Widget>[
            visibilityDetector(0),
            visibilityDetector(1),
            visibilityDetector(2),
            visibilityDetector(3),
            visibilityDetector(4),
            visibilityDetector(5),
          ],
        ),
        Positioned(
          bottom: bottomDistance,
          left: 25,
          child: SizedBox(
            height: 35,
            width: MediaQuery.of(context).size.width - 50,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _calendarButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget visibilityDetector(int index) {
    return VisibilityDetector(
      key: Key(index.toString()),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1) {
          setState(() {
            _activateButton = index;
          });
        }
      },
      child: AutoScrollTag(
          key: ValueKey(index),
          controller: _controller,
          index: index,
          child: Container(
            height: 450,
            decoration: BoxDecoration(color: (index % 2) == 0 ? Colors.teal : Colors.black12),
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
            alignment: Alignment.topLeft,
            child: Text(
              DateFormat('MMM y').format(months[index]!).toUpperCase(),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          )
      ),
    );
  }

  _generateCalendarNavigator() {
    List<Widget> allButton = [];

    allButton.add(const SizedBox(width: 4));

    for (var element in months.entries) {
      DateTime month = element.value;
      int i = element.key;
      String formattedMonth = DateFormat('MMMM y').format(month);
      String formattedMonthAbbr = DateFormat('MMM.').format(month);

      allButton.add(
          Expanded(
            flex: (_activateButton == i) ? 3 : 1,
            child: SizedBox(
              height: 27.0,
              child: TextButton(
                onPressed: () async {
                  setState(() {
                    _activateButton = i;
                    _scrollToIndex(i);
                  });
                },
                child: Text(
                  (_activateButton == i) ? formattedMonth : formattedMonthAbbr,
                  style: TextStyle(
                      fontWeight: _activateButton == i ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white,
                      fontSize: 12.5
                  ),
                ),
                style: (_activateButton == i)
                    ? ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.amberAccent),
                  padding:
                  MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                )
                    : ButtonStyle(
                  padding:
                  MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(0)),
                ),
              ),
            ),
          )
      );
    }
    allButton.add(const SizedBox(width: 5));

    setState(() {
      _calendarButton = allButton;
    });
  }
}
