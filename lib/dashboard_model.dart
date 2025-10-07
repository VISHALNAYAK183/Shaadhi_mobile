import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String age;
  final String matriId;
  final String imageUrl;
  final String gender;
  final String planStatus;

  User({
    required this.name,
    required this.age,
    required this.matriId,
    required this.imageUrl,
    required this.gender,
    required this.planStatus,
  });

  factory User.fromJson(Map<String, dynamic> json, String baseUrl) {
    return User(
      name: json['first_name'].toString(),
      age: json['age'].toString(),
      matriId: json['matri_id'].toString(),
      imageUrl: baseUrl + json['url'].toString(),
      gender: json['gender'].toString(),
      planStatus: json['plan_status'].toString(),
    );
  }
}

class Profile {
  final String myName;
  final String myAge;
  final String myMatriId;
  final String myImageUrl;
  final String myBaseUrl;
  final String profileUrl;
  final String percentage;
  final String Score;
  final String expiry_date;
  final String planStatus;
  final String gender;
  final String creator_phone;
  

  Profile({
    required this.myName,
    required this.myAge,
    required this.myMatriId,
    required this.myImageUrl,
    required this.myBaseUrl,
    required this.profileUrl,
    required this.percentage,
    required this.Score,
    required this.expiry_date,
    required this.planStatus,
    required this.gender,
    required this.creator_phone
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    String profilePhoto = json['profile_photo']?.toString() ?? '';
    String baseUrl = json['base_url']?.toString() ?? '';
    String profileUrl =
        (baseUrl.isNotEmpty && profilePhoto.isNotEmpty) ? baseUrl + profilePhoto : '';

    return Profile(
      myName: "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim(),
      myAge: json['age']?.toString() ?? '',
      myMatriId: json['matri_id']?.toString() ?? '',
      myImageUrl: profileUrl,
      myBaseUrl: baseUrl,
      profileUrl: profileUrl,
      percentage: json['percent']?.toString() ?? '0',
      Score: json['score']?.toString() ?? '0',
      expiry_date: json['subscription_date']?.toString() ?? '',
      planStatus: json['plan_status']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      creator_phone: json['creator_phone']?.toString() ?? '',
    );
  }
}

class ProfileList {
  final String liked_by;
  final String i_liked;
  final String viewed_by;
  final String i_viewed;
  final String mutual_liked;
  final String profile_contacted;
  final String shortlisted;

  ProfileList({
    required this.liked_by,
    required this.i_liked,
    required this.viewed_by,
    required this.i_viewed,
    required this.mutual_liked,
    required this.profile_contacted,
    required this.shortlisted,
  });

  factory ProfileList.fromJson(Map<String, dynamic> json) {
    return ProfileList(
      liked_by: json['liked_by'].toString(),
      i_liked: json['i_liked'].toString(),
      viewed_by: json['viewed_by'].toString(),
      i_viewed: json['i_viewed'].toString(),
      mutual_liked: json['mutual_liked'].toString(),
      profile_contacted: json['profile_contacted'].toString(),
      shortlisted: json['shortlisted'].toString(),
    );
  }
}

class AppNotification {
  final String notiurl;

  AppNotification({required this.notiurl});

  factory AppNotification.fromJson(Map<String, dynamic> json, String baseUrl) {
    return AppNotification(
      notiurl: baseUrl + json['img_url'],
    );
  }
}

class DashboardData {
  final List<User> recentlyJoined;
  final List<User> recentlyLoggedIn;
  final List<Profile> myProfile;
  final List<User> matched;
  final List<AppNotification> advnotifivation;
  final ProfileList profilecount;
  final String baseUrl;

  DashboardData({
    required this.recentlyJoined,
    required this.recentlyLoggedIn,
    required this.myProfile,
    required this.matched,
    required this.baseUrl,
    required this.profilecount,
    required this.advnotifivation,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // ✅ Since my_profile is an object, not a list
    final myProfileJson = json['my_profile'];

    String baseUrl = myProfileJson['base_url'].toString();
    String creatorPhone = myProfileJson['creator_phone'].toString();

    Map<String, String> maxpPofileCountData = {
      "maxProfile": myProfileJson['max_viewed'].toString(),
      "maxContact": myProfileJson['max_contact'].toString(),
      "maxMessage": myProfileJson['max_message'].toString(),
      "usedProfile": myProfileJson['viewed_count'].toString(),
      "usedContact": myProfileJson['contact_count'].toString(),
      "usedMessage": myProfileJson['message_count'].toString(),
      "planStatus": myProfileJson['plan_status'].toString(),
      "creator_phone": myProfileJson['creator_phone'].toString(),
    };

    List<User> recentlyJoinedList = (json['recently_joined'] as List)
        .map((user) => User.fromJson(user, baseUrl))
        .toList();

    List<User> recentlyLoggedInList = (json['recently_logedin'] as List)
        .map((user) => User.fromJson(user, baseUrl))
        .toList();

    List<User> matchedList = (json['matched'] as List)
        .map((user) => User.fromJson(user, baseUrl))
        .toList();

  
    List<Profile> myProfileList = [Profile.fromJson(myProfileJson)];

  List<AppNotification> notificationList = (json['adv_notifications'] as List)
    .map((n) => AppNotification.fromJson(n, baseUrl))
    .toList();


    ProfileList profileCountData = ProfileList.fromJson(json['profile_count']);

    _saveBaseUrl(baseUrl, creatorPhone, maxpPofileCountData);

    return DashboardData(
      recentlyJoined: recentlyJoinedList,
      recentlyLoggedIn: recentlyLoggedInList,
      myProfile: myProfileList,
      matched: matchedList,
      baseUrl: baseUrl,
      profilecount: profileCountData,
      advnotifivation: notificationList,
    );
  }

  static Future<void> _saveBaseUrl(
    String baseUrl,
    String creatorPhone,
    Map<String, String> maxpPofileCountData,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', baseUrl);
    await prefs.setString('maxProfile', maxpPofileCountData["maxProfile"] ?? "0");
    await prefs.setString('maxMessage', maxpPofileCountData["maxMessage"] ?? "0");
    await prefs.setString('maxContact', maxpPofileCountData["maxContact"] ?? "0");
    await prefs.setString('usedProfile', maxpPofileCountData["usedProfile"] ?? "0");
    await prefs.setString('usedMessage', maxpPofileCountData["usedMessage"] ?? "0");
    await prefs.setString('usedContact', maxpPofileCountData["usedContact"] ?? "0");
    await prefs.setString('creatorPhone', creatorPhone);
    await prefs.setString('planStatus', maxpPofileCountData["planStatus"] ?? "");
  }
}


class LoginData {
  final List<UserLogin> dataout;

