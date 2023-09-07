import 'package:flutter/material.dart';
import 'package:e_dukaxon/auth.dart';
import 'package:e_dukaxon/fetch_username.dart';

class CustomAppBarWithBackButton extends StatelessWidget
    implements PreferredSizeWidget {
  final String text;
  @override
  final Size preferredSize;

  CustomAppBarWithBackButton({
    Key? key,
    required this.text,
  })  : preferredSize = const Size.fromHeight(60.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      automaticallyImplyLeading: true,
      title: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
