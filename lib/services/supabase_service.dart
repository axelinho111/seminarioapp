import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _supabase = Supabase.instance.client;

  static Future<void> saveUserOnboarding({
    required double weight,
    required double height,
    required String diet,
    required List<String> injuries,
  }) async {
    // ID de usuario
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Debes iniciar sesión para guardar datos.");
    final userId = user.id;

    try {
      // 1. Guardar o actualizar datos
      await _supabase.from('health_data').upsert({
        'id': userId,
        'weight': weight,
        'height': height,
        'injuries': injuries,
        'is_safe_mode_active': injuries.isNotEmpty,
      });

      // 2. Guardar preferencias dietéticas
      await _supabase.from('dietary_preferences').upsert({
        'id': userId,
        'diet_type': diet,
      });

      // 3. Inicializar registro de plan en Supabase
      await _supabase.from('fitness_plans').upsert({
        'user_id': userId,
        'plan_type': 'workout',
        'status': 'pending',
      }, onConflict: 'user_id');

      // 4. LLAMADA DIRECTA A n8n vía ngrok (Motor Local sin API Premium)
      final n8nUrl = 'https://urology-stunner-bok.ngrok-free.dev/webhook-test/fitness-brain-webhook';
      
      final response = await http.post(
        Uri.parse(n8nUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'weight': weight,
          'height': height,
          'diet': diet,
          'injuries': injuries,
        }),
      );

      print('DEBUG: n8n respondió con status ${response.statusCode}');
    } catch (e) {
      print('❌ ERROR EN INTEGRACIÓN: $e');
      rethrow;
    }
  }
}
