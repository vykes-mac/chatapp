import 'package:chat/chat.dart';
import 'package:chatapp/colors.dart';
import 'package:chatapp/models/local_message.dart';
import 'package:chatapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SenderMessage extends StatelessWidget {
  final LocalMessage message;
  const SenderMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerRight,
      widthFactor: 0.75,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    position: DecorationPosition.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Text(this.message.message.contents,
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('h:mm a')
                            .format(this.message.message.timestamp),
                        style: Theme.of(context).textTheme.overline.copyWith(
                            color: isLightTheme(context)
                                ? Colors.black54
                                : Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Align(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isLightTheme(context) ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: message.receipt == ReceiptStatus.read
                        ? Colors.green[700]
                        : Colors.grey,
                    size: 20.0,
                  )),
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
