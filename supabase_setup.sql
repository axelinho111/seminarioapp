-- REVISIÓN DE QA: Esquema robusto con manejo de conflictos para el usuario de prueba

-- 1. Enums
DO $$ BEGIN
    CREATE TYPE diet_enum AS ENUM ('standard', 'vegetarian', 'vegan', 'keto', 'paleo');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE plan_status AS ENUM ('pending', 'processing', 'completed', 'failed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Tablas
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  full_name TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS health_data (
  id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  weight FLOAT NOT NULL,
  height FLOAT NOT NULL,
  injuries TEXT[] DEFAULT '{}',
  is_safe_mode_active BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dietary_preferences (
  id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  diet_type diet_enum DEFAULT 'standard',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fitness_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE, -- UNIQUE para permitir upsert por user_id
  plan_type TEXT NOT NULL,
  content TEXT,
  status plan_status DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. INSERTAR USUARIO DE PRUEBA (Para evitar errores de FK)
INSERT INTO profiles (id, full_name)
VALUES ('00000000-0000-0000-0000-000000000000', 'Usuario QA Test')
ON CONFLICT (id) DO NOTHING;

-- 4. RLS (Desactivado temporalmente para pruebas rápidas de QA, activar en producción)
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE health_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE dietary_preferences DISABLE ROW LEVEL SECURITY;
ALTER TABLE fitness_plans DISABLE ROW LEVEL SECURITY;
