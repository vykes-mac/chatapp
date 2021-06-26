import 'package:chatapp/colors.dart';
import 'package:chatapp/theme.dart';
import 'package:chatapp/ui/widgets/home/profile_image.dart';
import 'package:chatapp/viewmodels/chats_view_model.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  final ChatsViewModel viewModel;
  Chats(this.viewModel);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.only(top: 30, right: 16),
        itemBuilder: (BuildContext context, indx) => _chatItem(),
        separatorBuilder: (_, __) => Divider(),
        itemCount: 3);
  }

  _chatItem() => ListTile(
        leading: ProfileImage(
          imageUrl: 'https://picsum.photos/seed/picsum/200/300',
          online: true,
        ),
        title: Text(
          'Lisa',
          style: Theme.of(context).textTheme.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: isLightTheme(context) ? Colors.black : Colors.white),
        ),
        subtitle: Text(
          'Thank you so much!',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: Theme.of(context).textTheme.overline.copyWith(
              color: isLightTheme(context) ? Colors.black54 : Colors.white70),
        ),
        contentPadding: EdgeInsets.only(left: 16.0),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '12pm',
                style: Theme.of(context).textTheme.overline.copyWith(
                    color: isLightTheme(context)
                        ? Colors.black54
                        : Colors.white70),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Container(
                    height: 15.0,
                    width: 15.0,
                    color: kPrimary,
                    alignment: Alignment.center,
                    child: Text(
                      '2',
                      style: Theme.of(context)
                          .textTheme
                          .overline
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
