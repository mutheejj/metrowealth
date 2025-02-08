class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final double budget;
  final double spent;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.budget,
    this.spent = 0.0,
  });
} 