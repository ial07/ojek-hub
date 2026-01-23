class QueueModel {
  String? id;
  String? orderId;
  String? userId;
  int? position;
  DateTime? joinedAt;

  QueueModel({
    this.id,
    this.orderId,
    this.userId,
    this.position,
    this.joinedAt,
  });

  QueueModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'] ?? json['orderId'];
    userId = json['worker_id'] ?? json['userId'];
    position = json['position'];
    if (json['joined_at'] != null) {
      joinedAt = DateTime.tryParse(json['joined_at']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['worker_id'] = userId;
    data['position'] = position;
    data['joined_at'] = joinedAt?.toIso8601String();
    return data;
  }
}
