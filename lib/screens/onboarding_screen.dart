import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/supabase_service.dart';
import 'plan_result_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  double _weight = 75;
  double _height = 175;
  String _dietType = 'standard';
  List<String> _injuries = [];
  bool _isSafeMode = false;

  void _onInjurySelected(String injury, bool selected) {
    setState(() {
      if (selected) {
        _injuries.add(injury);
        _isSafeMode = true;
      } else {
        _injuries.remove(injury);
        if (_injuries.isEmpty) _isSafeMode = false;
      }
    });
  }

  Future<void> _submitData() async {
    try {
      // 1. Mostrar pantalla de carga/procesando inmediatamente en la UI actual
      _nextPage();
      
      // 2. Enviar datos a Supabase y n8n
      await SupabaseService.saveUserOnboarding(
        weight: _weight,
        height: _height,
        diet: _dietType,
        injuries: _injuries,
      );
      
      if (mounted) {
        // 3. Navegar a la pantalla de resultados en tiempo real
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlanResultScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
    );
    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWeightStep(),
                  _buildHeightStep(),
                  _buildDietStep(),
                  _buildHealthStep(),
                  _buildFinalStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PASO ${_currentStep + 1} DE 5",
                style: GoogleFonts.orbitron(fontSize: 12, color: Colors.black38, letterSpacing: 2),
              ),
              Text(
                "${((_currentStep + 1) / 5 * 100).toInt()}%",
                style: GoogleFonts.orbitron(fontSize: 12, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              minHeight: 6,
              backgroundColor: Colors.black.withOpacity(0.05),
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return _OnboardingStep(
      title: "BIOMETRÍA",
      subtitle: "¿Cuánto pesas hoy?",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Text(
              "${_weight.toInt()} KG",
              style: GoogleFonts.orbitron(fontSize: 64, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            activeColor: const Color(0xFF2563EB),
            inactiveColor: Colors.black.withOpacity(0.05),
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 50),
          _buildActionButton("CONTINUAR", _nextPage),
        ],
      ),
    );
  }

  Widget _buildHeightStep() {
    return _OnboardingStep(
      title: "BIOMETRÍA",
      subtitle: "¿Cuál es tu altura?",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Text(
              "${_height.toInt()} CM",
              style: GoogleFonts.orbitron(fontSize: 64, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ),
          Slider(
            value: _height,
            min: 120,
            max: 220,
            activeColor: const Color(0xFF2563EB),
            inactiveColor: Colors.black.withOpacity(0.05),
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: 50),
          _buildActionButton("CONTINUAR", _nextPage),
        ],
      ),
    );
  }

  Widget _buildDietStep() {
    return _OnboardingStep(
      title: "PREFERENCIAS",
      subtitle: "Tipo de alimentación",
      child: Column(
        children: [
          _buildSelectionCard("ESTÁNDAR", "Dieta equilibrada", _dietType == 'standard', () => setState(() => _dietType = 'standard')),
          _buildSelectionCard("VEGETARIANO", "Sin proteína animal", _dietType == 'vegetarian', () => setState(() => _dietType = 'vegetarian')),
          _buildSelectionCard("VEGANO", "Basado en plantas", _dietType == 'vegan', () => setState(() => _dietType = 'vegan')),
          const Spacer(),
          _buildActionButton("CONTINUAR", _nextPage),
        ],
      ),
    );
  }

  Widget _buildHealthStep() {
    return _OnboardingStep(
      title: "SEGURIDAD",
      subtitle: "¿Alguna zona a cuidar?",
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ["RODILLA", "HOMBRO", "LUMBAR", "CUELLO"].map((injury) {
              final isSelected = _injuries.contains(injury);
              return ChoiceChip(
                label: Text(injury),
                selected: isSelected,
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                onSelected: (val) => _onInjurySelected(injury, val),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          if (_isSafeMode)
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.05),
                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF2563EB)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "PROTOCOLO SEGURO ACTIVADO. El cerebro filtrará ejercicios de impacto.",
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          _buildActionButton("GENERAR PLAN INTELIGENTE", _submitData),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: const Icon(Icons.sync, size: 100, color: Color(0xFF2563EB))),
          const SizedBox(height: 32),
          Text("ENVIANDO...", style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 16),
          const Text("Sincronizando con el cerebro de n8n.", textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String title, String desc, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B))),
                Text(desc, style: TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text(text, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _OnboardingStep({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: Text(
              title,
              style: GoogleFonts.orbitron(fontSize: 14, color: const Color(0xFF2563EB), letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(child: child),
        ],
      ),
    );
  }
}
