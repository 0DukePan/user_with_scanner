import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:hungerz/Locale/locales.dart';
import 'package:hungerz/Themes/colors.dart';
import 'package:hungerz/Pages/items.dart';

class StoresPage extends StatelessWidget {
  final String? pageTitle;
  final bool isBooking;

  const StoresPage(this.pageTitle, [this.isBooking = false]);

  final int noOfStores = 28;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          pageTitle!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {/*......*/},
          ),
        ],
      ),
      body: FadedSlideAnimation(
        beginOffset: Offset(0.0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: ListView(
          physics: BouncingScrollPhysics(),
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
              child: Text(
                '$noOfStores ${AppLocalizations.of(context)!.storeFound!}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: kHintColor, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.store,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/Layer 1.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.store!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.2',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('6.4 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.storee,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/Layer 2.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.storee!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.8',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('8.9 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.jesica,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/Layer 3.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.jesica!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.5',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('5.0 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.fish,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/layer4.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.fish!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.8',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('8.9 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.seven,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/layer5.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.seven!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.8',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('8.9 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemsPage(
                        AppLocalizations.of(context)!.operum,
                        isBooking ? true : false),
                  )),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20, right: 20.0),
                child: Row(
                  children: <Widget>[
                    FadedScaleAnimation(
                      fadeDuration: Duration(milliseconds: 800),
                      child: Image(
                        image: AssetImage("images/Restaurants/layer6.png"),
                        height: 93.3,
                      ),
                    ),
                    SizedBox(width: 13.3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.operum!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.0),
                        Text(AppLocalizations.of(context)!.type!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kHintColor, fontSize: 10.0)),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Color(0xff7ac81e),
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('4.8',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Color(0xff7ac81e),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: kIconColor,
                              size: 15,
                            ),
                            SizedBox(width: 10.0),
                            Text('8.9 km ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                            Text('| ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kMainColor, fontSize: 10.0)),
                            Text(AppLocalizations.of(context)!.storeAddress!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: kHintColor, fontSize: 10.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
