import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

void Mensajes(String titulo, String descripcion,DialogType tipoMensaje, BuildContext context) async {
  print(tipoMensaje);
  AwesomeDialog(
    context: context,
    dialogType: tipoMensaje,
    animType: AnimType.rightSlide,
    title: titulo,
    desc: descripcion,
    btnOkOnPress: () {
   
    },
    btnOkColor: tipoMensaje == DialogType.error ? Colors.red : tipoMensaje == DialogType.success ? Colors.green : tipoMensaje == DialogType.warning ? Colors.yellow : Colors.blue,
    btnOkText: 'continuar'
  ).show();
}