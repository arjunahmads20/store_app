class Province {
  final int id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(id: json['id'] as int, name: json['name'] as String);
  }
}

class RegencyMunicipality {
  final int id;
  final String name;

  RegencyMunicipality({required this.id, required this.name});

  factory RegencyMunicipality.fromJson(Map<String, dynamic> json) {
    return RegencyMunicipality(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'] as int, name: json['name'] as String);
  }
}

class Village {
  final int id;
  final String name;
  final String postCode;

  Village({required this.id, required this.name, required this.postCode});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as int,
      name: json['name'] as String,
      postCode: json['post_code'] as String? ?? '',
    );
  }
}

class Street {
  final int id;
  final String name;

  Street({required this.id, required this.name});

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(id: json['id'] as int, name: json['name'] as String);
  }
}