  LoginData({
    required this.dataout,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    List<UserLogin> loginList = (json['dataout'] as List)
        .map((user) => UserLogin.fromJson(user as Map<String, dynamic>))
        .toList();  

    return LoginData(
      dataout: loginList,
    );
  }
}

class UserLogin {
  final int id;
  final String matriId;
  final String phone;

  UserLogin({
    required this.id,
    required this.matriId,
    required this.phone,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: json['id'] ?? 0, // Default to 0 if null
      matriId: json['matri_id'] ?? '',
      phone: json['phone']?.toString() ?? '', // Ensure phone is a String
    );
  }
}
//Check Phone Number

class CheckNumber {
  final List<CheckNumberData> dataout;
  final String message;
  final String messageFlag;

  CheckNumber(
      {required this.dataout,
      required this.message,
      required this.messageFlag});

  /// Convert JSON to `CheckNumber` object
  factory CheckNumber.fromJson(Map<String, dynamic> json) {
    List<CheckNumberData> profileList = [];

    if (json['dataout'] != null && json['dataout'] is List) {
      profileList = (json['dataout'] as List)
          .map((user) => CheckNumberData.fromJson(user))
          .toList();
    }

    String messageFlag = json['message']['p_out_mssg_flg'] ?? 'N';
    String message = json['message']['p_out_mssg'] ?? 'Unknown error';

    return CheckNumber(
      dataout: profileList,
      message: message,
      messageFlag: messageFlag,
    );
  }
}

class CheckNumberData {
  final int id;
  final String matriId;
  final String phone;

  CheckNumberData(
      {required this.id, required this.matriId, required this.phone});

  /// Convert JSON to `CheckNumberData` object
  factory CheckNumberData.fromJson(Map<String, dynamic> json) {
    return CheckNumberData(
      id: json['id'] ?? 0, // Ensure id is always an int
      matriId: json['matri_id']?.toString() ?? 'Unknown', // Prevent null issues
      phone: json['phone']?.toString() ?? 'Unknown', // Ensure phone is a string
    );
  }
}

//Send OTP
class SendOtp {
  final List<sendotpData> data;
  final String message;
  final String messageFlag;

  SendOtp(
      {required this.data, required this.message, required this.messageFlag});

  /// Convert JSON to `CheckNumber` object
  factory SendOtp.fromJson(Map<String, dynamic> json) {
    List<sendotpData> profileList = [];

    if (json['data'] != null && json['data'] is List) {
      profileList = (json['data'] as List)
          .map((user) => sendotpData.fromJson(user))
          .toList();
    }

    String messageFlag = json['message']['p_out_mssg_flg'] ?? 'N';
    String message = json['message']['p_out_mssg'] ?? 'Unknown error';

    return SendOtp(
      data: profileList,
      message: message,
      messageFlag: messageFlag,
    );
  }
}

class sendotpData {
  final String otp;

  sendotpData({required this.otp});

  /// Convert JSON to `CheckNumberData` object
  factory sendotpData.fromJson(Map<String, dynamic> json) {
    return sendotpData(
      otp: json['Otp']?.toString() ?? '',
    );
  }
}

//New Password
class NewPasswordResponse {
  final String messageFlag;
  final String message;

  NewPasswordResponse({required this.messageFlag, required this.message});

  factory NewPasswordResponse.fromJson(Map<String, dynamic> json) {
    return NewPasswordResponse(
      messageFlag: json['message']['p_out_mssg_flg'] ?? 'N',
      message: json['message']['p_out_mssg'] ?? 'Error updating password',
    );
  }
}

class NewPassword {
  final String messageFlag;
  final String message;

  NewPassword({required this.messageFlag, required this.message});

  factory NewPassword.fromJson(Map<String, dynamic> json) {
    return NewPassword(
      messageFlag: json['message']['p_out_mssg_flg'] ?? 'N',
      message: json['message']['p_out_mssg'] ?? 'Error updating password',
    );
  }
}

//My Profile

class myProfileData {
  final List<userprofile> dataout;

  myProfileData({required this.dataout});

  static Future<myProfileData> fromJson(Map<String, dynamic> json) async {
    List<Future<userprofile>> futureProfiles = (json['dataout'] as List)
        .map((user) => userprofile.fromJson(user))
        .toList();

    List<userprofile> profileList = await Future.wait(futureProfiles);

    return myProfileData(
      dataout: profileList,
    );
  }
}

class userprofile {
  final String id;
  final String matriId;
  late String maritalStatus;
  late String status;
  final String profileCreatorId;
  final String profileCreator;
  final String profileForId;
  final String profileFor;
  final String creatorPhone;
  final String creatorName;
  late final String firstName;
  late final String lastName;
  late final String phone;
  late final String email;
  late final String dob;
  String age;
  String profileStatus;
  String gender;
  String genderType;
  String kids;
  String address;
  String caste;
  String city;
  String country;
  String state;
  String cityId;
  String countryId;
  String stateId;
  String planStatus;
  String score;
  String percent;
  late String subCaste;
  late String subCasteId;
  String company;
  String companyCity;
  String specialization;
  String qualification;
  String occupation;
  String salary;
  String height;
  String weight;
  String bloodGroup;
  String motherTongue;
  String complexion;
  String disability;
  String rashi;
  String nakshatra;
  String gothra;
  String birthTime;
  String birthPlace;
  String horoscope;
  String familyDiety;
  String fatherName;
  String fatherOccupation;
  String motherName;
  String motherOccupation;
  String numberOfBrothers;
  String numberOfSisters;
  String familyType;
  String homeTown;
  String url;
  String reference;
  String reference_no;
  String remark;

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  userprofile({
    required this.id,
    required this.matriId,
    required this.maritalStatus,
    required this.status,
    required this.profileCreatorId,
    required this.profileCreator,
    required this.profileForId,
    required this.profileFor,
    required this.creatorPhone,
    required this.creatorName,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.dob,
    required this.age,
    required this.profileStatus,
    required this.gender,
    required this.genderType,
    required this.kids,
    required this.address,
    required this.caste,
    required this.city,
    required this.country,
    required this.state,
    required this.cityId,
    required this.countryId,
    required this.stateId,
    required this.planStatus,
    required this.score,
    required this.percent,
    required this.subCaste,
    required this.subCasteId,
    required this.company,
    required this.companyCity,
    required this.specialization,
    required this.qualification,
    required this.occupation,
    required this.salary,
    required this.height,
    required this.weight,
    required this.bloodGroup,
    required this.motherTongue,
    required this.complexion,
    required this.disability,
    required this.rashi,
    required this.nakshatra,
    required this.gothra,
    required this.birthTime,
    required this.birthPlace,
    required this.horoscope,
    required this.familyDiety,
    required this.fatherName,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherOccupation,
    required this.numberOfBrothers,
    required this.numberOfSisters,
    required this.familyType,
    required this.homeTown,
    required this.url,
    required this.reference,
    required this.reference_no,
    required this.remark,
  });

