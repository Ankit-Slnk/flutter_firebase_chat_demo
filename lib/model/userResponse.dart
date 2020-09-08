class UserResponse {
  Userdata userdata;
  String status;
  String message;

  UserResponse({this.userdata, this.status, this.message});

  UserResponse.fromJson(Map<String, dynamic> json) {
    userdata = json['userdata'] != null
        ? new Userdata.fromJson(json['userdata'])
        : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userdata != null) {
      data['userdata'] = this.userdata.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Userdata {
  int id;
  String name;
  String email;
  String emailVerifiedAt;
  String createdAt;
  String updatedAt;
  String userType;
  String companyName;
  String address;
  String registrationDate;
  String jobPreferenceRadius;
  String addressFile;
  String addressApproved;
  String passportFile;
  String passportNumber;
  String passportExpiryDate;
  String passportApproved;
  String insuranceFile;
  String insuranceNumber;
  String insuranceExpiryDate;
  String insuranceApproved;
  String isActive;

  Userdata({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.userType,
    this.companyName,
    this.address,
    this.registrationDate,
    this.jobPreferenceRadius,
    this.addressFile,
    this.addressApproved,
    this.passportFile,
    this.passportNumber,
    this.passportExpiryDate,
    this.passportApproved,
    this.insuranceFile,
    this.insuranceNumber,
    this.insuranceExpiryDate,
    this.insuranceApproved,
    this.isActive,
  });

  Userdata.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    email = json['email'] ?? "";
    emailVerifiedAt = json['email_verified_at'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    userType = json['user_type'] ?? "";
    companyName = json['company_name'] ?? "";
    address = json['address'] ?? "";
    registrationDate = json['registration_date'] ?? "";
    jobPreferenceRadius = json['job_preference_radius'] ?? "";
    addressFile = json['address_file'] ?? "";
    addressApproved = json['address_approved'] ?? "";
    passportFile = json['passport_file'] ?? "";
    passportNumber = json['passport_number'] ?? "";
    passportExpiryDate = json['passport_expiry_date'] ?? "";
    passportApproved = json['passport_approved'] ?? "";
    insuranceFile = json['insurance_file'] ?? "";
    insuranceNumber = json['insurance_number'] ?? "";
    insuranceExpiryDate = json['insurance_expiry_date'] ?? "";
    insuranceApproved = json['insurance_approved'] ?? "";
    isActive = json['is_active'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_type'] = this.userType;
    data['company_name'] = this.companyName;
    data['address'] = this.address;
    data['registration_date'] = this.registrationDate;
    data['job_preference_radius'] = this.jobPreferenceRadius;
    data['address_file'] = this.addressFile;
    data['address_approved'] = this.addressApproved;
    data['passport_file'] = this.passportFile;
    data['passport_number'] = this.passportNumber;
    data['passport_expiry_date'] = this.passportExpiryDate;
    data['passport_approved'] = this.passportApproved;
    data['insurance_file'] = this.insuranceFile;
    data['insurance_number'] = this.insuranceNumber;
    data['insurance_expiry_date'] = this.insuranceExpiryDate;
    data['insurance_approved'] = this.insuranceApproved;
    return data;
  }
}
