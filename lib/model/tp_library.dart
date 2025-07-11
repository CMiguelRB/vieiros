class TPLibrary {
  bool expanded;
  String title;
  String license;

  TPLibrary({required this.expanded, required this.title, required this.license});

  factory TPLibrary.fromJson(Map<String, dynamic> json) {
    return TPLibrary(expanded: json['expanded'], title: json['title'], license: json['license']);
  }

  void setExpanded(bool value) {
    expanded = value;
  }

  Map toJson() => {'expanded': expanded, 'title': title, 'license': license};
}
