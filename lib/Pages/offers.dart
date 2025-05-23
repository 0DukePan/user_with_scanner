import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:hungerz/Locale/locales.dart';
import 'package:hungerz/Themes/colors.dart';

class Offers extends StatefulWidget {
  const Offers({super.key});

  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)!.offer!,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold)),
        actions: [
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Tap to Copy",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ))
        ],
      ),
      body: FadedSlideAnimation(
        beginOffset: Offset(0.0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ListView(
            children: [
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
              buildOfferTile(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOfferTile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListTile(
          title: Text(
            AppLocalizations.of(context)!.buy!,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(AppLocalizations.of(context)!.buy1!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 10.0, color: Theme.of(context).hintColor)),
          trailing: FittedBox(
            child: Row(
              children: [
                RotatedBox(
                    quarterTurns: 1,
                    child: Text('---------',
                        style: TextStyle(color: Colors.grey[200]))),
                SizedBox(
                  width: 5.0,
                ),
                FadedScaleAnimation(
                  fadeDuration: Duration(milliseconds: 800),
                  child: Text('FFB2G1',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: kMainColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
