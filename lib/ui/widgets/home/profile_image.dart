import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/colors.dart';
import 'package:chatapp/ui/widgets/home/online_indicator.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String imageUrl;
  final bool online;

  const ProfileImage({
    @required this.imageUrl,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: imageUrl != null ? Colors.transparent : kBubbleLight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(126.0),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 126,
                    height: 126,
                    fit: BoxFit.fill,
                  )
                : Icon(
                    Icons.group_rounded,
                    size: 35,
                    color: kPrimary,
                  ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: online ? OnlineIndicator() : Container())
        ],
      ),
    );
  }
}
