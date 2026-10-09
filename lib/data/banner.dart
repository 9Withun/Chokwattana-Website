class BannerItem {
  const BannerItem({
    required this.id,
    required this.name,
    required this.align,
    required this.type,
    required this.imageUrl,
    required this.dateStart,
    required this.dateEnd,
  });

  final int id;
  final String name;
  final String align;
  final String type;
  final String imageUrl;
  final String dateStart;
  final String? dateEnd;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: _intValue(json['id']),
      name: _stringValue(json['banner_name']),
      align: _stringValue(json['align']),
      type: _stringValue(json['type']),
      imageUrl: _stringValue(json['image_url']),
      dateStart: _stringValue(json['date_start']),
      dateEnd: json['date_end'] == null || json['date_end'] == ''
          ? null
          : _stringValue(json['date_end']),
    );
  }
}

String _stringValue(dynamic value) => value?.toString() ?? '';

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
