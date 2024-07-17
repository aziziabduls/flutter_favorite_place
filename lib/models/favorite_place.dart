class FavoritePlaceItem {
  String? name;
  String? image;
  String? location;
  double? lat;
  double? lng;

  FavoritePlaceItem({
    required this.name,
    required this.image,
    required this.location,
    required this.lat,
    required this.lng,
  });

  FavoritePlaceItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    location = json['location'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['location'] = location;
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}
