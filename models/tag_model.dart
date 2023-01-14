class TagModel {
  final double id;
  final double tag_number;
  final Map range;

  TagModel({required this.id, required this.tag_number,
    required this.range }); //, required this.range_from, required this.range_to});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['tagId'],
      tag_number: json['tagNumber'],
      range: json['range'],
    );
  }
}
