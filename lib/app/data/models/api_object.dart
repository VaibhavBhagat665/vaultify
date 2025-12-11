class ApiObject {
  final String? id;
  final String name;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiObject({
    this.id,
    required this.name,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiObject.fromJson(Map<String, dynamic> json) {
    return ApiObject(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (data != null) 'data': data,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (data != null && data!.isNotEmpty) 'data': data,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      if (data != null) 'data': data,
    };
  }

  ApiObject copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiObject(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ApiObject && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
