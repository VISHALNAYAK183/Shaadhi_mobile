import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:buntsmatrimony/custom_widget.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:buntsmatrimony/lang.dart';
import 'partner_preference.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UploadImagePage extends StatefulWidget {
  final String matriId;
  final String id;
  const UploadImagePage({super.key, required this.matriId, required this.id});

  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? mainImage;
  List<File?> additionalImages = [null, null, null, null, null];
  final ImagePicker picker = ImagePicker();
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInternet();

    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() {
        _isOffline =
            !result.contains(ConnectivityResult.mobile) &&
            !result.contains(ConnectivityResult.wifi);
      });
    });
  }

  Future<void> _checkInternet() async {
    var localizations = AppLocalizations.of(context);
    List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();
    setState(() {
      _isOffline =
          !connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi);
    });

    if (_isOffline) {
      _showPopup(
        localizations.translate('no_internet'),
        localizations.translate('no_internet_msg'),
      );
    }
  }

  void _showPopup(String title, String message) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.translate('ok'),
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(bool isMain, int? index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? croppedImage = await cropImage(File(pickedFile.path));
      if (croppedImage != null) {
        setState(() {
          if (isMain) {
            mainImage = croppedImage;
          } else if (index != null) {
            additionalImages[index] = croppedImage;
          }
        });
      }
    }
  }

  Future<File?> cropImage(File imageFile) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio3x2,
          ],
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
    return cropped != null ? File(cropped.path) : null;
  }

  Future<void> uploadImages() async {
    var localizations = AppLocalizations.of(context);
    if (_isOffline) {
      _showPopup(
        localizations.translate('no_internet'),
        localizations.translate('no_internet_msg'),
      );
      return;
    }
    if (mainImage == null) {
      Fluttertoast.showToast(msg: localizations.translate('upload_one'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String apiEndpoint =
        "https://www.sharutech.com/matrimony/upload_image.php";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
      request.fields.addAll({
        'matri_id': widget.matriId,
        'photo_type': '1',
        'type': 'update_profilePhoto',
      });

      String newMainImagePath = mainImage!.path.replaceAll(
        RegExp(r'\.jpg$'),
        '.jpeg',
      );
      File renamedMainImage = await mainImage!.rename(newMainImagePath);

      String? mimeType = lookupMimeType(renamedMainImage.path);
      MediaType mediaType = mimeType == 'image/png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          renamedMainImage.path,
          contentType: mediaType,
        ),
      );

      for (int i = 0; i < additionalImages.length; i++) {
        if (additionalImages[i] != null) {
          String newAdditionalImagePath = additionalImages[i]!.path.replaceAll(
            RegExp(r'\.jpg$'),
            '.jpeg',
          );
          File renamedAdditionalImage = await additionalImages[i]!.rename(
            newAdditionalImagePath,
          );

          String? additionalMimeType = lookupMimeType(
            renamedAdditionalImage.path,
          );
          MediaType additionalMediaType = additionalMimeType == 'image/png'
              ? MediaType('image', 'png')
              : MediaType('image', 'jpeg');

          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              renamedAdditionalImage.path,
              contentType: additionalMediaType,
            ),
          );
        }
      }

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("API Response Data: $responseBody");
        Fluttertoast.showToast(msg: "Images uploaded successfully.");
        setState(() {
          _isLoading = false;
        });

        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FilterDialog(matriId: widget.matriId, id: widget.id),
              ),
            );
          }
        });
      } else {
        print("Error: ${response.reasonPhrase}");
        Fluttertoast.showToast(msg: "Failed to upload images.");
      }
    } catch (e) {
      print("Error occurred: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildImageBox({File? image, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(0),
          color: Colors.grey[200],
        ),
        child: image == null
            ? const Center(child: Icon(Icons.add, color: Colors.blue, size: 40))
            : ClipRRect(child: Image.file(image, fit: BoxFit.cover)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                localizations.translate('main_image'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              buildImageBox(
                image: mainImage,
                onTap: () => pickImage(true, null),
              ),
              const SizedBox(height: 40),
              Text(
                localizations.translate('additional_images'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  3,
                  (index) => buildImageBox(
                    image: additionalImages[index],
                    onTap: () => pickImage(false, index),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : customElevatedButton(
                      uploadImages,
                      localizations.translate('submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

uploadImage(String matri_id) async {
  final ImagePicker picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio3x2,
          ],
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (cropped != null) {
      File imageFile = File(cropped.path);

      String newMainImagePath = imageFile.path.replaceAll(
        RegExp(r'\.jpg$'),
        '.jpeg',
      );
      File renamedMainImage = await imageFile.rename(newMainImagePath);

      String apiEndpoint =
          "https://www.sharutech.com/matrimony/upload_image.php";

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
        request.fields.addAll({
          'matri_id': matri_id,
          'photo_type': '1',
          'type': 'update_profiePhoto',
        });

        String? mimeType = lookupMimeType(renamedMainImage.path);
        MediaType mediaType = mimeType == 'image/png'
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            renamedMainImage.path,
            contentType: mediaType,
          ),
        );

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          print("API Response Data: $responseBody");
          Fluttertoast.showToast(msg: "Profile photo updated successfully.");
          return "uploaded";
          // setState(() {});
        } else {
          print("Error: ${response.reasonPhrase}");
          Fluttertoast.showToast(msg: "Failed to update profile photo.");
          return "error";
        }
      } catch (e) {
        print("Error occurred: $e");
        Fluttertoast.showToast(msg: "Error: $e");
        return "error";
      }
    }
    return "error";
  }
  return "error";
}
