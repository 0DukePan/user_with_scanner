import 'package:flutter/material.dart';
import 'package:hungerz/Components/textfield.dart';
import 'package:hungerz/Components/list_tile.dart';
import 'package:hungerz/Locale/locales.dart';
import 'package:hungerz/Routes/routes.dart';
import 'package:hungerz/Themes/colors.dart';

class AddToWallet extends StatefulWidget {
  const AddToWallet({super.key});

  @override
  _AddToWalletState createState() => _AddToWalletState();
}

class _AddToWalletState extends State<AddToWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMoney!,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold)),
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
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: EntryField(
              AppLocalizations.of(context)!.enterAmountToAdd!.toUpperCase(),
              '\$ 500',
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            color: Theme.of(context).cardColor,
            child: Text(AppLocalizations.of(context)!.addVia!.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: kDisabledColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.67)),
          ),
          BuildListTile(
            onTap: () => Navigator.pushNamed(context, PageRoutes.addMoney),
            image: 'images/payment/payment_card.png',
            text: AppLocalizations.of(context)!.credit,
          ),
          BuildListTile(
            onTap: () => Navigator.pushNamed(context, PageRoutes.addMoney),
            image: 'images/payment/payment_card.png',
            text: AppLocalizations.of(context)!.debit,
          ),
          BuildListTile(
            onTap: () => Navigator.pushNamed(context, PageRoutes.addMoney),
            image: 'images/payment/payment_paypal.png',
            text: AppLocalizations.of(context)!.paypal,
          ),
          BuildListTile(
            onTap: () => Navigator.pushNamed(context, PageRoutes.addMoney),
            image: 'images/payment/payment_payu.png',
            text: AppLocalizations.of(context)!.payU,
          ),
          BuildListTile(
            onTap: () => Navigator.pushNamed(context, PageRoutes.addMoney),
            image: 'images/payment/payment_stripe.png',
            text: AppLocalizations.of(context)!.stripe,
          ),
          Container(
            height: 150,
            color: Theme.of(context).cardColor,
          )
        ],
      ),
    );
  }
}
