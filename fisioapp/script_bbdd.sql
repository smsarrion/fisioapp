-- Crear tabla de empresas (tenants)
CREATE TABLE empresas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(50),
    email VARCHAR(255),
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de usuarios
CREATE TABLE usuarios (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    rol VARCHAR(50) NOT NULL, -- 'admin', 'profesional', 'recepcionista'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de pacientes
CREATE TABLE pacientes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(50),
    direccion TEXT,
    fecha_nacimiento DATE,
    dni VARCHAR(50),
    historial_medico TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de profesionales
CREATE TABLE profesionales (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(50),
    especialidad VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de servicios/tratamientos
CREATE TABLE servicios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    duracion INTEGER NOT NULL, -- en minutos
    precio DECIMAL(10, 2),
    color VARCHAR(7), -- código hexadecimal para el color en el calendario
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de citas
CREATE TABLE citas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    paciente_id UUID REFERENCES pacientes(id) ON DELETE CASCADE NOT NULL,
    profesional_id UUID REFERENCES profesionales(id) ON DELETE CASCADE NOT NULL,
    servicio_id UUID REFERENCES servicios(id) ON DELETE CASCADE NOT NULL,
    fecha_hora_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_hora_fin TIMESTAMP WITH TIME ZONE NOT NULL,
    estado VARCHAR(50) NOT NULL, -- 'programada', 'confirmada', 'cancelada', 'completada'
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear políticas de seguridad (RLS) para las tablas
-- Política para empresas
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver su propia empresa" ON empresas
    FOR SELECT USING (auth.uid() IN (SELECT id FROM usuarios WHERE empresa_id = empresas.id));

CREATE POLICY "Solo los administradores pueden insertar empresas" ON empresas
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT id FROM usuarios WHERE rol = 'admin'));

CREATE POLICY "Solo los administradores pueden actualizar empresas" ON empresas
    FOR UPDATE USING (auth.uid() IN (SELECT id FROM usuarios WHERE rol = 'admin'));

-- Política para usuarios
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver usuarios de su empresa" ON usuarios
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Solo los administradores pueden insertar usuarios" ON usuarios
    FOR INSERT WITH CHECK (
        auth.uid() IN (SELECT id FROM usuarios WHERE rol = 'admin') AND
        empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid())
    );

CREATE POLICY "Los usuarios pueden actualizar su propio perfil" ON usuarios
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Solo los administradores pueden actualizar usuarios de su empresa" ON usuarios
    FOR UPDATE USING (
        auth.uid() IN (SELECT id FROM usuarios WHERE rol = 'admin') AND
        empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid())
    );

-- Políticas para pacientes, profesionales, servicios y citas
ALTER TABLE pacientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver pacientes de su empresa" ON pacientes
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar pacientes de su empresa" ON pacientes
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar pacientes de su empresa" ON pacientes
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar pacientes de su empresa" ON pacientes
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

ALTER TABLE profesionales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver profesionales de su empresa" ON profesionales
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar profesionales de su empresa" ON profesionales
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar profesionales de su empresa" ON profesionales
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar profesionales de su empresa" ON profesionales
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

ALTER TABLE servicios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver servicios de su empresa" ON servicios
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar servicios de su empresa" ON servicios
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar servicios de su empresa" ON servicios
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar servicios de su empresa" ON servicios
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

ALTER TABLE citas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver citas de su empresa" ON citas
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar citas de su empresa" ON citas
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar citas de su empresa" ON citas
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar citas de su empresa" ON citas
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE id = auth.uid()));

-- Crear triggers para actualizar updated_at
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_empresas
    BEFORE UPDATE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_usuarios
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_pacientes
    BEFORE UPDATE ON pacientes
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_profesionales
    BEFORE UPDATE ON profesionales
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_servicios
    BEFORE UPDATE ON servicios
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_citas
    BEFORE UPDATE ON citas
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();