class Employee{
  var user;
  String _uid;
  bool _hasPowers;
  List<String> _information = new List();
  //_name, _lastName, _email, _phoneNumber, _department, _position, _Schedule;
  DateTime _birthday;

  Employee(String name, String lastName, String email, String phoneNumber,
      String department, String position, String initSchedule, String endSchedule){
    this._information = [email, name, lastName, phoneNumber, department, position, initSchedule, endSchedule];
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
      case "dept":
        index = 4;
        break;
      case "position":
        index = 5;
        break;
      case "init":
        index = 6;
        break;
      case "end":
        index = 7;
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
  int getTotalRealParameters() { return 4;} // Email, Password, Name + LastName + phone

  void updateByString(String parameter, var value){
    int index = mapParamStringToInt(parameter);
    (index == -1)? null : this._information[index] = value;
  }
}