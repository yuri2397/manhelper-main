import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import '../controllers/messages_controller.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../models/chat_model.dart';
import '../../../models/media_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import 'dart:isolate';
import 'dart:ui';

class ChatMessageItem extends StatefulWidget {
  final Chat chat;

  ChatMessageItem({this.chat});

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthService>().user.value.id == this.widget.chat.userId) {
      if (widget.chat.isOffer == true) {
        return getSendOfferDescription(context);
      }
      if (widget.chat.text.isURL) {
        return getSentMessageImageLayout(context);
      } else {
        return getSentMessageTextLayout(context);
      }
    } else {
      if (widget.chat.text.isURL) {
        return getReceivedMessageImageLayout(context);
      } else {
        return getReceivedMessageTextLayout(context);
      }
    }
  }

  Widget getSentMessageTextLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(this.widget.chat.user.name,
                          style: Get.textTheme.bodyText2
                              .merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(widget.chat.text,
                            style: Get.textTheme.bodyText1),
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.widget.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(
                  DateTime.fromMillisecondsSinceEpoch(this.widget.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  Widget getSendOfferDescription(context) {
    final controller3 = Get.put(MessagesController());
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text("You Sent an Offer",
                          style: Get.textTheme.bodyText1
                              .merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: InkWell(
                          onTap: () {
                            // Get.toNamed(Routes.GALLERY, arguments: {
                            //   'media': [
                            //     new Media(
                            //         id: this.chat.text,
                            //         url: this.chat.customMedia)
                            //   ],
                            //   'current': new Media(
                            //       id: this.chat.text,
                            //       url: this.chat.customMedia),
                            //   'heroTag': 'chat_image'
                            // });
                          },
                          child: Container(
                              child: Column(
                            children: [
                              Wrap(
                                children: this
                                    .widget
                                    .chat
                                    .customMedia
                                    .map(
                                      (e) => InkWell(
                                        onTap: () async {
                                          await controller3.downloadFiles(e);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.asset(
                                            'assets/img/offerFile.png',
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              Text(
                                  this
                                          .widget
                                          .chat
                                          .customMedia
                                          .length
                                          .toString() +
                                      " Files attached click to download",
                                  style: Get.textTheme.bodyText1),
                            ],
                          )),
                          // child: ClipRRect(
                          //   borderRadius: BorderRadius.all(Radius.circular(10)),
                          //   child: CachedNetworkImage(
                          //     width: double.infinity,
                          //     fit: BoxFit.cover,
                          //     height: 200,
                          //     imageUrl: this.chat.customMedia,
                          //     placeholder: (context, url) => Image.asset(
                          //       'assets/img/loading.gif',
                          //       fit: BoxFit.cover,
                          //       width: double.infinity,
                          //     ),
                          //     errorWidget: (context, url, error) =>
                          //         Icon(Icons.link_outlined),
                          //   ),
                          // ),
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            new Text("Description:",
                                style: Get.textTheme.bodyText1.merge(
                                    TextStyle(fontWeight: FontWeight.w600))),
                            SizedBox(
                              width: 5,
                            ),
                            new Text(widget.chat.customDescription ?? "",
                                style: Get.textTheme.bodyText1),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            new Text("Price:",
                                style: Get.textTheme.bodyText1.merge(
                                    TextStyle(fontWeight: FontWeight.w600))),
                            SizedBox(
                              width: 5,
                            ),
                            new Text(widget.chat.customPrice ?? "",
                                style: Get.textTheme.bodyText1),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            new Text("Days:",
                                style: Get.textTheme.bodyText1.merge(
                                    TextStyle(fontWeight: FontWeight.w600))),
                            SizedBox(
                              width: 5,
                            ),
                            new Text(widget.chat.customDate ?? "",
                                style: Get.textTheme.bodyText1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.widget.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(
                  DateTime.fromMillisecondsSinceEpoch(this.widget.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  Widget getSentMessageImageLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(this.widget.chat.user.name,
                          style: Get.textTheme.bodyText1
                              .merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.GALLERY, arguments: {
                              'media': [
                                new Media(
                                    id: this.widget.chat.text,
                                    url: this.widget.chat.text)
                              ],
                              'current': new Media(
                                  id: this.widget.chat.text,
                                  url: this.widget.chat.text),
                              'heroTag': 'chat_image'
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 200,
                              imageUrl: this.widget.chat.text,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.link_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.widget.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(
                  DateTime.fromMillisecondsSinceEpoch(this.widget.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  Widget getReceivedMessageTextLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.widget.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.widget.chat.user.name,
                          style: Get.textTheme.bodyText2.merge(TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Get.theme.primaryColor))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(
                          widget.chat.text,
                          style: Get.textTheme.bodyText1
                              .merge(TextStyle(color: Get.theme.primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('HH:mm | d, MMMM y', Get.locale.toString()).format(
                  DateTime.fromMillisecondsSinceEpoch(this.widget.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  Widget getReceivedMessageImageLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.widget.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.widget.chat.user.name,
                          style: Get.textTheme.bodyText2.merge(TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Get.theme.primaryColor))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.GALLERY, arguments: {
                              'media': [
                                new Media(
                                    id: this.widget.chat.text,
                                    url: this.widget.chat.text)
                              ],
                              'current': new Media(
                                  id: this.widget.chat.text,
                                  url: this.widget.chat.text),
                              'heroTag': 'chat_image'
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 200,
                              imageUrl: this.widget.chat.text,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.link_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('HH:mm | d, MMMM y', Get.locale.toString()).format(
                  DateTime.fromMillisecondsSinceEpoch(this.widget.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.caption,
            ),
          )
        ],
      ),
    );
  }
}
