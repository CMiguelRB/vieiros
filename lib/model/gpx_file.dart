class GpxFile {
  String name;
  String? path;

  GpxFile({required this.name, required this.path});

  factory GpxFile.fromJson(Map<String, dynamic> json) {
    return GpxFile(
    name: json['name'],
    path: json['path']
    );
  }

  Map toJson() => {
    'name': name,
    'path': path
  };
}