import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:buntsmatrimony/custom_widget.dart';
import 'package:buntsmatrimony/edit_additional_details.dart';
import 'package:buntsmatrimony/edit_education_profession_details.dart';
import 'package:buntsmatrimony/edit_family_details.dart';
import 'package:buntsmatrimony/edit_horoscope_details.dart';
import 'package:buntsmatrimony/edit_personal_details.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_model.dart';
import 'api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ProfilePage1 extends StatefulWidget {
  // final String matri_id;
  final dynamic user;
  const ProfilePage1({super.key, this.user});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage1> {
  late Future<myProfileData> _myProfileDataFuture;
  late Future<List<AdditionalImagesData>> _myAdditionalImages;
  late Future<DashboardData> _dashboardDataFuture;
  String profileImageUrl = "";
  String storedProfileUrl = "";
  Color appcolor = Color(0xFFea4a57);

  @override
  void initState() {
    super.initState();
    _loadStoredProfileImage();
    _myProfileDataFuture = ApiService.fetchmyProfileData(context);
    _myAdditionalImages = ApiService.fetchAdditionalImages();
    _dashboardDataFuture = ApiService.fetchDashboardData(context);
  }

  File? profileImage;
  final ImagePicker picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _storeProfileImage(String imageUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imageUrl);
  }

  Future<void> _loadStoredProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedProfileUrl = prefs.getString('profile_image') ?? "";
    });
  }

  TableRow _buildProfileRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 211, 138, 224),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            value,
            style: const TextStyle(fontSize: 17, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dob) {
    if (dob.isNotEmpty) {
      List<String> parts = dob.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    }
    return dob;
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      // backgroundColor: Colors.black87
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('profile'),
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            String? savedProfileUrl = prefs.getString('profile_image');
            String? currentProfileUrl = prefs.getString(
              'current_profile_image',
            );
            await prefs.setString(
              'current_profile_image',
              savedProfileUrl ?? "",
            );
            print("Current URL: $currentProfileUrl");
            print("Saved URL: $savedProfileUrl");

            if (currentProfileUrl == savedProfileUrl) {
              print("Storing initial profile image as current.");
              Navigator.pop(context);
            } else if (currentProfileUrl != savedProfileUrl) {
              print("Profile image updated, navigating to MainScreen.");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            } else {
              print("No changes detected, just popping.");
              Navigator.pop(context);
            }
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<myProfileData>(
            future: _myProfileDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    "No profile data found",
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              }

              // final user = snapshot.data!.dataout[0];
              userprofile profile = snapshot.data!.dataout[0];
              print("Profile status:${profile.profileStatus}");

              profileImageUrl = profile.url;

              _storeProfileImage(profileImageUrl);

              if (profileImageUrl.isEmpty ||
                  profileImageUrl.contains("/null") ||
                  profileImageUrl == "https://www.sharutech.com/matrimony") {
                profileImageUrl = profile.gender == "1"
                    ? 'assets/2.png'
                    : 'assets/1.png';
              }

              print("Updated Profile URL: $profileImageUrl");

              print("Profile Image URL: ${profile.url}");
              print("Profile Gender: ${profile.gender}");
              print("Profile Image is NULL: ${profileImage == null}");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.white,
                        backgroundImage: (profileImage != null)
                            ? FileImage(profileImage!)
                            : (profileImageUrl.startsWith("http")
                                  ? NetworkImage(profileImageUrl)
                                        as ImageProvider
                                  : AssetImage(profileImageUrl)),
                        onBackgroundImageError: (_, __) {
                          setState(() {
                            profileImageUrl = (widget.user.gender == "1")
                                ? 'assets/2.png'
                                : 'assets/1.png';
                          });
                        },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 237, 106, 66),
                            size: 20,
                          ),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (pickedFile != null) {
                              CroppedFile? cropped = await ImageCropper()
                                  .cropImage(
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

                                String newMainImagePath = imageFile.path
                                    .replaceAll(RegExp(r'\.jpg$'), '.jpeg');
                                File renamedMainImage = await imageFile.rename(
                                  newMainImagePath,
                                );

                                String apiEndpoint =
                                    "https://www.sharutech.com/matrimony/upload_image.php";

                                try {
                                  var request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse(apiEndpoint),
                                  );
                                  request.fields.addAll({
                                    'matri_id': profile.matriId,
                                    'id': profile.id,
                                    'photo_type': '1',
                                    'type': 'update_profiePhoto',
                                  });

                                  String? mimeType = lookupMimeType(
                                    renamedMainImage.path,
                                  );
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

                                  http.StreamedResponse response = await request
                                      .send();

                                  if (response.statusCode == 200) {
                                    String responseBody = await response.stream
                                        .bytesToString();
                                    print("API Response Data: $responseBody");
                                    Fluttertoast.showToast(
                                      msg:
                                          "Profile photo updated successfully.",
                                    );

                                    setState(() {
                                      profileImage = renamedMainImage;
                                      _myProfileDataFuture =
                                          ApiService.fetchmyProfileData(
                                            context,
                                          );
                                      _myAdditionalImages =
                                          ApiService.fetchAdditionalImages();
                                    });
                                  } else {
                                    print("Error: ${response.reasonPhrase}");
                                    Fluttertoast.showToast(
                                      msg: "Failed to update profile photo.",
                                    );
                                  }
                                } catch (e) {
                                  print("Error occurred: $e");
                                  Fluttertoast.showToast(msg: "Error: $e");
                                }
                              }
                            }
                          },
                        ),
                      ),
                      if (_isLoading)
                        Positioned(
                          top: 30,
                          right: 30,
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate('basic_details'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 237, 106, 66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 237, 106, 66),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PersonalDetails(profile: profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildProfileRow(
                        '${localizations.translate('name')}:',
                        '${profile.firstName} ${profile.lastName}',
                      ),
                      _buildProfileRow(
                        '${localizations.translate('dob')}:',
                        _formatDate(profile.dob),
                      ),
                      _buildProfileRow(
                        '${localizations.translate('age')}:',
                        profile.age,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('gender')}:',
                        profile.genderType,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('marital_status')}:',
                        profile.status,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('phone_number')}:',
                        profile.phone,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('email')}:',
                        profile.email,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('creator_name')}:',
                        profile.creatorName,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('creator_phone')}:',
                        profile.creatorPhone.toString(),
                      ),
                      _buildProfileRow(
                        '${localizations.translate('sub_caste')}:',
                        profile.subCaste,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate('additional_details'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 237, 106, 66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 237, 106, 66),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdditionalDetailsPage(profile: profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildProfileRow(
                        '${localizations.translate('height')}:',
                        "${profile.height}cm",
                      ),
                      _buildProfileRow(
                        '${localizations.translate('weight')}:',
                        "${profile.weight}kg",
                      ),
                      _buildProfileRow(
                        '${localizations.translate('blood_group')}:',
                        profile.bloodGroup,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('complexion')}:',
                        profile.complexion,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('disabilities')}:',
                        profile.disability,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('country')}:',
                        profile.country,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('state')}:',
                        profile.state,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('city')}:',
                        profile.city,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('address')}:',
                        profile.address,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate('education_profession'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 237, 106, 66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 237, 106, 66),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EducationProfessionPage(profile: profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildProfileRow(
                        '${localizations.translate('qualification')}:',
                        profile.qualification,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('specialisation')}:',
                        profile.specialization,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('profession')}:',
                        profile.occupation,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('company_name')}:',
                        profile.company,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('company_city')}:',
                        profile.companyCity,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('salary_range')}:',
                        profile.salary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate('horoscope'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 237, 106, 66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 237, 106, 66),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HoroscopeDetailsPage(profile: profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildProfileRow(
                        '${localizations.translate('nakshatra')}:',
                        profile.nakshatra,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('rashi')}:',
                        profile.rashi,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('gothra')}:',
                        profile.gothra,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('birth_place')}:',
                        profile.birthPlace,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('birth_time')}:',
                        profile.birthTime,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('family_deity')}:',
                        profile.familyDiety,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  //Family details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate('family_details'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 237, 106, 66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 237, 106, 66),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FamilyDetailsPage(profile: profile),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      if (profile.maritalStatus != "1")
                        _buildProfileRow(
                          '${localizations.translate('no_of_kids')}:',
                          profile.kids,
                        ),
                      _buildProfileRow(
                        '${localizations.translate('father_name')}:',
                        profile.fatherName,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('father_occupation')}:',
                        profile.fatherOccupation,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('mother_name')}:',
                        profile.motherName,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('mother_occupation')}:',
                        profile.motherOccupation,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('no_of_brothers')}:',
                        profile.numberOfBrothers.toString(),
                      ),
                      _buildProfileRow(
                        '${localizations.translate('no_of_sisters')}:',
                        profile.numberOfSisters.toString(),
                      ),
                      _buildProfileRow(
                        '${localizations.translate('permanent_address')}:',
                        profile.homeTown,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('mother_tongue')}:',
                        profile.motherTongue,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('family_type')}:',
                        profile.familyType,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('reference_name')}:',
                        profile.reference,
                      ),
                      _buildProfileRow(
                        '${localizations.translate('reference_phone')}:',
                        profile.reference_no,
                      ),
                    ],
                  ),
                  SizedBox(height: 60),

                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildProfileRow(
                        '${localizations.translate('remarks')}:',
                        profile.remark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Text(
                    localizations.translate('images'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 237, 106, 66),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 15),

                  FutureBuilder<List<AdditionalImagesData>>(
                    future: _myAdditionalImages,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            localizations.translate('no_images'),
                            style: TextStyle(color: Colors.black87),
                          ),
                        );
                      }

                      List<AdditionalImagesData> images = snapshot.data!;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          String imageUrl =
                              "https://www.sharutech.com/matrimony/${images[index].url}";

                          print("Loading Image: $imageUrl");

                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.5),
                                builder: (context) {
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Container(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.8,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                // Image Display
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 150,
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            print(
                                              "Image failed to load: $imageUrl",
                                            );
                                            return const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            );
                                          },
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  localizations.translate(
                                                    'choose',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.close),
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    setAsProfilePhoto(
                                                      profile.matriId,
                                                      images[index].slId
                                                          .toString(),
                                                    );
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      _myProfileDataFuture =
                                                          ApiService.fetchmyProfileData(
                                                            context,
                                                          );
                                                      _myAdditionalImages =
                                                          ApiService.fetchAdditionalImages();
                                                    });
                                                  },
                                                  child: Text(
                                                    localizations.translate(
                                                      'set_profile',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextButton(
                                                  onPressed: () async {
                                                    const String apiUrl =
                                                        "https://www.sharutech.com/matrimony/edit_image.php";

                                                    final Map<String, String>
                                                    body = {
                                                      "type": "delet",
                                                      "matri_id":
                                                          profile.matriId,
                                                      "sl_id": images[index]
                                                          .slId
                                                          .toString(),
                                                    };

                                                    try {
                                                      final response =
                                                          await http.post(
                                                            Uri.parse(apiUrl),
                                                            headers: {
                                                              "Content-Type":
                                                                  "application/json",
                                                            },
                                                            body: jsonEncode(
                                                              body,
                                                            ),
                                                          );

                                                      final Map<String, dynamic>
                                                      responseData = jsonDecode(
                                                        response.body,
                                                      );

                                                      if (response.statusCode ==
                                                              200 &&
                                                          responseData["message"]["p_out_mssg_flg"] ==
                                                              "Y") {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Photo deleted successfully!",
                                                            ),
                                                          ),
                                                        );

                                                        final SharedPreferences
                                                        prefs =
                                                            await SharedPreferences.getInstance();
                                                        prefs.setString(
                                                          'myImageUrl',
                                                          '',
                                                        );
                                                        await prefs.setBool(
                                                          'hasUploadedImage',
                                                          false,
                                                        );

                                                        Navigator.pop(context);

                                                        setState(() {
                                                          profileImage = null;

                                                          profileImageUrl =
                                                              (profile.gender ==
                                                                  "1")
                                                              ? 'assets/2.png'
                                                              : 'assets/1.png';

                                                          _myProfileDataFuture =
                                                              ApiService.fetchmyProfileData(
                                                                context,
                                                              );
                                                          _myAdditionalImages =
                                                              ApiService.fetchAdditionalImages();
                                                        });
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Failed: ${responseData["message"]["p_out_mssg"]}",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Error: $e",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    localizations.translate(
                                                      'delete_photo',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Color.fromARGB(
                                          255,
                                          237,
                                          106,
                                          66,
                                        ),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> setAsProfilePhoto(String matriId, String slId) async {
    String apiUrl = "https://www.sharutech.com/matrimony/edit_image.php";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "profile",
          "matri_id": matriId,
          "sl_id": slId,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          jsonResponse["message"]["p_out_mssg_flg"] == "Y") {
        String newProfileImage =
            "https://www.sharutech.com/matrimony/${jsonResponse['newProfileImage']}";

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_profile_image', newProfileImage);

        Fluttertoast.showToast(msg: "Profile photo updated successfully.");

        _storeProfileImage(newProfileImage);

        setState(() {
          _myProfileDataFuture = ApiService.fetchmyProfileData(context);
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed: ${jsonResponse["message"]["p_out_mssg"]}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
