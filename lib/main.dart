import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'providers/notes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализация SQLite для Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final notesProvider = NotesProvider();
  await notesProvider.initDatabase();

  runApp(
    ChangeNotifierProvider.value(
      value: notesProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1B1E),
        primaryColor: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardTheme(
          elevation: 8,
          color: const Color(0xFF2A2B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
