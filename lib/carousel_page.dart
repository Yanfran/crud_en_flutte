// carousel_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'carousel_cubit.dart';
import 'package:http/http.dart' as http;

class CarouselPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrusel de Imágenes')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CarouselCubit, CarouselState>(
              builder: (context, state) {
                if (state is CarouselLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CarouselLoaded) {
                  return Center(
                    child: Image.network(state.images[state.currentIndex]),
                  );
                } else if (state is CarouselError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('No images available.'));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.read<CarouselCubit>().previousImage(),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => context.read<CarouselCubit>().nextImage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
