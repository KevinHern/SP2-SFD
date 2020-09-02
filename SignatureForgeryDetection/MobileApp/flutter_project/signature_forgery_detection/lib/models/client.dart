class Client{
  var user;
  String _uid;
  var _information = [];
  //_name, _lastName, _email, _phoneNumber;

  Client(String name, String lastName, String email, String phoneNumber,
      String registrationDate, String birthday){
    this._information = [email, name, lastName, phoneNumber, birthday, registrationDate];
  }

  String getUID(){
    return this._uid;
  }

  void setUID(String uid){
    this._uid = uid;
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
      case "registration":
        index = 5;
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
  int getTotalRealParameters() { return 4;} // Email, Name + LastName, phone, birthday

  void updateByString(String parameter, var value){
    int index = mapParamStringToInt(parameter);
    (index == -1)? null : this._information[index] = value;
  }
}