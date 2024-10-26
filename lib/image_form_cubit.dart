// image_form_cubit.dart
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'carousel_page.dart';

class ImageFormCubit extends Cubit<String?> {
  final String? fcmToken; 

  ImageFormCubit(this.fcmToken) : super(null);

  Future<void> createUser(String name, String email, String address, File? imageFile, BuildContext context) async {
    print("LLEGO ACAAAAAAAAAAAA ");
    emit("loading");

    final url = Uri.parse("http://192.168.0.108:8000/api/user/create");

    var request = http.MultipartRequest('POST', url);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['address'] = address;

    // Agrega el token FCM si está disponible
    if (fcmToken != null) {
      request.fields['fcmToken'] = fcmToken!;
    }

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        print("Usuario creado: $data");
        emit("success");

        // Redirige a la CarouselPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CarouselPage()),
        );

      } else {
        print("Error: ${response.statusCode}");
        emit("error");
      }
    } catch (e, stackTrace) {
      print("Error: $e");
      print("Detalles del error: $stackTrace");
      emit("error");
    }
}

}
