import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'services/layout_service.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LayoutService.init(); // Load persisted layouts from local storage
  runApp(const RemoteApp());
}

class RemoteApp extends StatelessWidget {
  const RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Remote',
      theme: _buildBlueTechTheme(),
      home: const StartScreen(),
    );
  }
}
ThemeData _buildBlueTechTheme() {
    // Either use the bundled RobotoMono or GoogleFonts:
    final base = ThemeData.light();

    return base.copyWith(
      primaryColor: const Color(0xFF0D47A1),   // deep blue
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF0D47A1),
        secondary: const Color(0xFF42A5F5),     // light blue accent
        surface: const Color(0xFFE3F2FD),    // very light blue
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 9, 9, 9),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D47A1),
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'RobotoMono',            // if bundled
          // If using GoogleFonts, see commented code below
          // fontFamily: GoogleFonts.robotoMono().fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: const Color.fromARGB(255, 235, 231, 231),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',           // if bundled
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
          elevation: 4,
        ),
      ),
      /*
      // TextTheme: if you bundled RobotoMono manually:
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: Color(0xFF0D47A1),
        ),
        titleLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Color(0xFF1565C0),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 16,
          color: Color(0xFF212121),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          color: Color(0xFF424242),
        ),
      ),
      */
      // If using Google Fonts instead of bundling, replace the above with:
      
      textTheme: GoogleFonts.robotoMonoTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.robotoMono(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 11, 103, 241),
        ),
        titleLarge: GoogleFonts.robotoMono(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1565C0),
        ),
        bodyLarge: GoogleFonts.robotoMono(
          fontSize: 16,
          color: Color.fromARGB(255, 240, 238, 238),
        ),
        bodyMedium: GoogleFonts.robotoMono(
          fontSize: 14,
          color: Color.fromARGB(255, 233, 228, 228),
        ),
      ),
      

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF1976D2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'RobotoMono',
          color: Color.fromARGB(255, 11, 105, 246),
        ),
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFF0D47A1),
        size: 24,
      ),
    );
  }

