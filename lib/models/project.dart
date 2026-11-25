import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.year,
    this.projectUrl = '',
    this.projectImageUrl = '',
    this.categoryDisplay = '',
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String category;
  final int year;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  @JsonKey(defaultValue: '', includeToJson: false)
  final String categoryDisplay;

  @JsonKey(defaultValue: 0, includeToJson: false)
  final int starCount;

  @JsonKey(defaultValue: false, includeToJson: false)
  final bool isStarred;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
