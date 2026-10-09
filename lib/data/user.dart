class User {
  final int id;
  final String? memberId;
  final String username;
  final String? email;
  final String? phonenumber;
  final String? address;
  final String? paymentMethod;

  User({
    required this.id,
    this.memberId,
    required this.username,
    this.email,
    this.phonenumber,
    this.address,
    this.paymentMethod,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      memberId: json['member_id']?.toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      phonenumber: json['phonenumber']?.toString(),
      address: json['address']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'username': username,
      'email': email,
      'phonenumber': phonenumber,
      'address': address,
      'payment_method': paymentMethod,
    };
  }
}
