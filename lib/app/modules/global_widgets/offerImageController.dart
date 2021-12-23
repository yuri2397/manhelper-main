import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../../repositories/chat_repository.dart';
import '../../../common/ui.dart';
import 'package:image_picker/image_picker.dart';

class OfferImageController extends GetxController {
  ChatRepository _chatRepository;
  Rx<String> offerImage = "".obs;
  final descriptionTextController = TextEditingController();
  final timeController = TextEditingController();
  final budgetTextController = TextEditingController();

  GlobalKey<FormState> offerForm;
  OfferImageController() {
    _chatRepository = new ChatRepository();
  }

  @override
  void onClose() {
    budgetTextController.dispose();
    descriptionTextController.dispose();
    timeController.dispose();
  }

  Rx<File> image = Rx<File>(null);

  final uploading = false.obs;
  void reset() {
    offerImage.value = "";
    image.value = null;
  }

  Future pickImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile pickedFile =
        await imagePicker.pickImage(source: source, imageQuality: 80);
    File imageFile = File(pickedFile.path);
    if (imageFile != null) {
      print(imageFile);
      image.value = imageFile;
      if (imageFile != null) {
        try {
          uploading.value = true;
          return await _chatRepository.uploadFile(imageFile);
        } catch (e) {
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }
      } else {
        Get.showSnackbar(
            Ui.ErrorSnackBar(message: "Please select an image file".tr));
      }
    }
  }

  Future resetImage() async {
    if (image != null) {
      image = Rx<File>(null);
    }
  }

  void saveForm() async {
    // Get.focusScope.unfocus();
    if (offerForm.currentState.validate()) {}
  }
}
