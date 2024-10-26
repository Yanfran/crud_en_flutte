// carousel_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define los estados del carrusel
abstract class CarouselState {
  const CarouselState();
}

class CarouselLoading extends CarouselState {}

class CarouselLoaded extends CarouselState {
  final List<String> images;
  final int currentIndex;

  CarouselLoaded(this.images, {this.currentIndex = 0});
}

class CarouselError extends CarouselState {
  final String message;

  CarouselError(this.message);
}

class CarouselCubit extends Cubit<CarouselState> {
  CarouselCubit() : super(CarouselLoading());

  Future<void> fetchImages() async {
  try {
    final response = await http.get(Uri.parse("http://192.168.0.108:8000/api/user/getAllUsers"));
    print(response);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      
     // Define la URL base del servidor
      const String baseUrl = "http://192.168.0.108:8000";

      // Filtra y convierte los registros con 'imageUrl' no nulo
      final List<String> images = data
          .where((user) => user['imageUrl'] != null)
          .map((user) => '$baseUrl${user['imageUrl']}' as String)  // Concatena la URL base
          .toList();

      emit(CarouselLoaded(images));
    } else {
      emit(CarouselError("Failed to load images"));
    }
  } catch (e) {
    print("Error: $e");
    emit(CarouselError("Error: $e"));
  }
}

  void nextImage() {
    if (state is CarouselLoaded) {
      final currentIndex = (state as CarouselLoaded).currentIndex;
      final images = (state as CarouselLoaded).images;
      emit(CarouselLoaded(images, currentIndex: (currentIndex + 1) % images.length));
    }
  }

  void previousImage() {
    if (state is CarouselLoaded) {
      final currentIndex = (state as CarouselLoaded).currentIndex;
      final images = (state as CarouselLoaded).images;
      emit(CarouselLoaded(images, currentIndex: (currentIndex - 1 + images.length) % images.length));
    }
  }
}
