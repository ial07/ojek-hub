class UserModel {
  String? id;
  String? name;
  String? email;
  String? role;
  String? workerType;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.workerType,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    workerType = json['worker_type'] ?? json['workerType']; // Support both cases
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['worker_type'] = workerType;
    return data;
  }
}
