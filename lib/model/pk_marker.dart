class PKMarker {
  String pk;
  String marker;

  PKMarker({required this.pk, required this.marker});

  factory PKMarker.fromJson(Map<String, dynamic> json) {
    return PKMarker(pk: json['pk'], marker: json['marker']);
  }

  Map toJson() => {'pk': pk, 'marker': marker};
}
