class AIResponse{
  int code;
  bool _conv_model, _ss_model, _siamese_model, _siamese_success;
  String _conv_pred, _conv_pred_signer, _siamese_pred, _ss_pred_signer, _ss_pred_signature;
  String _last_date, signer;
  String _conv_probability, _ss_probability, _siamese_probability;
  var signers = [];
  AIResponse(){
    this._conv_model = false;
    this._ss_model = false;
    this._siamese_model = false;
  }

  void setModelProbability(String option, String value){
    switch(option){
      case "conv":
        this._conv_probability = value;
        break;
      case "ss":
        this._ss_probability = value;
        break;
      case "siamese":
        this._siamese_probability = value;
        break;
      default:
        break;
    }
  }

  String getModelProbability(String option){
    switch(option){
      case "conv":
        return this._conv_probability;
      case "ss":
        return this._ss_probability;
      case "siamese":
        return this._siamese_probability;
      default:
        return "";
        break;
    }
  }

  void setModelFlag(String option, bool value){
    switch(option){
      case "conv":
        this._conv_model = value;
        break;
      case "ss":
        this._ss_model = value;
        break;
      case "siamese":
        this._siamese_model = value;
        break;
      default:
        break;
    }
  }

  bool getModelFlag(String option){
    switch(option){
      case "conv":
        return this._conv_model;
      case "ss":
        return this._ss_model;
      case "siamese":
        return this._siamese_model;
      default:
        break;
    }
  }

  void setModelInfo(int model, String last_date, var options) {
    this._last_date = last_date;
    switch(model){
      case 1:
        this.signers = options;
        break;
      case 21:
        this.signers = options;
        break;
      case 22:
        break;
      case 3:
        this.signers = options;
        break;
      default:
        break;
    }
  }

  String getModelLastDate(){
    return this._last_date;
  }

  String getModelSigner(){
    return this.signer;
  }

  String getModelSigners(){
    String str = "";
    for(int i = 0; i < this.signers.length; i++) str += this.signers[i] + ", ";

    return (str.isEmpty)? "" : str.substring(0, str.length - 2);
  }

  void setConvPred(String prediction, String predictionSiner){
    this._conv_pred = prediction;
    this._conv_pred_signer = predictionSiner;
  }

  void setSiamesePred(String prediction){
    this._siamese_pred = prediction;
  }

  void setSSPred(String predictionSignature, String predictionSigner){
    this._ss_pred_signer = predictionSigner;
    this._ss_pred_signature = predictionSignature;
  }

  List<String> getConvPred(){
    return (this._conv_model)? [this._conv_pred, this._conv_pred_signer] : "No predictions found for the Convolutional Model";
  }

  String getSiamesePred(){
    return (this._siamese_model)? this._siamese_pred : "No predictions found for the Siamese Model";
  }

  List<String> getSSPred(){
    return (this._ss_model)? [this._ss_pred_signer, this._ss_pred_signature] : "No predictions found for the Signer-Signature Model";
  }

  void setSiameseSuccess(bool success){ this._siamese_success = success; }
  bool getSiameseSuccess(){ return this._siamese_success; }
}