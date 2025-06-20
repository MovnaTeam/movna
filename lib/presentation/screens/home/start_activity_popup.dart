import 'package:flutter/material.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/extensions/sport_translation_extension.dart';
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
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sport selection
              _buildSportSelectionRow(context),
              // Start button.
              ElevatedButton(
                child: Text(
                  LocaleKeys.home.startActivity().translate(context),
                ),
                onPressed: () =>
                    ActivityRoute(ActivityScreenParams(sport: _sport))
                        .go(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportDropDownButton(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      value: _sport,
      onChanged: (Sport? value) {
        if (value == null) return;
        setState(() {
          _sport = value;
        });
      },
      items: Sport.values.map<DropdownMenuItem<Sport>>((Sport value) {
        return DropdownMenuItem(
          value: value,
          child: Text(
            value.translatable().translate(context),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSportSelectionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              LocaleKeys.home.activityConfiguration.sport().translate(context),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildSportDropDownButton(context),
          ),
        ),
      ],
    );
  }
}
