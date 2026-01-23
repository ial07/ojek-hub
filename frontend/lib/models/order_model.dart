class OrderModel {
  String? id;
  String? title;
  String? description;
  int? totalWorkers;
  int? currentQueue;
  String? status;
  // Extra fields that are likely needed but I'll make them optional to strictly match prompt rules primarily
  String? location;
  String? workerType;
  DateTime? jobDate;
  DateTime? createdAt;
  double? latitude;
  double? longitude;
  String? mapUrl;
  String? employerPhone;
  String? employerName; // Might be useful too

  OrderModel({
    this.id,
    this.title,
    this.description,
    this.totalWorkers,
    this.currentQueue,
    this.status,
    this.location,
    this.workerType,
    this.jobDate,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.mapUrl,
    this.employerPhone,
    this.employerName,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Backend doesn't have title, so we use description preview or explicit title if added later
    // For now, let's fallback to description or worker_type if title is missing
    title = json['title'] ??
        (json['worker_type'] != null
            ? "Lowongan ${json['worker_type']}"
            : "Lowongan Pekerjaan");
    description = json['description'];
    totalWorkers = json['worker_count'] ?? json['totalWorkers'];
    // Handle count structure (e.g. from Supabase count query or explicit field)
    currentQueue = json['current_queue'] ?? json['currentQueue'] ?? 0;
    status = json['status'];

    location = json['location'];
    workerType = json['worker_type'];
    if (json['job_date'] != null) {
      jobDate = DateTime.tryParse(json['job_date']);
    }
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at']);
    }
    // Parse location fields
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    mapUrl = json['map_url'];

    if (json['employer'] != null) {
      employerPhone = json['employer']['phone'];
      employerName = json['employer']['name'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['worker_count'] = totalWorkers;
    data['current_queue'] = currentQueue;
    data['status'] = status;
    data['location'] = location;
    data['worker_type'] = workerType;
    data['job_date'] = jobDate?.toIso8601String();
    data['created_at'] = createdAt?.toIso8601String();
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['map_url'] = mapUrl;
    // We generally don't send employer info back to server this way, but for completeness or caching:
    // data['employer_phone'] = employerPhone;
    return data;
  }
}
