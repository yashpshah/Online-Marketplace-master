class CategoryProvider{
  CategoryProvider._();
  static final CategoryProvider cp = CategoryProvider._();
  List<String> category;

  void setCategory(catList){
    category = new List<String>.from(catList);
  }
}