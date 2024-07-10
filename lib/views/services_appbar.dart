import 'package:flutter/material.dart';

class ServicesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onSearchIconPressed;
  final VoidCallback? onGroupIconPressed;
  final GlobalKey? menuKey; // 新增 GlobalKey 参数

  ServicesAppBar({
    required this.title,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.onSearchIconPressed,
    this.onGroupIconPressed,
    this.menuKey, // 初始化 GlobalKey
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
          key: menuKey, // 将 GlobalKey 赋值给 IconButton
          icon: const Icon(Icons.group),
          onPressed: onGroupIconPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
