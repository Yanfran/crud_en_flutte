// main.dart
import 'package:crud/carousel_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'carousel_page.dart';
import 'image_form_page.dart';
import 'image_form_cubit.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler para notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Notificación en segundo plano: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Se configura el handler para segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Se Obtiene el token de FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token: $token"); 

  runApp(
    BlocProvider(
      create: (_) => ImageFormCubit(token), // Pasar el token a ImageFormCubit
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   @override
  void initState() {
    super.initState();

    // Configura los listeners para cada tipo de notificación
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationSnackBar(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta desde segundo plano: ${message.notification?.title}');
      _showNotificationSnackBar(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Notificación abrió la app desde cerrada: ${message.notification?.title}');
        _showNotificationSnackBar(message);
      }
    });
  }

  void _showNotificationSnackBar(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final snackBar = SnackBar(
        content: Text('Notificación: ${notification.title ?? 'No Title'}'),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageFormPage()),
                );
              },
              child: const Text('Formulario de Subida'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => CarouselCubit()..fetchImages(),
                      child: CarouselPage(),
                    ),
                  ),
                );
              },
              child: const Text('Ver Carrusel'),
            ),
          ],
        ),
      ),
    );
  }
}
