
CREATE SCHEMA IF NOT EXISTS fisioapp8004;

set search_path to fisioapp8004;

CREATE TABLE IF NOT EXISTS fisioapp8004.infobasica (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    cif varchar PRIMARY KEY,
    email varchar,
    vatic varchar,
    nomfiscal varchar NOT NULL,
    nomcomercial varchar,
    telf varchar,
    adres varchar,
    cp varchar,
    ciutat varchar,
    poblacio varchar,
    pais varchar NOT NULL,
    inforegciv text
);

ALTER TABLE fisioapp8004.infobasica ENABLE ROW LEVEL SECURITY;

drop policy "Users can query their own rows" on fisioapp8004.infobasica;

create policy "Users can query their own rows"
on fisioapp8004.infobasica for select
using (tenant_id = auth.uid());

drop policy "Users can update their own rows" on fisioapp8004.infobasica;

create policy "Users can update their own rows"
on fisioapp8004.infobasica for update
using (tenant_id = auth.uid());

drop policy "Users can delete their own rows" on fisioapp8004.infobasica;

create policy "Users can delete their own rows"
on fisioapp8004.infobasica for delete
using (tenant_id = auth.uid());

drop policy "Users can insert their own rows" on fisioapp8004.infobasica;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.infobasica
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.clients (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    cif varchar UNIQUE NOT NULL,
    email varchar,
    nomfiscal varchar NOT NULL,
    nomcomercial varchar,
    telf varchar,
    adres varchar,
    cp varchar,
    ciutat varchar,
    re bool default false,
    id_dcpte int,
    PRIMARY KEY (tenant_id, cif)
);

ALTER TABLE fisioapp8004.clients ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.clients;

create policy "Users can query their own rows"
on fisioapp8004.clients for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.clients;

create policy "Users can update their own rows"
on fisioapp8004.clients for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.clients;

create policy "Users can delete their own rows"
on fisioapp8004.clients for delete
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.clients;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.clients
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.proveidors (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    cif varchar NOT NULL,
    email varchar,
    nomfiscal varchar NOT NULL,
    nomcomercial varchar,
    telf varchar,
    adres varchar,
    cp varchar,
    ciutat varchar,
    PRIMARY KEY (tenant_id, cif)
);

ALTER TABLE fisioapp8004.proveidors ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.proveidors;

create policy "Users can query their own rows"
on fisioapp8004.proveidors for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.proveidors;

create policy "Users can update their own rows"
on fisioapp8004.proveidors for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.proveidors;

create policy "Users can delete their own rows"
on fisioapp8004.proveidors for delete
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.proveidors;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.proveidors
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());


