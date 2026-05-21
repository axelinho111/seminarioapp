# Walkthrough: AI-Powered Fitness Architecture (Flutter + n8n)

Hemos completado la construcción de la aplicación "Fitness AI Brain". El sistema está diseñado para ofrecer una experiencia premium y segura, utilizando n8n como motor de inteligencia.

## 📱 App Flutter (Frontend Premium)
- **Onboarding Dinámico**: [onboarding_screen.dart](file:///C:/Users/Usuario/AndroidStudioProjects/fitness2/lib/screens/onboarding_screen.dart). Flujo tipo encuesta con animaciones de entrada y feedback cinético.
- **Modo Seguro**: Detecta lesiones en tiempo real y ajusta la UI para informar al usuario sobre la protección de sus articulaciones.
- **Servicio Supabase**: [supabase_service.dart](file:///C:/Users/Usuario/AndroidStudioProjects/fitness2/lib/services/supabase_service.dart). Envía automáticamente el perfil de salud para su procesamiento.

## 🧠 Cerebro n8n (Motor de Inteligencia)
- **Flujo de Trabajo**: [n8n_flow_copy_paste.json](file:///C:/Users/Usuario/AndroidStudioProjects/fitness2/n8n_flow_copy_paste.json).
- **Lógica de Decisión**:
  - Filtra recetas para vegetarianos/veganos.
  - Activa el "Modo Seguro" para excluir ejercicios de alto impacto si hay lesiones.
  - Utiliza GPT-4 para generar planes hiper-personalizados.

## 🗄️ Backend Supabase (Estructura de Datos)
- **Script SQL**: [supabase_setup.sql](file:///C:/Users/Usuario/AndroidStudioProjects/fitness2/supabase_setup.sql). Incluye Row Level Security (RLS) para proteger los datos de salud sensibles.

## 🚀 Instrucciones de Lanzamiento
1. **Supabase**: Ejecuta el SQL en el editor de tu proyecto.
2. **Flutter**: Ejecuta `flutter pub get` y asegúrate de poner tus llaves en `main.dart`.
3. **n8n**: Importa el JSON adjunto, configura el Webhook y tus credenciales de IA/Supabase.
