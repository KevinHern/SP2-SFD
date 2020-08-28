enum LogStatus{APPROVED, PENDING, SHOW, DENIED}
enum LogType{INFO, REPORT, CHECK}

class Log {
  LogType logType;
  String overview, description, logId;
  LogStatus status;

  Log(String logId, LogType logType, String overview, String description, LogStatus status) {
    this.logId = logId;
    this.logType = logType;
    this.overview = overview;
    this.description = description;
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
      case "status":
        return this.status;
        break;
      default:
        return null;
    }
  }

  int getLogTypeAsInt(){
    switch(this.logType){
      case LogType.INFO: return 0;
      case LogType.REPORT: return 1;
      case LogType.CHECK: return 2;
      default: return -1;
    }
  }

  void updateFieldByString(String param, Object value) {
    switch(param) {
      case "id":
        this.logId = value as String;
        break;
      case "type":
        this.logType = value as LogType;
        break;
      case "overview":
        this.overview = value as String;
        break;
      case "description":
        this.description = value as String;
        break;
      case "status":
        this.status = value as LogStatus;
        break;
      default:
        return null;
    }
  }
}