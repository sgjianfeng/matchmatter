import 'package:flutter/material.dart';

class CustomAppBarForApps extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onSearchIconPressed;
  final VoidCallback? onGroupIconPressed;

  CustomAppBarForApps({
    required this.title,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.onSearchIconPressed,
    this.onGroupIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackButtonPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        overflow: TextOverflow.ellipsis,
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchIconPressed,
        ),
        IconButton(
          icon: const Icon(Icons.group),
          onPressed: onGroupIconPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
