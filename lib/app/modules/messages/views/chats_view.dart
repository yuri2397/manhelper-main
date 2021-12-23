import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:home_services/app/modules/global_widgets/image_field_widget.dart';
import 'package:home_services/app/modules/global_widgets/offerImageController.dart';
import 'package:home_services/app/modules/global_widgets/text_field_widget.dart';
import 'package:home_services/app/modules/post_request/controllers/post_request_controller.dart';
import 'package:home_services/app/modules/post_request/controllers/post_requests_controller.dart';
import 'package:home_services/app/modules/post_request/widgets/multiFilePicker.dart';
import 'package:home_services/common/ui.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/chat_model.dart';
import '../../../models/media_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_message_item_widget.dart';

// ignore: must_be_immutable
class ChatsView extends GetView<MessagesController> {
  final _myListKey = GlobalKey<AnimatedListState>();

  String field;
  ValueChanged<String> uploadCompleted;
  File images;
  Widget chatList() {
    return Obx(
      () {
        if (controller.chats.isEmpty) {
          return CircularLoadingWidget(
            height: Get.height,
            onCompleteText: "Type a message to start chat!".tr,
          );
        } else {
          return ListView.builder(
              key: _myListKey,
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              itemCount: controller.chats.length,
              shrinkWrap: false,
              primary: true,
              itemBuilder: (context, index) {
                Chat _chat = controller.chats.elementAt(index);
                _chat.user = controller.message.value.users.firstWhere(
                    (_user) => _user.id == _chat.userId,
                    orElse: () => new User(name: "-", avatar: new Media()));
                return ChatMessageItem(
                  chat: _chat,
                );
              });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.message.value = Get.arguments as Message;
    if (controller.message.value.id != null) {
      controller.listenForChats();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
            onPressed: () async {
              controller.message.value = new Message([]);
              controller.chats.clear();
              await controller.refreshMessages();
              Get.back();
            }),
        automaticallyImplyLeading: false,
        title: Obx(() {
          return Text(
            controller.message.value.name,
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: Get.textTheme.headline6,
          );
        }),
        actions: [
          InkWell(
            onTap: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OfferBottomSheet()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  backgroundColor: Get.theme.colorScheme.secondary,
                  child: Icon(Icons.add, color: Colors.white)),
            ),
          ),
          InkWell(
            onTap: () async {
              Get.offNamed('post_request');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  backgroundColor: Get.theme.colorScheme.secondary,
                  child: Icon(Icons.attach_file_sharp, color: Colors.white)),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: chatList(),
          ),
          Obx(() {
            if (controller.uploading.isTrue)
              return Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(),
              );
            else
              return SizedBox();
          }),
          Container(
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).hintColor.withOpacity(0.10),
                    offset: Offset(0, -4),
                    blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                Wrap(
                  children: [
                    SizedBox(width: 10),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl =
                            await controller.getImage(ImageSource.gallery);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          await controller.addMessage(
                              message: controller.message.value,
                              isOffer: false,
                              text: imageUrl);
                        }
                        Timer(Duration(milliseconds: 100), () {
                          controller.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.photo_outlined,
                        color: Get.theme.colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl =
                            await controller.getImage(ImageSource.camera);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          await controller.addMessage(
                              message: controller.message.value,
                              isOffer: false,
                              text: imageUrl);
                        }
                        Timer(Duration(milliseconds: 100), () {
                          controller.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Get.theme.colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: controller.chatTextController,
                    onChanged: (value) async {},
                    style: Get.textTheme.bodyText1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: "Type to start chat".tr,
                      hintStyle: TextStyle(
                          color: Get.theme.focusColor.withOpacity(0.8)),
                      suffixIcon: IconButton(
                        padding: EdgeInsetsDirectional.only(end: 20, start: 10),
                        onPressed: () {
                          print("MESSAGE VALUE ${controller.message.value}");
                          controller.addMessage(
                              isOffer: false,
                              message: controller.message.value,
                              text: controller.chatTextController.text);
                          Timer(Duration(milliseconds: 100), () {
                            controller.chatTextController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: Get.theme.colorScheme.secondary,
                          size: 30,
                        ),
                      ),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder:
                          UnderlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OfferBottomSheet extends GetView<OfferImageController> {
  final controller = Get.put(OfferImageController());
  final controller2 = Get.put(MessagesController());
  final controller3 = Get.put(PostRequestController());
  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String offerImage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Obx(() {
              return Center(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                color: Get.theme.hintColor),
                          ),
                          Text(
                            'Send Custom Offer',
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            style: Get.textTheme.headline6,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Obx(() {
                        return MultiFilePickerWidget(
                          filesNumber: controller3.filesNumber,
                          onTap: () async {
                            await controller3.chooseFiles(true);
                          },
                          onReset: () async {
                            await controller3.resetOfferSelectedFiles();
                          },
                          title: controller3.files.length == 0
                              ? "Add new file"
                              : controller3.files.length.toString() +
                                  "files selected.",
                        );
                      }),
                      // Container(
                      //   padding: EdgeInsets.only(
                      //       top: 8, bottom: 10, left: 20, right: 20),
                      //   margin: EdgeInsets.only(
                      //       left: 20, right: 20, top: 20, bottom: 20),
                      //   decoration: BoxDecoration(
                      //       color: Get.theme.primaryColor,
                      //       borderRadius: BorderRadius.all(Radius.circular(10)),
                      //       boxShadow: [
                      //         BoxShadow(
                      //             color: Get.theme.focusColor.withOpacity(0.1),
                      //             blurRadius: 10,
                      //             offset: Offset(0, 5)),
                      //       ],
                      //       border: Border.all(
                      //           color: Get.theme.focusColor.withOpacity(0.05))),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.stretch,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Container(
                      //               height: 60,
                      //               alignment: AlignmentDirectional.centerStart,
                      //               child: Text(
                      //                 'Select Image'.tr,
                      //                 style: Get.textTheme.bodyText1,
                      //                 textAlign: TextAlign.start,
                      //               ),
                      //             ),
                      //           ),
                      //           MaterialButton(
                      //             onPressed: () async {
                      //               print(offerImage);
                      //               print('res');
                      //               await controller.reset();
                      //             },
                      //             shape: StadiumBorder(),
                      //             color: Get.theme.focusColor.withOpacity(0.1),
                      //             child: Text("Reset".tr,
                      //                 style: Get.textTheme.bodyText1),
                      //             elevation: 0,
                      //             hoverElevation: 0,
                      //             focusElevation: 0,
                      //             highlightElevation: 0,
                      //           ),
                      //         ],
                      //       ),
                      //       Padding(
                      //         padding: EdgeInsets.symmetric(vertical: 10),
                      //         child: Wrap(
                      //           alignment: WrapAlignment.start,
                      //           spacing: 5,
                      //           runSpacing: 8,
                      //           children: [
                      //             if (controller.image.value != null)
                      //               ClipRRect(
                      //                 borderRadius:
                      //                     BorderRadius.all(Radius.circular(10)),
                      //                 child: Image.file(
                      //                   controller.image.value,
                      //                   fit: BoxFit.cover,
                      //                   width: 100,
                      //                   height: 100,
                      //                 ),
                      //               ),
                      //             GestureDetector(
                      //               onTap: () async {
                      //                 controller3.chooseFiles().then((value) {
                      //                   controller3.postRequest();
                      //                 });
                      //               },
                      //               child: Container(
                      //                 width: 100,
                      //                 height: 100,
                      //                 alignment: Alignment.center,
                      //                 decoration: BoxDecoration(
                      //                     color: Get.theme.focusColor
                      //                         .withOpacity(0.1),
                      //                     borderRadius:
                      //                         BorderRadius.circular(10)),
                      //                 child: Icon(
                      //                     Icons.add_photo_alternate_outlined,
                      //                     size: 42,
                      //                     color: Get.theme.focusColor
                      //                         .withOpacity(0.4)),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            TextFieldWidget(
                              maxLength: 300,
                              onSaved: (value) {
                                controller.descriptionTextController.text =
                                    value;
                              },
                              validator: (input) => input.length < 3
                                  ? "Should be more than 3 letters".tr
                                  : null,
                              hintText: "description".tr,
                              labelText: "Enter description".tr,
                              iconData: Icons.description,
                            ),
                            TextFieldWidget(
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: false, decimal: true),
                              labelText: "Budget".tr,
                              hintText: "Budget".tr,
                              validator: (input) => input.length < 1
                                  ? "Please enter budget".tr
                                  : null,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                              onSaved: (input) =>
                                  controller.budgetTextController.text = input,
                            ),
                            TextFieldWidget(
                              keyboardType: TextInputType.number,
                              onSaved: (input) =>
                                  controller.timeController.text = input,
                              validator: (input) => input.length < 1
                                  ? "Please enter days".tr
                                  : null,
                              hintText: "days".tr,
                              labelText: "Enter days".tr,
                              iconData: Icons.view_day_sharp,
                            ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        minWidth: 300,
                        height: 50,
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            if (controller3.fileUrls.length > 0) {
                              formKey.currentState.save();
                              controller2.addMessage(
                                isOffer: true,
                                description:
                                    controller.descriptionTextController.text,
                                price: controller.budgetTextController.text,
                                timeFrame: controller.timeController.text,
                                media: controller3.fileUrls,
                                message: controller2.message.value,
                              );
                              print('here');
                              Navigator.of(context).pop();
                              controller3.resetOfferSelectedFilesd();
                              print(controller.descriptionTextController.text);
                            } else {
                              Get.showSnackbar(Ui.ErrorSnackBar(
                                  message: "Please select some files.".tr));
                            }
                          }
                        },
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: controller3.fileUrls.length == 0
                            ? Colors.grey
                            : Get.theme.colorScheme.secondary,
                        child: Text("Send Offer".tr,
                            style: Get.textTheme.bodyText2.merge(TextStyle(
                                color: controller3.fileUrls.length == 0
                                    ? Colors.black
                                    : Get.theme.primaryColor))),
                        elevation: 0,
                        highlightElevation: 0,
                        hoverElevation: 0,
                        focusElevation: 0,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
