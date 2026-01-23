class UserModel {
  String? id;
  String? name;
  String? email;
  String? role;
  String? workerType;
  String? phoneNumber;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.workerType,
    this.phoneNumber,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    workerType =
        json['worker_type'] ?? json['workerType']; // Support both cases
    phoneNumber = json['phone'] ?? json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['worker_type'] = workerType;
    data['phone'] = phoneNumber;
    return data;
  }
}
