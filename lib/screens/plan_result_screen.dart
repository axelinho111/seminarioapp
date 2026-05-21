import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'auth_screen.dart';

class PlanResultScreen extends StatefulWidget {
  const PlanResultScreen({super.key});

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen> {
  
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text("Error: No user session")));
    final userId = user.id;
    final userEmail = user.email ?? "Usuario";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            Text("FITNESS AI", style: GoogleFonts.orbitron(fontSize: 10, letterSpacing: 2, color: const Color(0xFF2563EB))),
            Text(userEmail.split('@')[0].toUpperCase(), style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: "Cerrar Sesión",
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('fitness_plans')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildLoadingState("CONECTANDO...");

          final planData = snapshot.data!.first;
          final String status = planData['status'] ?? 'pending';
          final String? content = planData['content'];

          if (status == 'completed' || (content != null && content.length > 50)) {
             return _buildPlanContent(content ?? "");
          }

          return _buildLoadingState("GENERANDO TU RUTINA...");
        },
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(child: const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF2563EB))),
          const SizedBox(height: 32),
          Text(message, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("El cerebro de n8n está procesando tus datos...", style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildPlanContent(String content) {
    // Limpieza estética de Markdown para la presentación
    final cleanContent = content
        .replaceAll('**', '')
        .replaceAll('###', '')
        .replaceAll('🏆', '✨')
        .trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: FadeInUp(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), 
                    blurRadius: 30,
                    offset: const Offset(0, 15)
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text("PROTOCOLO IA VALIDADO", 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(cleanContent, 
                    style: GoogleFonts.inter(fontSize: 15, height: 1.8, color: const Color(0xFF1E293B))
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text("VOLVER A EDITAR DATOS"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
