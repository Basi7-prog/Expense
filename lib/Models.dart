final String tableModels = "Items";

class ModelFields {
  static final List<String> values = [id, item, price];
  static final String id = '_id';
  static final String item = 'item';
  static final String price = 'price';
}

class Models {
  final int? id;
  final String item;
  final double price;

  const Models({
    this.id,
    required this.item,
    required this.price,
  });

  Models copy({int? id, String? item, double? price}) => Models(
      id: id ?? this.id, item: item ?? this.item, price: price ?? this.price);

  static Models fromJson(Map<String, Object?> json) => Models(
      id: json[ModelFields.id] as int?,
      item: json[ModelFields.item] as String,
      price: json[ModelFields.price] as double);
      
  Map<String, Object?> toJson() => {
        ModelFields.id: id,
        ModelFields.item: item,
        ModelFields.price: price,
      };
}
