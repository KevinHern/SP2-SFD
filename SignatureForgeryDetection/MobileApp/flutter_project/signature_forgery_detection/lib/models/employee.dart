class Employee{
  var _user;
  String _uid;
  bool _hasPowers;
  List<String> _information = new List();
  String profileUrl;
  //_name, _lastName, _email, _phoneNumber, _department, _position, _Schedule;

  Employee(String name, String lastName, String email, String phoneNumber, String birthday,
      String department, String position, String initSchedule, String endSchedule){
    this._information = [email, name, lastName, phoneNumber, birthday, department, position, initSchedule, endSchedule];
  }

  void setUser(var user){
    this._user = user;
  }

  void setProfilePicURL(String url){
    this.profileUrl = url;
  }

  String getProfilePicURL(){ return this.profileUrl; }

  Object getUser(){
    return this._user;
  }

  void setUID(String uid){
    this._uid = uid;
  }

  String getUID(){
    return this._uid;
  }

  int mapParamStringToInt(String parameter) {
    int index = -1;
    switch(parameter){
      case "email":
        index = 0;
        break;
      case "name":
        index = 1;
        break;
      case "lname":
        index = 2;
        break;
      case "phone":
        index = 3;
        break;
      case "birthday":
        index = 4;
        break;
      case "dept":
        index = 5;
        break;
      case "position":
        index = 6;
        break;
      case "init":
        index = 7;
        break;
      case "end":
        index = 8;
        break;
      default:
        index = -1;
    }
    return index;
  }

  String getParameterByString(String parameter){
    int index = mapParamStringToInt(parameter);
    return (index == -1)? null : this._information[index];
  }

  String getParameterByInt(int option) { return this._information[option]; }

  List getInformation() { return this._information; }
  int getTotalRealParameters() { return 5;} // Email, Password, Name + LastName,  phone, birthday

  void updateByString(String parameter, var value){
    int index = mapParamStringToInt(parameter);
    (index == -1)? null : this._information[index] = value;
  }

  void setPowers(bool hasIt){
    this._hasPowers = hasIt;
  }

  bool getPowers(){
    return this._hasPowers;
  }
}