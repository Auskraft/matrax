import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MatraxApp(),
    ),
  );
}

class MatraxApp extends StatelessWidget {
  const MatraxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'Matrax',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const MainScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF04050B) : const Color(0xFFF0EAD9);
    final surface = isDark ? const Color(0xFF0E101E) : const Color(0xFFFFFDF5);
    final t1 = isDark ? const Color(0xFFE2EAF8) : const Color(0xFF2A1F12);
    final t2 = isDark ? const Color(0xFF4E5A78) : const Color(0xFF8A7A60);
    final accent = isDark ? const Color(0xFF4F8EF7) : const Color(0xFF1E5BC9);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: Colors.white,
        secondary: const Color(0xFF00E5A0),
        onSecondary: Colors.black,
        error: const Color(0xFFFF5E5E),
        onError: Colors.white,
        surface: surface,
        onSurface: t1,
      ),
      textTheme: GoogleFonts.syneTextTheme().copyWith(
        bodySmall: GoogleFonts.jetBrainsMono(color: t2, fontSize: 12),
        bodyMedium: GoogleFonts.syne(color: t1, fontSize: 14),
        bodyLarge: GoogleFonts.syne(color: t1, fontSize: 16),
        titleMedium: GoogleFonts.syne(color: t1, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.syne(color: t1, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      useMaterial3: true,
    );
  }
}