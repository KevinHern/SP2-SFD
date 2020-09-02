import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

// Templates
import 'package:signature_forgery_detection/models/dropdown_item.dart';

class FormTemplate {
  static Widget buildEmailInput(TextEditingController emailController, int labelColor, int borderColor, int borderFocusColor){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.email, color: new Color(labelColor).withOpacity(0.60),),
          labelText: "Email",
          fillColor: Colors.white,
          labelStyle: new TextStyle(
              color: Color(labelColor)
          ),
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Color(borderColor), width: 0.0),
            borderRadius: new BorderRadius.circular(15.0),
          ),

          focusedBorder:OutlineInputBorder(
            borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        validator: (String value) {
          return (value.isEmpty || !value.contains("@")) ? 'Por favor, ingrese un email válido' : null;
        },
        textCapitalization: TextCapitalization.none,

        controller: emailController,
      ),
    );
  }

  static Widget buildSingleTextInput(TextEditingController controller, String caption, IconData icon, int labelColor, int borderColor, int borderFocusColor, bool hide, bool caps){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new TextFormField(
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(labelColor).withOpacity(0.60),),
          labelText: caption,
          fillColor: Colors.white,
          //focusColor: Colors.green,
          labelStyle: new TextStyle(
              color: Color(labelColor)
          ),
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Color(borderColor), width: 0.0),
            borderRadius: new BorderRadius.circular(15.0),
          ),

          focusedBorder:OutlineInputBorder(
            borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        validator: (String value) {
          return (value.isEmpty) ? 'Por favor, llene el campo' : (hide && value.length < 6)? "Ingrese una contraseña de al menos 6 caracteres": null;
        },
        textCapitalization: (caps)? TextCapitalization.sentences : TextCapitalization.none,
        controller: controller,
        obscureText: hide,
      ),
    );
  }

  static Widget buildMultiTextInput(TextEditingController controller, String caption, IconData icon, int labelColor, int borderColor, int borderFocusColor){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new TextFormField(
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(labelColor).withOpacity(0.60),),
          labelText: caption,
          fillColor: Colors.white,
          //focusColor: Colors.green,
          labelStyle: new TextStyle(
              color: Color(labelColor)
          ),
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Color(borderColor), width: 0.0),
            borderRadius: new BorderRadius.circular(15.0),
          ),

          focusedBorder:OutlineInputBorder(
            borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        validator: (String value) {
          return (value.isEmpty) ? 'Por favor, llene el campo' : null;
        },
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: controller,
      ),
    );
  }

  static Widget buildNumberInput(TextEditingController controller, String caption, IconData icon, int labelColor, int borderColor, int borderFocusColor, bool limit) {
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new TextFormField(
        decoration: InputDecoration(
          icon: Icon(icon, color: Color(labelColor).withOpacity(0.60),),
          labelText: caption,
          fillColor: Colors.white,
          //focusColor: Colors.green,
          labelStyle: new TextStyle(
              color: Color(labelColor)
          ),
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Color(borderColor), width: 0.0),
            borderRadius: new BorderRadius.circular(15.0),
          ),

          focusedBorder:OutlineInputBorder(
            borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
            borderRadius: BorderRadius.circular(0.0),
          ),
        ),
        validator: (String value) {
          return (value.isEmpty) ? 'Por favor, llene el campo' : null;
        },
        keyboardType: TextInputType.number,
        inputFormatters: (limit) ? [
          WhitelistingTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8),
        ] :
        [
          WhitelistingTextInputFormatter.digitsOnly
        ],
        controller: controller,
      ),
    );
  }

  static Widget buildDateInput(TextEditingController controller, String caption, IconData icon, int labelColor, int borderColor, int borderFocusColor, String heroTag, BuildContext context){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextFormField(
              decoration: InputDecoration(
                icon: Icon(icon, color: Color(labelColor).withOpacity(0.60),),
                labelText: caption,
                fillColor: Colors.white,
                //focusColor: Colors.green,
                labelStyle: new TextStyle(
                    color: Color(labelColor)
                ),
                enabledBorder:  OutlineInputBorder(
                  borderSide: BorderSide(color: Color(borderColor), width: 0.0),
                  borderRadius: new BorderRadius.circular(15.0),
                ),
                focusedBorder:OutlineInputBorder(
                  borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              validator: (String value) {
                return (value.isEmpty) ? 'Por favor, llene el campo' : (value.contains("Escoja otra ")) ? 'Por favor, escoja una fecha valida' : null;
              },
              controller: controller,
              readOnly: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: heroTag,
              backgroundColor: Color(labelColor),
              child: new Icon(Icons.edit, color: Colors.white,),
              onPressed: () async {
                DateTime date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year-90),
                  lastDate: DateTime(DateTime.now().year+1),
                  initialDate: DateTime.now(),
                );
                controller.text = "${DateTime.parse(date.toString()).day}/${DateTime.parse(date.toString()).month}/${DateTime.parse(date.toString()).year}";
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTimeInput(TextEditingController controller, String caption, IconData icon, int labelColor, int borderColor, int borderFocusColor, String heroTag, BuildContext context){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextFormField(
              decoration: InputDecoration(
                icon: Icon(icon, color: Color(labelColor).withOpacity(0.60),),
                labelText: caption,
                fillColor: Colors.white,
                //focusColor: Colors.green,
                labelStyle: new TextStyle(
                    color: Color(labelColor)
                ),
                enabledBorder:  OutlineInputBorder(
                  borderSide: BorderSide(color: Color(borderColor), width: 0.0),
                  borderRadius: new BorderRadius.circular(15.0),
                ),
                focusedBorder:OutlineInputBorder(
                  borderSide:  BorderSide(color: Color(borderFocusColor), width: 2.0),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              validator: (String value) {
                return (value.isEmpty) ? 'Por favor, llene el campo' : (value.contains("Escoja otra ")) ? 'Por favor, escoja un tiempo valida' : null;
              },
              controller: controller,
              readOnly: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: heroTag,
              backgroundColor: Color(labelColor),
              child: new Icon(Icons.edit, color: Colors.white,),
              onPressed: () async {
                TimeOfDay time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                );
                if (time == null) time = TimeOfDay.now();
                controller.text = (time.hour < 10)? "0${time.hour}:" : "${time.hour}:";
                controller.text += (time.minute < 10)? "0${time.minute}" : "${time.minute}";
              }
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSwitchInput(bool switchedValue, String caption, IconData icon, int labelColor, int trackColor, int markColor) {
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new ListTile(
        leading: new Icon(icon, color: Color(labelColor).withOpacity(0.60),),
        title: new Text(caption, style: new TextStyle(
            color: new Color(labelColor),
          ),
        ),
        trailing: Switch(
          value: switchedValue,
          onChanged: (value){
            switchedValue = value;
          },
          activeTrackColor: new Color(trackColor),
          activeColor: new Color(markColor),
        ),
      ),
    );
  }

  static Widget buildDropDown(List<ListItem> items, ListItem displaying){
    List<DropdownMenuItem<ListItem>> ditems = List();
    for (ListItem listItem in items) {
      ditems.add(
        DropdownMenuItem(
          child: listItem.getDisplay(),
          value: listItem,
        ),
      );
    }

    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new DropdownButtonHideUnderline(
        child: new DropdownButton(
          items: ditems,
          value: displaying,
          onChanged: (onChange) {
            displaying = onChange;
          },
        ),
      ),
    );
  }
  /*

   */
}