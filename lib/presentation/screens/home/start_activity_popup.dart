import 'package:flutter/material.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/screens/activity/activity_screen.dart';

class StartActivityPopup extends StatefulWidget {
  const StartActivityPopup({super.key});

  @override
  State<StartActivityPopup> createState() => _StartActivityPopupState();
}

class _StartActivityPopupState extends State<StartActivityPopup> {
  Sport _sport = Sport.running;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          DropdownButton<Sport>(
            value: _sport,
            onChanged: (Sport? value) {
              if (value == null) return;
              setState(() {
                _sport = value;
              });
            },
            items: Sport.values.map<DropdownMenuItem<Sport>>((Sport value) {
              return DropdownMenuItem<Sport>(
                value: value,
                child: Text(
                  value.name, // TODO translate this
                ),
              );
            }).toList(),
          ),
          ElevatedButton(
            child: Text(
              LocaleKeys.home.startActivity().translate(context),
            ),
            onPressed: () =>
                ActivityRoute(ActivityScreenParams(sport: _sport)).go(context),
          ),
        ],
      ),
    );
  }
}
