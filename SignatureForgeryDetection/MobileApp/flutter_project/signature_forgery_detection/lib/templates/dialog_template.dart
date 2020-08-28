import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DialogTemplate {
  static ProgressDialog progress;

  static void showFormMessage(BuildContext context, String message){
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("Aviso"),
            content: new Text(message),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("Ok"),
              ),
            ],
          );
        }
    );
  }

  static void showMessage(BuildContext context, String message){
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("Aviso"),
            content: new Text(message),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: new Text("Ok"),
              ),
            ],
          );
        }
    );
  }

  static void showStatusUpdate(BuildContext context, int code) {
    String message = "";
    if(code == 1) {
      // If update was successful
      message = "El dato se actualizó correctamente.";
    }
    else if(code == 2) {
      // If during update a crash occurred
      message = "Ocurrió un error al actualizar el dato.\nInténtelo de nuevo";
    }
    else if(code == 3) {
      // If the user lost authentication
      message = "Ocurrió un error fatal.\nAl parecer se perdieron sus credenciales.\n\nPor favor, salga de la app, ingrese otra vez y vuelva a intentarlo.";
    }
    showMessage(context, message);
  }

  static void showStatusRegister(BuildContext context, int code) {
    String message = "";
    if(code == 1) {
      // If update was successful
      message = "Registro exitoso.";
    }
    else if(code == 2) {
      // If during update a crash occurred
      message = "Ocurrió un error en el registro.\nInténtelo de nuevo";
    }
    else if(code == 3) {
      // If the user lost authentication
      message = "Ocurrió un error fatal.\nAl parecer se perdieron sus credenciales.\n\nPor favor, salga de la app, ingrese otra vez y vuelva a intentarlo.";
    }
    showMessage(context, message);
  }

  static void showStatusDelete(BuildContext context, int code) {
    String message = "";
    if(code == 1) {
      // If update was successful
      message = "Eliminación exitosa.";
    }
    else if(code == 2) {
      // If during update a crash occurred
      message = "Ocurrió un error en la eliminación del registro.\nInténtelo de nuevo";
    }
    else if(code == 3) {
      // If the user lost authentication
      message = "Ocurrió un error fatal.\nAl parecer se perdieron sus credenciales.\n\nPor favor, salga de la app, ingrese otra vez y vuelva a intentarlo.";
    }
    showMessage(context, message);
  }

  static void showStatusDeactivation(BuildContext context, int code) {
    String message = "";
    if(code == 1) {
      // If update was successful
      message = "Desasignación exitosa.";
    }
    else if(code == 2) {
      // If during update a crash occurred
      message = "Ocurrió un error en la desasignación de la rutina del paciente.\nInténtelo de nuevo";
    }
    else if(code == 3) {
      // If the user lost authentication
      message = "Ocurrió un error fatal.\nAl parecer se perdieron sus credenciales.\n\nPor favor, salga de la app, ingrese otra vez y vuelva a intentarlo.";
    }
    showMessage(context, message);
  }

  /*
  static void deleteConfirmation(BuildContext context, String type, Therapist therapist, Patient patient, Exercise exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Advertencia"),
          content: new Text("¿Desea eliminar de forma permanente el ejercicio registrado?\nNo será posible recuperar los datos una vez completada la acción."),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("Confirmar"),
                        content: new Text("¿Es lo que realmente desea hacer?"),
                        actions: <Widget>[
                          new FlatButton(
                            onPressed: () async {
                              initLoader(context, "Eliminando...");
                              if(type == 'p') {
                                int code = 1;
                                //int code = await (new QueryD()).removePatient(therapist, patient);
                                DialogTemplate.terminateLoader();
                                showStatusDelete(context, code);
                              }
                              else if(type == 'e') {
                                int code = 1;
                                //int code = await (new QueryD()).removeExercise(exercise.id);
                                DialogTemplate.terminateLoader();
                                showStatusDelete(context, code);
                              }
                              else if(type == 'r') {

                                DialogTemplate.terminateLoader();
                                showStatusDelete(context, 0);
                              }
                              else {
                                DialogTemplate.terminateLoader();
                                showMessage(context, "No hackee");
                              }
                            },
                            child: new Text("Sí"),
                          ),
                          new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: new Text("No"),
                          ),
                        ],
                      );
                    }
                );

              },
              child: new Text("Sí"),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: new Text("No"),
            ),
          ],
        );
      },
    );
  }

   */

  static void initLoader(BuildContext context, String message) {
    progress = new ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
    );
    progress.style(
        message: message,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    progress.show();
  }

  static void terminateLoader(){
    if(progress.isShowing() && progress != Null) {
      progress.hide();
    }
  }
}