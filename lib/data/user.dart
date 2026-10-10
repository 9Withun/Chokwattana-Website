class UserItem {
  const UserItem({
    required this.id,
    required this.memberId,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.paymentMethod,
  });

  final int id;
  final String memberId;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? paymentMethod;

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: _intValue(json['id']),
      memberId: _stringValue(json['member_id']),
      username: _stringValue(json['username']),
      email: _nullableString(json['email']),
      phoneNumber: _nullableString(json['phonenumber']),
      address: _nullableString(json['address']),
      paymentMethod: _nullableString(json['payment_method']),
    );
  }
}

String _stringValue(dynamic value) => value?.toString() ?? '';

String? _nullableString(dynamic value) {
  if (value == null || value == '') return null;
  return value.toString();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
