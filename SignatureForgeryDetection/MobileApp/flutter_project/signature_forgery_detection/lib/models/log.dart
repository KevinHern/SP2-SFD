enum LogStatus{SHOW, PENDING, APPROVED, DENIED}
enum LogType{INFO, REPORT, CHECK}

class Log {
  int logId, logType;
  String overview, description, who, victim, victimid, reason, _date;
  int status, action;
  bool _hide;
  /*
    ACTION:
    0 == CREATION
    1 == EDIT
    2 == VERIFICATION
    3 == DELETION
    4 == DELETION
   */

  /*
    STATUS:
    0 == SHOW
    1 == PENDING
    2 == APPROVED
    3 == DENIED
   */

  Log(int logId, int logType, String description, String who, String victim, String victimid, int action, String reason, int status) {
    this.logId = logId;
    this.logType = logType;
    this.description = description;
    this.who = who;
    this.victim = victim;
    this.victimid = victimid;
    this.action = action;
    this.reason = reason;
    this.status = status;
  }

  Object getFieldByInt(int index) {
    switch(index) {
      case 0:
        return this.logId;
        break;
      case 1:
        return this.logType;
        break;
      case 2:
        return this.overview;
        break;
      case 3:
        return this.description;
        break;
      case 4:
        return this.status;
        break;
      default:
        return null;
    }
  }

  Object getFieldByString(String param) {
    switch(param) {
      case "id":
        return this.logId;
        break;
      case "type":
        return this.logType;
        break;
      case "overview":
        return this.overview;
        break;
      case "description":
        return this.description;
        break;
      case "who":
        return this.who;
        break;
      case "victim":
        return this.victim;
        break;
      case "victimid":
        return this.victimid;
        break;
      case "reason":
        return this.reason;
        break;
      case "action":
        return this.action;
        break;
      case "status":
        return this.status;
        break;
      default:
        return null;
    }
  }

  /*
  int getLogTypeAsInt(){
    switch(this.logType){
      case LogType.INFO: return 0;
      case LogType.REPORT: return 1;
      case LogType.CHECK: return 2;
      default: return -1;
    }
  }

   */

  void updateFieldByString(String param, Object value) {
    switch(param) {
      case "id":
        this.logId = value as int;
        break;
      case "type":
        this.logType = value as int;
        break;
      case "overview":
        this.overview = value as String;
        break;
      case "description":
        this.description = value as String;
        break;
      case "status":
        this.status = value as int;
        break;
      default:
        return null;
    }
  }

  void setHide(bool hide){
    this._hide = hide;
  }

  bool getHide(){
    return this._hide;
  }

  void setDate(String date){
    this._date = date;
  }

  String getDate(){
    return this._date;
  }

}