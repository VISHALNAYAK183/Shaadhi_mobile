class MotherTongue {
  final List<MotherTongueItem> dataout;

  MotherTongue({required this.dataout});

  factory MotherTongue.fromJson(Map<String, dynamic> json) {
    return MotherTongue(
      dataout: (json['dataout'] as List)
          .map((item) => MotherTongueItem.fromJson(item))
          .toList(),
    );
  }
}

class MotherTongueItem {
  final String id;
  final String language;
  final String status;

  MotherTongueItem(
      {required this.id, required this.language, required this.status});

  factory MotherTongueItem.fromJson(Map<String, dynamic> json) {
    return MotherTongueItem(
      id: (json['id'] ?? 0).toString(),
      language: json['language'] ?? '',
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Educations {
  final List<EducationItems> dataout;

  Educations({required this.dataout});

  factory Educations.fromJson(Map<String, dynamic> json) {
    return Educations(
      dataout: (json['dataout'] as List)
          .map((item) => EducationItems.fromJson(item))
          .toList(),
    );
  }
}

class EducationItems {
  final String id;
  final String name;
  final String status;

  EducationItems({required this.id, required this.name, required this.status});

  factory EducationItems.fromJson(Map<String, dynamic> json) {
    return EducationItems(
      id: (json['id'] ?? 0).toString(),
      name: json['name'] ?? '',
      status: (json['status'] ?? '').toString(),
    );
  }
}



class Occupations {
  final List<OccupationItems> dataout;

  Occupations({required this.dataout});

  factory Occupations.fromJson(Map<String, dynamic> json) {
    return Occupations(
      dataout: (json['dataout'] as List)
          .map((item) => OccupationItems.fromJson(item))
          .toList(),
    );
  }
}

class OccupationItems {
  final String id;
  final String name;
  final String status;

  OccupationItems({required this.id, required this.name, required this.status});

  factory OccupationItems.fromJson(Map<String, dynamic> json) {
    return OccupationItems(
      id: (json['id'] ?? 0).toString(),
      name: json['name'] ?? '',
      status: (json['status'] ?? '').toString(),
    );
  }
}



