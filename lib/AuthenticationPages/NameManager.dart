class NameManager {
  static String? name;

  static void setname(String newname) {

    name = newname;
    print(name);
  }

  static String getname() {

    return name ?? '';
  }
}