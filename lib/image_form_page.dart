import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'image_form_cubit.dart';

class ImageFormPage extends StatefulWidget {
  final String? token;

  const ImageFormPage({Key? key, this.token}) : super(key: key);

  @override
  _ImageFormPageState createState() => _ImageFormPageState();
}

class _ImageFormPageState extends State<ImageFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  String? _nameError;
  String? _emailError;
  String? _addressError;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  bool _validateFields() {
    bool isValid = true;

    setState(() {
      _nameError = _nameController.text.length < 3
          ? 'El nombre debe tener al menos 3 caracteres'
          : null;

      _emailError = !_isValidEmail(_emailController.text)
          ? 'Ingrese un correo electrónico válido'
          : null;

      _addressError = _addressController.text.length < 5
          ? 'La dirección debe tener al menos 5 caracteres'
          : null;
    });

    if (_nameError != null || _emailError != null || _addressError != null) {
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Imagen')),
      body: BlocProvider(
        create: (_) => ImageFormCubit(widget.token),
        child: BlocListener<ImageFormCubit, String?>(
          listener: (context, state) {
            if (state == "success") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Imagen subida exitosamente')),
              );
            } else if (state == "error") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al subir la imagen')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    errorText: _nameError,
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    errorText: _emailError,
                  ),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    errorText: _addressError,
                  ),
                ),
                const SizedBox(height: 20),
                _imageFile == null
                    ? const Text("No hay imagen seleccionada")
                    : Image.file(_imageFile!, height: 100, width: 100),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Seleccionar Imagen'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_validateFields()) {
                      final name = _nameController.text;
                      final email = _emailController.text;
                      final address = _addressController.text;
                      context.read<ImageFormCubit>().createUser(
                          name, email, address, _imageFile, context);
                    }
                  },
                  child: const Text('Subir Imagen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