  static Future<userprofile> fromJson(Map<String, dynamic> json) async {
    String baseUrl = (await _getBaseUrl()) ?? '';
    return userprofile(
      id: (json['id'] ?? 0).toString(),
      matriId: (json['matri_id'] ?? '').toString(),
      maritalStatus: (json['marital_status'] ?? 0).toString(),
      status: (json['status'] ?? '').toString(),
      profileCreatorId: (json['profile_creator_id'] ?? 0).toString(),
      profileCreator: (json['profile_creator'] ?? '').toString(),
      profileForId: (json['profile_for_id'] ?? 0).toString(),
      profileFor: (json['profile_for'] ?? '').toString(),
      creatorPhone: (json['creator_phone'] ?? 0).toString(),
      creatorName: (json['creator_name'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      phone: (json['phone'] ?? 0).toString(),
      email: (json['email'] ?? '').toString(),
      dob: (json['dob'] ?? '').toString(),
      age: (json['age'] ?? 0).toString(),
      profileStatus: (json['profile_status'] ?? 0).toString(),
      gender: (json['gender'] ?? 0).toString(),
      genderType: (json['gender_type'] ?? '').toString(),
      kids: (json['kids'] ?? 0).toString(),
      address: (json['address'] ?? '').toString(),
      caste: (json['caste'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      cityId: (json['city_id'] ?? 0).toString(),
      countryId: (json['country_id'] ?? 0).toString(),
      stateId: (json['state_id'] ?? 0).toString(),
      planStatus: (json['plan_status'] ?? '').toString(),
      score: (json['score'] ?? 0).toString(),
      percent: (json['percent'] ?? 0).toString(),
      subCaste: (json['sub_caste'] ?? '').toString(),
      subCasteId: (json['sub_caste_id'] ?? 0).toString(),
      company: (json['company'] ?? '').toString(),
      companyCity: (json['company_city'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      qualification: (json['qualification'] ?? '').toString(),
      occupation: (json['occupation'] ?? '').toString(),
      salary: (json['salary'] ?? '').toString(),
      height: (json['height'] ?? 0).toString(),
      weight: (json['weight'] ?? 0).toString(),
      bloodGroup: (json['blood_group'] ?? '').toString(),
      motherTongue: (json['mother_tongue'] ?? '').toString(),
      complexion: (json['complexion'] ?? '').toString(),
      disability: (json['disability'] ?? '').toString(),
      rashi: (json['rashi'] ?? '').toString(),
      nakshatra: (json['nakshatra'] ?? '').toString(),
      gothra: (json['gothra'] ?? '').toString(),
      birthTime: (json['birth_time'] ?? '').toString(),
      birthPlace: (json['birth_place'] ?? '').toString(),
      horoscope: (json['horoscope'] ?? '').toString(),
      familyDiety: (json['family_diety'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      fatherOccupation: (json['father_ocupation'] ?? '').toString(),
      motherName: (json['mother_name'] ?? '').toString(),
      motherOccupation: (json['mother_occupation'] ?? '').toString(),
      numberOfBrothers: (json['number_of_brothers'] ?? 0).toString(),
      numberOfSisters: (json['number_of_sisters'] ?? 0).toString(),
      familyType: (json['family_type'] ?? '').toString(),
      homeTown: (json['home_town'] ?? '').toString(),
      url: (baseUrl + (json['url'] ?? '')).toString(),
      reference: (json['reference'] ?? '').toString(),
      reference_no: (json['reference_number'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
    );
  }
}


class AdditionalImagesData {
  final int slId;
  final String matriId;
  final int photoType;
  final String url;
  final int deleted;
  final String createdDate;
  final String updatedDate;

  AdditionalImagesData({
    required this.slId,
    required this.matriId,
    required this.photoType,
    required this.url,
    required this.deleted,
    required this.createdDate,
    required this.updatedDate,
  });

  factory AdditionalImagesData.fromJson(Map<String, dynamic> json) {
    return AdditionalImagesData(
      slId: json['sl_id'] ?? 0,
      matriId: json['matri_id'] ?? '',
      photoType: json['photo_type'] ?? 0,
      url: json['url'] ?? '',
      deleted: json['deleted'] ?? 0,
      createdDate: json['created_date'] ?? '',
      updatedDate: json['updated_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sl_id': slId,
      'matri_id': matriId,
      'photo_type': photoType,
      'url': url,
      'deleted': deleted,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}


//Matched

class MatchedData {
  final List<matchedprofile> dataout;

  MatchedData({required this.dataout});

  static MatchedData fromJson(Map<String, dynamic> json, String baseUrl) {
    List<matchedprofile> profileList = (json['dataout'] as List)
        .map((user) => matchedprofile.fromJson(user, baseUrl))
        .toList();

    return MatchedData(dataout: profileList);
  }
}

class matchedprofile {
  final String id;
  final String matriId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final String age;
  final String gender;
  final String genderType;
  final String planStatus;
  final String height;
  final String weight;
  final String url;

  matchedprofile({
    required this.id,
    required this.matriId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.planStatus,
    required this.height,
    required this.weight,
    required this.url,
  });

  // Convert JSON to matchedprofile object
  static matchedprofile fromJson(Map<String, dynamic> json, String baseUrl) {
    String imageUrl = json['url'] ?? '';

    // If image URL is missing or invalid, provide a default placeholder
    if (imageUrl.isEmpty || imageUrl == 'null') {
      imageUrl = 'https://via.placeholder.com/150';
    } else if (!imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/$imageUrl';
    }

    return matchedprofile(
      id: (json['id'] ?? 0).toString(),
      matriId: (json['matri_id'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      dob: (json['dob'] ?? '').toString(),
      age: (json['age'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      genderType: (json['gender_type'] ?? '').toString(),
      planStatus: (json['plan_status'] ?? '').toString(),
      height: (json['height'] ?? '').toString(),
      weight: (json['weight'] ?? '').toString(),
      url: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "matri_id": matriId,
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "dob": dob,
      "age": age,
      "gender": gender,
      "gender_type": genderType,
      "plan_status": planStatus,
      "height": height,
      "weight": weight,
      "url": url,
    };
  }

  static Future<String?> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }
}

//Liked By me

//Profile View

class ProfileViewData {
  final List<profileview> dataout;

  ProfileViewData({required this.dataout});

  static Future<ProfileViewData> fromJson(Map<String, dynamic> json) async {
    List<Future<profileview>> futureProfiles = (json['dataout'] as List)
        .map((user) => profileview.fromJson(user))
        .toList();

    List<profileview> profileList = await Future.wait(futureProfiles);

    return ProfileViewData(
      dataout: profileList,
    );
  }
}

class profileview {
  final String id;
  final String matriId;
  final String maritalStatus;
  final String status;
  final String profileCreatorId;
  final String profileCreator;
  final String profileForId;
  final String profileFor;
  final String creatorPhone;
  final String creatorName;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String dob;
  final String age;
  final String gender;
  final String genderType;
  final String cityId;
  final String countryId;
  final String stateId;
  final String city;
  final String country;
  final String state;
  final String kids;
  final String address;
  final String caste;
  final String planStatus;
  final String subCaste;
  final String subCasteId;
  final String company;
  final String companyCity;
  final String specializationId;
  final String specialization;
  final String qualification;
  final String qualificationId;
  final String occupationId;
  final String occupation;
  final String remark;
  final String createdDate;
  final String salary;
  final String height;
  final String weight;
  final String bloodGroup;
  final String motherTongueId;
  final String motherTongue;
  final String complexion;
  final String disability;
  final String rashiId;
  final String nakshatraId;
  final String gothra;
  final String sunSign;
  final String birthTime;
  final String birthPlace;
  final String horoscope;
  final String familyDiety;
  final String fatherName;
  final String fatherOccupation;
  final String motherName;
  final String motherOccupation;
  final String numberOfBrothers;
  final String numberOfSisters;
  final String familyType;
  final String homeTown;
  final String reference;
  final String referenceNumber;
  final String url;
  final String rashi;
  final String nakshatra;
  final String liked;

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('base_url'));
    return prefs.getString('base_url');

    // static Future<userprofile> fromJson(Map<String, dynamic> json) async {
    //  String baseUrl = (await _getBaseUrl()) ?? '';
  }

  profileview({
    required this.id,
    required this.matriId,
    required this.maritalStatus,
    required this.status,
    required this.profileCreatorId,
    required this.profileCreator,
    required this.profileForId,
    required this.profileFor,
    required this.creatorPhone,
    required this.creatorName,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.cityId,
    required this.countryId,
    required this.stateId,
    required this.city,
    required this.country,
    required this.state,
    required this.kids,
    required this.address,
    required this.caste,
    required this.planStatus,
    required this.subCaste,
    required this.subCasteId,
    required this.company,
    required this.companyCity,
    required this.specializationId,
    required this.specialization,
    required this.qualification,
    required this.qualificationId,
    required this.occupationId,
    required this.occupation,
    required this.remark,
    required this.createdDate,
    required this.salary,
    required this.height,
    required this.weight,
    required this.bloodGroup,
    required this.motherTongueId,
    required this.motherTongue,
    required this.complexion,
    required this.disability,
    required this.rashiId,
    required this.nakshatraId,
    required this.gothra,
    required this.sunSign,
    required this.birthTime,
    required this.birthPlace,
    required this.horoscope,
    required this.familyDiety,
    required this.fatherName,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherOccupation,
    required this.numberOfBrothers,
    required this.numberOfSisters,
    required this.familyType,
    required this.homeTown,
    required this.reference,
    required this.referenceNumber,
    required this.url,
    required this.rashi,
    required this.nakshatra,
    required this.liked,
  });

  static Future<profileview> fromJson(Map<String, dynamic> json) async {
    // String baseUrl = (await _getBaseUrl()) ?? '';
    String baseUrl = (await _getBaseUrl()).toString();
    String _url=json['url'] ?? '';
    return profileview(
      id: (json['id'] ?? 0).toString(),
      matriId: (json['matri_id'] ?? '').toString(),
      maritalStatus: (json['marital_status'] ?? 0).toString(),
      status: (json['status'] ?? '').toString(),
      profileCreatorId: (json['profile_creator_id'] ?? 0).toString(),
      profileCreator: (json['profile_creator'] ?? '').toString(),
      profileForId: (json['profile_for_id'] ?? 0).toString(),
      profileFor: (json['profile_for'] ?? '').toString(),
      creatorPhone: (json['creator_phone'] ?? 0).toString(),
      creatorName: (json['creator_name'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      phone: (json['phone'] ?? 0).toString(),
      email: (json['email'] ?? '').toString(),
      dob: (json['dob'] ?? '').toString(),
      age: (json['age'] ?? 0).toString(),
      gender: (json['gender'] ?? 0).toString(),
      genderType: (json['gender_type'] ?? '').toString(),
      cityId: (json['city_id'] ?? '').toString(),
      countryId: (json['country_id'] ?? '').toString(),
      stateId: (json['state_id'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      kids: (json['kids'] ?? 0).toString(),
      address: (json['address'] ?? '').toString(),
      caste: (json['caste'] ?? '').toString(),
      planStatus: (json['plan_status'] ?? '').toString(),
      subCaste: (json['sub_caste'] ?? '').toString(),
      subCasteId: (json['sub_caste_id'] ?? 0).toString(),
      company: (json['company'] ?? '').toString(),
      companyCity: (json['company_city'] ?? '').toString(),
      specializationId: (json['specialization_id'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      qualification: (json['qualification'] ?? '').toString(),
      qualificationId: (json['qualification_id'] ?? '').toString(),
      occupationId: (json['occupation_id'] ?? '').toString(),
      occupation: (json['occupation'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      createdDate: (json['created_date'] ?? '').toString(),
      salary: (json['salary'] ?? '').toString(),
      height: (json['height'] ?? 0).toString(),
      weight: (json['weight'] ?? 0).toString(),
      bloodGroup: (json['blood_group'] ?? '').toString(),
      motherTongueId: (json['mother_tongue_id'] ?? '').toString(),
      motherTongue: (json['mother_tongue'] ?? '').toString(),
      complexion: (json['complexion'] ?? '').toString(),
      disability: (json['disability'] ?? '').toString(),
      rashiId: (json['rashi_id'] ?? '').toString(),
      nakshatraId: (json['nakshatra_id'] ?? '').toString(),
      gothra: (json['gothra'] ?? '').toString(),
      sunSign: (json['sun_sign'] ?? 0).toString(),
      birthTime: (json['birth_time'] ?? '').toString(),
      birthPlace: (json['birth_place'] ?? '').toString(),
      horoscope: (json['horoscope'] ?? '').toString(),
      familyDiety: (json['family_diety'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      fatherOccupation: (json['father_ocupation'] ?? '').toString(),
      motherName: (json['mother_name'] ?? '').toString(),
      motherOccupation: (json['mother_occupation'] ?? '').toString(),
      numberOfBrothers: (json['number_of_brothers'] ?? 0).toString(),
      numberOfSisters: (json['number_of_sisters'] ?? 0).toString(),
      familyType: (json['family_type'] ?? '').toString(),
      homeTown: (json['home_town'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
      referenceNumber: (json['reference_number'] ?? '').toString(),
      
      url: (baseUrl + "/" + _url ).toString(),
      rashi: (json['rashi'] ?? '').toString(),
      nakshatra: (json['nakshatra'] ?? '').toString(),
      liked: (json['liked'] ?? 0).toString(),
    );
  }
}

//Search prefernce
class SearchData {
  final List<searchprofile> dataout;

  SearchData({required this.dataout});

  static Future<SearchData> fromJsonAsync(Map<String, dynamic> json) async {
    String baseUrl =
        (await _getBaseUrl()) ?? ''; // Get base URL before parsing data

    List<searchprofile> profileList = (json['dataout'] as List)
        .map((user) => searchprofile.fromJson(user, baseUrl))
        .toList();

    return SearchData(dataout: profileList);
  }

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }
}

class searchprofile {
  final String id;
  final String matriId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final int age;
  final int gender;
  final String genderType;
  final String planStatus;
  final double height;
  final int weight;
  final String url;

  searchprofile({
    required this.id,
    required this.matriId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.planStatus,
    required this.height,
    required this.weight,
    required this.url,
  });

  // Updated factory constructor to take baseUrl as an argument
  factory searchprofile.fromJson(Map<String, dynamic> json, String baseUrl) {
    return searchprofile(
      id: json['id']?.toString() ?? "",
      matriId: json['matri_id'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      phone: json['phone']?.toString() ?? "",
      dob: json['dob'] ?? "",
      age: int.tryParse(json['age'].toString()) ?? 0,
      gender: int.tryParse(json['gender'].toString()) ?? 0,
      genderType: json['gender_type'] ?? "",
      planStatus: json['plan_status'] ?? "",
      height: double.tryParse(json['height'].toString()) ?? 0.0,
      weight: int.tryParse(json['weight'].toString()) ?? 0,
      url: baseUrl + "/" + (json['url']?.toString() ?? ""),
    );
  }
}

//Sub Caste

class SubCaste {
  final List<searchsubcaste> dataout;

  SubCaste({required this.dataout});

  factory SubCaste.fromJson(Map<String, dynamic> json) {
    return SubCaste(
      dataout: (json['dataout'] as List)
          .map((e) => searchsubcaste.fromJson(e))
          .toList(),
    );
  }
}

class searchsubcaste {
  final String id;
  final String caste_id;
  final String sub_caste;
  final String status;

  searchsubcaste({
    required this.id,
    required this.caste_id,
    required this.sub_caste,
    required this.status,
  });

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  factory searchsubcaste.fromJson(Map<String, dynamic> json) {
    return searchsubcaste(
      id: (json['id'] ?? 0).toString(),
      caste_id: (json['caste_id'] ?? '').toString(),
      sub_caste: json['sub_caste'] ?? '',
      status: (json['status'] ?? '').toString(),
    );
  }

  static List<searchsubcaste> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => searchsubcaste.fromJson(json)).toList();
  }
}

//Education
class Education {
  final List<searcheducation> dataout;

  Education({required this.dataout});

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      dataout: (json['dataout'] as List)
          .map((e) => searcheducation.fromJson(e))
          .toList(),
    );
  }
}

class searcheducation {
  final String id;
  final String name;
  final String status;

  searcheducation({
    required this.id,
    required this.name,
    required this.status,
  });

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  factory searcheducation.fromJson(Map<String, dynamic> json) {
    return searcheducation(
      id: (json['id'] ?? 0).toString(),
      name: (json['name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  static List<searcheducation> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => searcheducation.fromJson(json)).toList();
  }
}

//Country
class Country {
  final List<searchcountry> dataout;

  Country({required this.dataout});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      dataout: (json['dataout'] as List)
          .map((e) => searchcountry.fromJson(e))
          .toList(),
    );
  }
}

class searchcountry {
  final String country_id;
  final String country_name;
  final String country_code;

  searchcountry({
    required this.country_id,
    required this.country_name,
    required this.country_code,
  });

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  factory searchcountry.fromJson(Map<String, dynamic> json) {
    return searchcountry(
      country_id: (json['country_id'] ?? 0).toString(),
      country_name: (json['country_name'] ?? '').toString(),
      country_code: (json['country_code'] ?? '').toString(),
    );
  }

  static List<searchcountry> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => searchcountry.fromJson(json)).toList();
  }
}

//State
class State1 {
  final List<searchstate> dataout;

  State1({required this.dataout});

  factory State1.fromJson(Map<String, dynamic> json) {
    return State1(
      dataout:
          (json['data'] as List).map((e) => searchstate.fromJson(e)).toList(),
    );
  }
}

class searchstate {
  final String state_id;
  final String state_name;
  final String state_code;
  final String country_id;

  searchstate({
    required this.state_id,
    required this.state_name,
    required this.state_code,
    required this.country_id,
  });

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  factory searchstate.fromJson(Map<String, dynamic> json) {
    return searchstate(
      state_id: (json['state_id'] ?? 0).toString(),
      state_name: (json['state_name'] ?? '').toString(),
      state_code: (json['state_code'] ?? '').toString(),
      country_id: (json['country_id'] ?? '').toString(),
    );
  }

  static List<searchstate> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => searchstate.fromJson(json)).toList();
  }
}

//City
class City {
  final List<searchcity> dataout;

  City({required this.dataout});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      dataout:
          (json['data'] as List).map((e) => searchcity.fromJson(e)).toList(),
    );
  }
}

class searchcity {
  final String city_id;
  final String city_name;
  final String state_id;
  final String country_id;

  searchcity({
    required this.city_id,
    required this.city_name,
    required this.state_id,
    required this.country_id,
  });

  factory searchcity.fromJson(Map<String, dynamic> json) {
    return searchcity(
      city_id: (json['city_id'] ?? 0).toString(),
      city_name: (json['city_name'] ?? '').toString(),
      state_id: (json['state_id'] ?? '').toString(),
      country_id: (json['country_id'] ?? '').toString(),
    );
  }

  static List<searchcity> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => searchcity.fromJson(json)).toList();
  }
}

//Search thrgh ategory

class Category {
  final List<searchcategory> dataout;

  Category({required this.dataout});

  static Future<Category> fromJsonAsync(Map<String, dynamic> json) async {
    String baseUrl =
        (await _getBaseUrl()) ?? ''; // Get base URL before parsing data

    List<searchcategory> searchList = (json['data'] as List)
        .map((e) => searchcategory.fromJson(e, baseUrl))
        .toList();

    return Category(dataout: searchList);
  }

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }
}

class searchcategory {
  final String id;
  final String matriId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final int age;
  final int gender;
  final String genderType;
  final String planStatus;
  final double height;
  final int weight;
  final String url;

  searchcategory({
    required this.id,
    required this.matriId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.planStatus,
    required this.height,
    required this.weight,
    required this.url,
  });

  factory searchcategory.fromJson(Map<String, dynamic> json, String baseUrl) {
    return searchcategory(
      id: json['id']?.toString() ?? "",
      matriId: json['matri_id'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      phone: json['phone']?.toString() ?? "",
      dob: json['dob'] ?? "",
      age: int.tryParse(json['age'].toString()) ?? 0, // Convert age to int
      gender:
          int.tryParse(json['gender'].toString()) ?? 0, // Convert gender to int
      genderType: json['gender_type'] ?? "",
      planStatus: json['plan_status'] ?? "",
      height: double.tryParse(json['height'].toString()) ??
          0.0, // Convert height to double
      weight:
          int.tryParse(json['weight'].toString()) ?? 0, // Convert weight to int
      url: baseUrl + "/" + (json['url']?.toString() ?? ""),
    );
  }
}

//Pagination

class Category1 {
  final List<searchcategory1> dataout;
  final int totalRows;

  Category1({required this.dataout, required this.totalRows});

  static Future<Category1> fromJsonAsync(Map<String, dynamic> json) async {
    String baseUrl = (await _getBaseUrl()) ?? '';

  List<searchcategory1> searchList = (json['dataout'] as List)
        .map((e) => searchcategory1.fromJson(e, baseUrl))
        .toList();

        int totalRows=0;

     if (json.containsKey('row_counts') && json['row_counts'] is List) {
      var rowCountData = json['row_counts'].isNotEmpty ? json['row_counts'][0] : null;
      totalRows = rowCountData != null && rowCountData.containsKey('TOTAL_ROWS')
          ? int.tryParse(rowCountData['TOTAL_ROWS'].toString()) ?? 0
          : 0;
    }
    return Category1(dataout: searchList, totalRows: totalRows);
  }

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }
}


class searchcategory1 {
  final String id;
  final String matriId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final int age;
  final int gender;
  final String genderType;
  final String planStatus;
  final double height;
  final int weight;
  final String url;


  searchcategory1({
    required this.id,
    required this.matriId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.planStatus,
    required this.height,
    required this.weight,
    required this.url,
   
  });

  factory searchcategory1.fromJson(Map<String, dynamic> json, String baseUrl) {
    return searchcategory1(
      id: json['id']?.toString() ?? "",
      matriId: json['matri_id']?.toString() ?? "",
      firstName: json['first_name']?.toString() ?? "",
      lastName: json['last_name']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      dob: json['dob']?.toString() ?? "",
      age: int.tryParse(json['age']?.toString() ?? "0") ?? 0,
      gender: int.tryParse(json['gender']?.toString() ?? "0") ?? 0,
      genderType: json['gender_type']?.toString() ?? "",
      planStatus: json['plan_status']?.toString() ?? "",
      height: double.tryParse(json['height']?.toString() ?? "0.0") ?? 0.0,
      weight: int.tryParse(json['weight']?.toString() ?? "0") ?? 0,
      url: json['url'] != null ? "$baseUrl/${json['url']}" : "",
     
     
    );
  }

 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matriId': matriId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dob': dob,
      'age': age,
      'gender': gender,
      'genderType': genderType,
      'planStatus': planStatus,
      'height': height,
      'weight': weight,
      'url': url,
  
    };
  }

  
  @override
  String toString() {
    return jsonEncode(toMap()); 
  }
}


//Partner Preference 

class Partner {
  final List<searchpartner> dataout;

  Partner({required this.dataout});

  static Future<Partner> fromJsonAsync(Map<String, dynamic> json) async {
    String baseUrl =
        (await _getBaseUrl()) ?? ''; // Get base URL before parsing data

    List<searchpartner> searchList = (json['data'] as List)
        .map((e) => searchpartner.fromJson(e, baseUrl))
        .toList();

    return Partner(dataout: searchList);
  }

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }
}

class searchpartner {
  final String id;
  final String matriId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final int age;
  final int gender;
  final String genderType;
  final String planStatus;
  final double height;
  final int weight;
  final String url;

  searchpartner({
    required this.id,
    required this.matriId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.gender,
    required this.genderType,
    required this.planStatus,
    required this.height,
    required this.weight,
    required this.url,
  });

  factory searchpartner.fromJson(Map<String, dynamic> json, String baseUrl) {
    return searchpartner(
      id: json['id']?.toString() ?? "",
      matriId: json['matri_id'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      phone: json['phone']?.toString() ?? "",
      dob: json['dob'] ?? "",
      age: int.tryParse(json['age'].toString()) ?? 0, // Convert age to int
      gender:
          int.tryParse(json['gender'].toString()) ?? 0, // Convert gender to int
      genderType: json['gender_type'] ?? "",
      planStatus: json['plan_status'] ?? "",
      height: double.tryParse(json['height'].toString()) ??
          0.0, // Convert height to double
      weight:
          int.tryParse(json['weight'].toString()) ?? 0, // Convert weight to int
      url: baseUrl + "/" + (json['url']?.toString() ?? ""),
    );
  }
}

//Images
class Images {
  final List<searchimages> dataout;

  Images({required this.dataout});

  static Future<Images> fromJson(Map<String, dynamic> json) async {
    List<dynamic> jsonData = json['data'] ?? [];

    List<searchimages> images = await Future.wait(
        jsonData.map((e) async => await searchimages.fromJson(e)));

    return Images(dataout: images);
  }
}

class searchimages {
  final String sl_id;
  final String matri_id;
  final String photo_type;
  final String img_url;
  final String deleted;
  final String created_date;
  final String updated_date;

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  searchimages({
    required this.sl_id,
    required this.matri_id,
    required this.photo_type,
    required this.img_url,
    required this.deleted,
    required this.created_date,
    required this.updated_date,
  });

  static Future<searchimages> fromJson(Map<String, dynamic> json) async {
    // String baseUrl = (await _getBaseUrl()) ?? '';
    String baseUrl = (await _getBaseUrl()) ?? '';
    return searchimages(
      sl_id: (json['sl_id'] ?? 0).toString(),
      matri_id: (json['matri_id'] ?? '').toString(),
      photo_type: (json['photo_type'] ?? '').toString(),
      img_url: (baseUrl + "/" + (json['url'] ?? '')).toString(),
      deleted: (json['deleted'] ?? '').toString(),
      created_date: (json['created_date'] ?? '').toString(),
      updated_date: (json['updated_date'] ?? '').toString(),
    );
  }

  static Future<List<searchimages>> fromJsonList(List<dynamic> jsonList) async {
    return await Future.wait(
        jsonList.map((json) async => await searchimages.fromJson(json)));
  }
}

//Shortlist Nishvita
class ShortlistData {
  final List<ShortlistedProfile> profiles;

  ShortlistData({required this.profiles});
  factory ShortlistData.fromJson(Map<String, dynamic> json, String baseUrl) {
    // Ensure 'dataout' is a list before mapping
    if (json['dataout'] is! List) {
      return ShortlistData(
          profiles: []); // Return empty list if not a valid list
    }
    List<ShortlistedProfile> profileList = (json['dataout'] as List)
        .whereType<Map<String, dynamic>>() // Ensure all items are maps
        .map((profile) => ShortlistedProfile.fromJson(profile, baseUrl))
        .toList();

    return ShortlistData(profiles: profileList);
  }
}

class ShortlistedProfile {
  final String name;
  final String age;
  final String matriId;
  final String imageUrl;
  final String planStatus;
  final String gender;

  ShortlistedProfile({
    required this.name,
    required this.age,
    required this.matriId,
    required this.imageUrl,
    required this.planStatus,
    required this.gender,
  });

  factory ShortlistedProfile.fromJson(
      Map<String, dynamic> json, String baseUrl) {
    String url = json['url']?.toString().trim() ?? ''; // Ensure no null value
    return ShortlistedProfile(
      name: "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim(),
      age: json['age']?.toString() ?? "N/A",
      matriId: json['matri_id']?.toString() ?? "N/A",
      imageUrl: url.isNotEmpty ? "$baseUrl/$url" : "Not avilable",
      planStatus: json['plan_status']?.toString() ?? "N/A",
      gender: json['gender']?.toString() ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "matriId": matriId.isNotEmpty ? matriId : "not avi",
      "name": name.isNotEmpty ? name : "N/A",
      "age": age.isNotEmpty ? age : "N/A",
      "planStatus": planStatus.isNotEmpty ? planStatus : "N/A",
      "gender": gender.isNotEmpty ? gender : "N/A",
      "imageUrl": imageUrl.isNotEmpty ? imageUrl : "image not avilable",
    };
  }
}

//Block or repoitt

class Block {
  final List<blockdata> dataout;
  final String message;

  Block({required this.dataout, required this.message});

  static Future<Block> fromJson(Map<String, dynamic> json) async {
    List<blockdata> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => blockdata.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return Block(
      dataout: profileList,
      message: message,
    );
  }
}

class blockdata {
  final String status;

  blockdata({required this.status});

  static Future<blockdata> fromJson(Map<String, dynamic> json) async {
    return blockdata(
      status: json['status'] ?? '',
    );
  }
}

//Add Shortlist

class AddShortlist {
  final List<AddShortlistData> dataout;
  final String message;

  AddShortlist({required this.dataout, required this.message});

  static Future<AddShortlist> fromJson(Map<String, dynamic> json) async {
    List<AddShortlistData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => AddShortlistData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return AddShortlist(
      dataout: profileList,
      message: message,
    );
  }
}

class AddShortlistData {
  final String status;

  AddShortlistData({required this.status});

  static Future<AddShortlistData> fromJson(Map<String, dynamic> json) async {
    return AddShortlistData(
      status: json['status'] ?? '',
    );
  }
}

//Remove Shortlist

class RemoveShortlist {
  final List<RemoveShortlistData> dataout;
  final String message;

  RemoveShortlist({required this.dataout, required this.message});

  static Future<RemoveShortlist> fromJson(Map<String, dynamic> json) async {
    List<RemoveShortlistData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => RemoveShortlistData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return RemoveShortlist(
      dataout: profileList,
      message: message,
    );
  }
}

class RemoveShortlistData {
  final String status;

  RemoveShortlistData({required this.status});

  static Future<RemoveShortlistData> fromJson(Map<String, dynamic> json) async {
    return RemoveShortlistData(
      status: json['status'] ?? '',
    );
  }
}

//Add like

class Addlike {
  final List<AddlikeData> dataout;
  final String message;

  Addlike({required this.dataout, required this.message});

  static Future<Addlike> fromJson(Map<String, dynamic> json) async {
    List<AddlikeData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => AddlikeData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return Addlike(
      dataout: profileList,
      message: message,
    );
  }
}

class AddlikeData {
  final String status;

  AddlikeData({required this.status});

  static Future<AddlikeData> fromJson(Map<String, dynamic> json) async {
    return AddlikeData(
      status: json['status'] ?? '',
    );
  }
}

//Remove Like

class Removelike {
  final List<RemovelikeData> dataout;
  final String message;

  Removelike({required this.dataout, required this.message});

  static Future<Removelike> fromJson(Map<String, dynamic> json) async {
    List<RemovelikeData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => RemovelikeData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return Removelike(
      dataout: profileList,
      message: message,
    );
  }
}

class RemovelikeData {
  final String status;

  RemovelikeData({required this.status});

  static Future<RemovelikeData> fromJson(Map<String, dynamic> json) async {
    return RemovelikeData(
      status: json['status'] ?? '',
    );
  }
}

//Likes

class LikeData {
  final List<LikedProfile> profiles;

  LikeData({required this.profiles});

  factory LikeData.fromJson(Map<String, dynamic> json, String baseUrl) {
    List<LikedProfile> profileList = (json['dataout'] as List)
        .map((profile) => LikedProfile.fromJson(profile, baseUrl))
        .toList();
    return LikeData(profiles: profileList);
  }
}

class LikedProfile {
  final String name;
  final String age;
  final String id;
  final String imageUrl;

  LikedProfile({
    required this.name,
    required this.age,
    required this.id,
    required this.imageUrl,
  });

  factory LikedProfile.fromJson(Map<String, dynamic> json, String baseUrl) {
    _saveBaseUrl(baseUrl);

    return LikedProfile(
      name: "${json['first_name']} ${json['last_name']}",
      age: json['age']?.toString() ?? "N/A",
      id: json['matri_id']?.toString() ?? "N/A",
      imageUrl: baseUrl + json['url'].toString(),
    );
  }

  static Future<void> _saveBaseUrl(String baseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', baseUrl);
  }
}
//Tickets

class AddTicket {
  final List<AddTicketData> dataout;
  final String message;

  AddTicket({required this.dataout, required this.message});

  static Future<AddTicket> fromJson(Map<String, dynamic> json) async {
    List<AddTicketData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => AddTicketData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return AddTicket(
      dataout: profileList,
      message: message,
    );
  }
}

class AddTicketData {
  final String status;

  AddTicketData({required this.status});

  static Future<AddTicketData> fromJson(Map<String, dynamic> json) async {
    return AddTicketData(
      status: json['status'] ?? '',
    );
  }
}
//Support Number
class SupportNumber {
  final List<supportnumberdata> dataout;

  SupportNumber({required this.dataout});

  factory SupportNumber.fromJson(Map<String, dynamic> json) {
    return SupportNumber(
      dataout: (json['dataout'] as List)
          .map((e) => supportnumberdata.fromJson(e))
          .toList(),
    );
  }
}

class supportnumberdata {
  final String name;
  final String phone;

  supportnumberdata({
    required this.name,
    required this.phone,
  });

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  factory supportnumberdata.fromJson(Map<String, dynamic> json) {
    return supportnumberdata(
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  static List<supportnumberdata> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => supportnumberdata.fromJson(json)).toList();
  }
}
//Cashfree

class Razor {
  final List<PaymentData> profiles;

  Razor({required this.profiles});

  factory Razor.fromJson(Map<String, dynamic> json, String baseUrl) {
    List<PaymentData> profileList = (json['dataout'] as List)
        .map((profile) => PaymentData.fromJson(profile))
        .toList();
    return Razor(profiles: profileList);
  }
}
class PaymentData {
  final String paymentSessionId;
  final String orderId;

  PaymentData({required this.paymentSessionId, required this.orderId});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("dataout") && json["dataout"] != null) {
      return PaymentData(
        paymentSessionId: json["dataout"]["payment_session_id"] ?? "",
        orderId: json["dataout"]["order_id"] ?? "",
      );
    } else {
      throw Exception("Missing 'dataout' in response");
    }
  }

}

//Cashfree Captured 

class Captured {
  final List<CapturedData> dataout;
  final String message;

  Captured({required this.dataout, required this.message});

  static Future<Captured> fromJson(Map<String, dynamic> json) async {
    List<CapturedData> profileList = [];

    if (json['dataout'] != null) {
      profileList = await Future.wait(
        (json['dataout'] as List)
            .map((user) => CapturedData.fromJson(user))
            .toList(),
      );
    }

    String message = json['message']['p_out_mssg'] ?? '';

    return Captured(
      dataout: profileList,
      message: message,
    );
  }
}

class CapturedData {
  final String status;

  CapturedData({required this.status});

  static Future<CapturedData> fromJson(Map<String, dynamic> json) async {
    return CapturedData(
      status: json['status'] ?? '',
    );
  }
}



//Subscription plan
class SubscriptionData {
  final String id;
  final String planName;
  final String amount;

  SubscriptionData({required this.id, required this.planName, required this.amount});

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json["id"]?.toString() ?? "",
      planName: json["plan_name"] ?? "Unknown Plan",
      amount: json["amount"]?.toString() ?? "0",
    );
  }
}



