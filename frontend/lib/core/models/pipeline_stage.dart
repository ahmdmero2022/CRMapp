class PipelineStage {
  PipelineStage({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.color,
  });

  final String id;
  final String name;
  final int orderIndex;
  final String color;

  factory PipelineStage.fromJson(Map<String, dynamic> json) => PipelineStage(
        id: json['id'] as String,
        name: json['name'] as String,
        orderIndex: (json['orderIndex'] as num).toInt(),
        color: json['color'] as String,
      );
}