CREATE TABLE IF NOT EXISTS fisioapp8004.impostos (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    nom varchar NOT NULL,
    impost varchar NOT NULL,
    re varchar,
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE fisioapp8004.impostos ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.impostos;

create policy  "Users can query their own rows"
on fisioapp8004.impostos for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.impostos;

create policy "Users can update their own rows"
on fisioapp8004.impostos for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.impostos;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.impostos
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.impostos;

create policy "Users can delete their own rows"
on fisioapp8004.impostos for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.unitats (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial NOT NULL,
    nom varchar NOT NULL,
    descripcio varchar NOT NULL,
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE fisioapp8004.unitats ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.unitats;

create policy  "Users can query their own rows"
on fisioapp8004.unitats for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.unitats;

create policy "Users can update their own rows"
on fisioapp8004.unitats for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.unitats;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.unitats
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.unitats;

create policy "Users can delete their own rows"
on fisioapp8004.unitats for delete
using (tenant_id = auth.uid());



CREATE TABLE IF NOT EXISTS fisioapp8004.numeracions (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial NOT NULL,
    nom varchar NOT NULL,
    serie varchar NOT NULL,
    numero integer NOT NULL,
    id_doc int NOT NULL,    
    PRIMARY KEY (tenant_id, id)
);


ALTER TABLE fisioapp8004.numeracions ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.numeracions;

create policy  "Users can query their own rows"
on fisioapp8004.numeracions for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.numeracions;

create policy "Users can update their own rows"
on fisioapp8004.numeracions for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.numeracions;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.numeracions
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.numeracions;

create policy "Users can delete their own rows"
on fisioapp8004.numeracions for delete
using (tenant_id = auth.uid());


CREATE TABLE IF NOT EXISTS fisioapp8004.categories (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    nom varchar NOT NULL,
    descripcio varchar,
    impost varchar,
    id_dcpte int,
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE fisioapp8004.categories ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.categories;

create policy  "Users can query their own rows"
on fisioapp8004.categories for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.categories;

create policy "Users can update their own rows"
on fisioapp8004.categories for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.categories;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.categories
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.categories;

create policy "Users can delete their own rows"
on fisioapp8004.categories for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.productes (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    ref varchar, --UNIQUE NULLS NOT DISTINCT,
    nom varchar UNIQUE NOT NULL,
    descripcio varchar,
    preu float8,
    impost int REFERENCES fisioapp8004.impostos(id),
    categoria_id integer REFERENCES fisioapp8004.categories(id),
    id_dcpte int REFERENCES fisioapp8004.dtespromocions(id),
    unitat_id int,  
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE fisioapp8004.productes ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.productes;

create policy  "Users can query their own rows"
on fisioapp8004.productes for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.productes;

create policy "Users can update their own rows"
on fisioapp8004.productes for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.productes;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.productes
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.productes;

create policy "Users can delete their own rows"
on fisioapp8004.productes for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.cap_Comanda (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_comanda varchar NOT NULL,
    id_client varchar REFERENCES fisioapp8004.clients(cif),
    data_crea date,
    footer_text text,
    tipus_dscpte int2 default 0,
    PRIMARY KEY (tenant_id, num_comanda)
);

ALTER TABLE fisioapp8004.cap_Comanda ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.cap_Comanda;

create policy  "Users can query their own rows"
on fisioapp8004.cap_Comanda for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.cap_Comanda;

create policy "Users can update their own rows"
on fisioapp8004.cap_Comanda for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.cap_Comanda;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.cap_Comanda
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.cap_Comanda;

create policy "Users can delete their own rows"
on fisioapp8004.cap_Comanda for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.lin_Comanda (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_comanda varchar NOT NULL,
    linia int NOT NULL,
    id_producte int NOT NULL  REFERENCES fisioapp8004.productes(id),
    ref_producte varchar,
    quantitat float4 NOT NULL,
    preu float8 NOT NULL,
    iva varchar,
    dscpte float4,
    PRIMARY KEY (tenant_id, num_comanda, id_producte)
);

ALTER TABLE fisioapp8004.lin_Comanda ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.lin_Comanda;

create policy  "Users can query their own rows"
on fisioapp8004.lin_Comanda for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.lin_Comanda;

create policy "Users can update their own rows"
on fisioapp8004.lin_Comanda for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.lin_Comanda;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.lin_Comanda
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.lin_Comanda;

create policy "Users can delete their own rows"
on fisioapp8004.lin_Comanda for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.cap_Factura (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_factura varchar NOT NULL,
    id_client varchar REFERENCES fisioapp8004.clients(cif),
    data_crea date,
    data_venciment date,
    footer_text text,
    tipus_dscpte int2 default 0,
    PRIMARY KEY (tenant_id, num_factura)
);

ALTER TABLE fisioapp8004.cap_Factura ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.cap_Factura;

create policy  "Users can query their own rows"
on fisioapp8004.cap_Factura for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.cap_Factura;

create policy "Users can update their own rows"
on fisioapp8004.cap_Factura for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.cap_Factura;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.cap_Factura
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.cap_Factura;

create policy "Users can delete their own rows"
on fisioapp8004.cap_Factura for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.lin_Factura (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_factura varchar NOT NULL,
    linia int NOT NULL,
    id_producte int NOT NULL  REFERENCES fisioapp8004.productes(id),
    ref_producte varchar,
    quantitat float4 NOT NULL,
    preu float8 NOT NULL,
    iva varchar,
    dscpte float4,
    PRIMARY KEY (tenant_id, num_factura, id_producte)
);

ALTER TABLE fisioapp8004.lin_Factura ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.lin_Factura;

create policy  "Users can query their own rows"
on fisioapp8004.lin_Factura for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.lin_Factura;

create policy "Users can update their own rows"
on fisioapp8004.lin_Factura for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.lin_Factura;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.lin_Factura
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.lin_Factura;

create policy "Users can delete their own rows"
on fisioapp8004.lin_Factura for delete
using (tenant_id = auth.uid());


CREATE TABLE IF NOT EXISTS fisioapp8004.cap_Abono (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_abono varchar NOT NULL,
    id_client varchar REFERENCES fisioapp8004.clients(cif),
    data_crea date,
    footer_text text,
    tipus_dscpte int2 default 0,
    PRIMARY KEY (tenant_id, num_abono)
);

ALTER TABLE fisioapp8004.cap_Abono ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.cap_Abono;

create policy  "Users can query their own rows"
on fisioapp8004.cap_Abono for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.cap_Abono;

create policy "Users can update their own rows"
on fisioapp8004.cap_Abono for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.cap_Abono;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.cap_Abono
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.cap_Abono;

create policy "Users can delete their own rows"
on fisioapp8004.cap_Abono for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.lin_Abono (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    num_abono varchar NOT NULL,
    linia int NOT NULL,
    id_producte int NOT NULL  REFERENCES fisioapp8004.productes(id),
    ref_producte varchar,
    quantitat float4 NOT NULL,
    preu float8 NOT NULL,
    iva varchar,
    dscpte float4,
    PRIMARY KEY (tenant_id, num_abono, id_producte)
);

ALTER TABLE fisioapp8004.lin_Abono ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.lin_Abono;

create policy  "Users can query their own rows"
on fisioapp8004.lin_Abono for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.lin_Abono;

create policy "Users can update their own rows"
on fisioapp8004.lin_Abono for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.lin_Abono;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.lin_Abono
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.lin_Abono;

create policy "Users can delete their own rows"
on fisioapp8004.lin_Abono for delete
using (tenant_id = auth.uid());

CREATE TABLE IF NOT EXISTS fisioapp8004.dtespromocions (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    nom varchar NOT NULL,
    descripcio varchar,
    dcpte float8 NOT NULL,
    data_ini date NOT NULL,
    data_fi date,
    tipus varchar NOT NULL,
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE fisioapp8004.dtespromocions ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.dtespromocions;

create policy  "Users can query their own rows"
on fisioapp8004.dtespromocions for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.dtespromocions;

create policy "Users can update their own rows"
on fisioapp8004.dtespromocions for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.dtespromocions;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.dtespromocions
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.dtespromocions;

create policy "Users can delete their own rows"
on fisioapp8004.dtespromocions for delete
using (tenant_id = auth.uid());


CREATE TABLE IF NOT EXISTS fisioapp8004.textdocs (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    textc text,
    textp text,
    id_doc int NOT NULL,
    posc int,
    posp int,
    PRIMARY KEY (tenant_id, id_doc)
);

ALTER TABLE fisioapp8004.textdocs ENABLE ROW LEVEL SECURITY;

drop policy IF EXISTS "Users can query their own rows" on fisioapp8004.textdocs;

create policy  "Users can query their own rows"
on fisioapp8004.textdocs for select
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can update their own rows" on fisioapp8004.textdocs;

create policy "Users can update their own rows"
on fisioapp8004.textdocs for update
using (tenant_id = auth.uid());

drop policy IF EXISTS "Users can insert their own rows" on fisioapp8004.textdocs;

CREATE POLICY "Users can insert their own rows"
ON fisioapp8004.textdocs
FOR INSERT
TO authenticated
WITH CHECK (tenant_id = auth.uid());

drop policy IF EXISTS "Users can delete their own rows" on fisioapp8004.textdocs;

create policy "Users can delete their own rows"
on fisioapp8004.textdocs for delete
using (tenant_id = auth.uid());



-- Crear tabla de empresas (tenants)
CREATE TABLE IF NOT EXISTS fisioapp8004.empresas (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(50),
    email VARCHAR(255),
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS fisioapp8004.usuarios (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    id serial UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    rol VARCHAR(50) NOT NULL,
    dni VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);




-- Crear tabla de servicios/tratamientos
CREATE TABLE IF NOT EXISTS  fisioapp8004.servicios (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    empresa_id UUID REFERENCES fisioapp8004.empresas(id) ON DELETE CASCADE NOT NULL,
    id serial UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    duracion INTEGER NOT NULL, -- en minutos
    precio DECIMAL(10, 2),
    color VARCHAR(7), -- código hexadecimal para el color en el calendario
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de citas
CREATE TABLE IF NOT EXISTS fisioapp8004.citas (
    tenant_id uuid not null references auth.users (id) default auth.uid(),
    empresa_id UUID REFERENCES fisioapp8004.empresas(id) ON DELETE CASCADE NOT NULL,
    paciente_id UUID REFERENCES fisioapp8004.pacientes(dni) ON DELETE CASCADE NOT NULL,
    profesional_id UUID REFERENCES fisioapp8004.profesionales(dni) ON DELETE CASCADE NOT NULL,
    servicio_id UUID REFERENCES fisioapp8004.servicios(id) ON DELETE CASCADE NOT NULL,
    fecha_hora_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_hora_fin TIMESTAMP WITH TIME ZONE NOT NULL,
    estado VARCHAR(50) NOT NULL, 
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear políticas de seguridad (RLS) para las tablas
-- Política para empresas
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propia empresa" ON empresas
    FOR SELECT USING (auth.uid() IN (SELECT tenant_id FROM usuarios WHERE empresa_id = empresas.id));

CREATE POLICY "Solo los administradores pueden insertar empresas" ON empresas
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT tenant_id FROM usuarios WHERE rol = "admin"));

CREATE POLICY "Solo los administradores pueden actualizar empresas" ON empresas
    FOR UPDATE USING (auth.uid() IN (SELECT tenant_id FROM usuarios WHERE rol = "admin"));

-- Política para usuarios
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver usuarios de su empresa" ON usuarios
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Solo los administradores pueden insertar usuarios" ON usuarios
    FOR INSERT WITH CHECK (
        auth.uid() IN (SELECT tenant_id FROM usuarios WHERE rol = "admin") AND
        empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid())
    );

CREATE POLICY "Los usuarios pueden actualizar su propio perfil" ON usuarios
    FOR UPDATE USING (tenant_id = auth.uid());


CREATE POLICY "Solo los administradores pueden actualizar usuarios de su empresa" ON usuarios
    FOR UPDATE USING (
        auth.uid() IN (SELECT tenant_id FROM usuarios WHERE rol = "admin") AND
        empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid())
    );

-- Políticas para pacientes, profesionales, servicios y citas
ALTER TABLE pacientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver pacientes de su empresa" ON pacientes
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar pacientes de su empresa" ON pacientes
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar pacientes de su empresa" ON pacientes
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar pacientes de su empresa" ON pacientes
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

ALTER TABLE profesionales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver profesionales de su empresa" ON profesionales
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar profesionales de su empresa" ON profesionales
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar profesionales de su empresa" ON profesionales
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar profesionales de su empresa" ON profesionales
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

ALTER TABLE servicios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver servicios de su empresa" ON servicios
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar servicios de su empresa" ON servicios
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar servicios de su empresa" ON servicios
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar servicios de su empresa" ON servicios
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

ALTER TABLE citas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Los usuarios pueden ver citas de su empresa" ON citas
    FOR SELECT USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden insertar citas de su empresa" ON citas
    FOR INSERT WITH CHECK (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden actualizar citas de su empresa" ON citas
    FOR UPDATE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

CREATE POLICY "Los usuarios pueden eliminar citas de su empresa" ON citas
    FOR DELETE USING (empresa_id IN (SELECT empresa_id FROM usuarios WHERE tenant_id = auth.uid()));

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



grant USAGE on schema fisioapp8004 to authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fisioapp8004 TO authenticated;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA fisioapp8004 TO authenticated;