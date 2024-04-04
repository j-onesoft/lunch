class Restaurant {
  final int id;
  final String name;
  final int vote;
  final DateTime lastDrawDate;
  final int price;

  Restaurant(
      {required this.id,
      required this.name,
      required this.vote,
      required this.lastDrawDate,
      required this.price});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      vote: json['vote'],
      lastDrawDate: DateTime.parse(json['last_draw_date']),
      price: json['price'],
    );
  }
}