-- ============================================================================
-- PROYECTO INTEGRADO: nuam exchange - SISTEMA DE GESTIÓN TRIBUTARIA
-- SCRIPT DDL: MODELO FÍSICO DE BASE DE DATOS (PostgreSQL 15+)
-- ENTORNO: Docker / PostgreSQL Relacional
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. ESQUEMAS DE SEGURIDAD Y MULTI-TENANCY
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS tributario;
CREATE SCHEMA IF NOT EXISTS auditoria;

-- ============================================================================
-- 2. TABLAS MAESTRAS (ESQUEMA core)
-- ============================================================================

-- Tabla de Corredoras de Bolsa (Aislamiento de Clientes / Multitenancy)
CREATE TABLE core.corredoras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo_corredora VARCHAR(10) NOT NULL UNIQUE,       -- Ej: 'CORR-01', 'BTG', 'LARRAIN'
    razon_social VARCHAR(150) NOT NULL,
    rut VARCHAR(12) NOT NULL UNIQUE,                   -- RUT con formato XX.XXX.XXX-X
    pais VARCHAR(3) NOT NULL DEFAULT 'CHL',            -- Chile, Perú o Colombia (nuam)
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Roles y Permisos de Sistema
CREATE TABLE core.roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,                -- 'ADMIN_SISTEMA', 'OPERADOR_CORREDORA', 'AUDITOR_TRIBUTARIO'
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tabla de Usuarios
CREATE TABLE core.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corredora_id UUID NOT NULL REFERENCES core.corredoras(id) ON DELETE RESTRICT,
    rol_id INT NOT NULL REFERENCES core.roles(id) ON DELETE RESTRICT,
    nombre_completo VARCHAR(120) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    hash_password VARCHAR(255) NOT NULL,              -- Argon2id / bcrypt
    mfa_habilitado BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_secreto VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMPTZ,
    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Instrumentos / Acciones
CREATE TABLE core.instrumentos (
    id SERIAL PRIMARY KEY,
    nemo VARCHAR(40) NOT NULL UNIQUE,                 -- Nemotécnico bursátil (ej: 'COPEC', 'LTAM', 'CHILE')
    razon_social_emisor VARCHAR(150) NOT NULL,
    rut_emisor VARCHAR(12) NOT NULL,
    mercado VARCHAR(10) NOT NULL DEFAULT 'ACN',       -- Acciones Nacionales ('AC', 'ACN')
    tipo_sociedad CHAR(1) NOT NULL CHECK (tipo_sociedad IN ('A', 'C')), -- 'A' Abierta, 'C' Cerrada
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. TABLAS DE GESTIÓN TRIBUTARIA (ESQUEMA tributario)
-- ============================================================================

-- Tabla de Eventos de Capital / Dividendos
CREATE TABLE tributario.eventos_capital (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instrumento_id INT NOT NULL REFERENCES core.instrumentos(id) ON DELETE RESTRICT,
    ejercicio_tributario INT NOT NULL CHECK (ejercicio_tributario BETWEEN 2000 AND 2100),
    secuencia_evento INT NOT NULL,                     -- Número de secuencia oficial
    numero_dividendo INT,
    fecha_pago DATE NOT NULL,
    descripcion_evento VARCHAR(150),                   -- Ej: 'DIVIDENDO PROVISORIO US$ 0.45'
    valor_historico NUMERIC(16, 4) DEFAULT 0,
    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_evento UNIQUE (instrumento_id, ejercicio_tributario, secuencia_evento, fecha_pago)
);

-- Tabla de Calificación Tributaria Cabecera
CREATE TABLE tributario.calificaciones_cabecera (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corredora_id UUID NOT NULL REFERENCES core.corredoras(id) ON DELETE RESTRICT,
    evento_id UUID NOT NULL REFERENCES tributario.eventos_capital(id) ON DELETE RESTRICT,
    tipo_certificado VARCHAR(20) NOT NULL CHECK (tipo_certificado IN ('CERT_70', 'CERT_44')), -- Cert. 70 (DJ 1948) o Cert. 44 (DJ 1922)
    origen_datos VARCHAR(20) NOT NULL CHECK (origen_datos IN ('CARGA_MASIVA_CSV', 'INGRESO_MANUAL', 'API_REST')),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' CHECK (estado IN ('BORRADOR', 'ACTIVA', 'OBSOLETA', 'ANULADA')),
    usuario_registro_id UUID NOT NULL REFERENCES core.usuarios(id),
    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_calificacion UNIQUE (corredora_id, evento_id, tipo_certificado)
);

-- Tabla de Factores Tributarios (F8 a F37)
-- Regla de Negocio: Precisión de 8 decimales exactos.
-- F8 a F33 calculados o directos; F34 a F37 tasas especiales y devoluciones.
CREATE TABLE tributario.factores_mensuales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    calificacion_id UUID NOT NULL REFERENCES tributario.calificaciones_cabecera(id) ON DELETE CASCADE,
    
    -- Factores Afectos a IGC / IA (Columnas 8 a 19 - Suma <= 1.00000000)
    factor_08 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Con crédito IDPC generado post 2017
    factor_09 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Con crédito IDPC acumulado pre 2017
    factor_10 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Con crédito IDPC voluntario
    factor_11 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Sin derecho a crédito
    factor_12 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- RAP y diferencia inicial 14 TER
    factor_13 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Otras rentas sin prioridad
    factor_14 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Exceso distribuciones desproporcionadas
    factor_15 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Utilidades afectadas ISFUT Ley 20.780
    factor_16 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Rentas pre 1983 / ISFUT Ley 21.210
    factor_17 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Exentas IGC Art 11 Ley 18.401 afectas IA
    factor_18 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Exentas IGC e IA
    factor_19 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Ingresos No Constitutivos de Renta (INR)

    -- Factores Créditos para IGC / IA (Columnas 20 a 33)
    factor_20 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_21 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_22 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_23 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_24 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_25 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_26 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_27 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_28 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_29 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_30 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_31 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_32 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,
    factor_33 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000,

    -- Factores de Tasas Especiales y Devoluciones (Columnas 34 a 37)
    factor_34 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Crédito Art. 21 LIR
    factor_35 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Tasa Efectiva Crédito FUT (TEF)
    factor_36 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Tasa Efectiva Crédito FUNT (TEX)
    factor_37 NUMERIC(10, 8) NOT NULL DEFAULT 0.00000000, -- Devolución Capital Art. 17 N° 7 LIR

    creado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- RESTRICCIÓN DE INTEGRIDAD TRIBUTARIA: Sumatoria F8 a F19 debe ser <= 1.00000000
    CONSTRAINT chk_suma_factores_base CHECK (
        (factor_08 + factor_09 + factor_10 + factor_11 + 
         factor_12 + factor_13 + factor_14 + factor_15 + 
         factor_16 + factor_17 + factor_18 + factor_19) <= 1.00000001
    )
);

-- ============================================================================
-- 4. TABLAS DE CARGA MASIVA Y AUDITORÍA FORENSE (ESQUEMA auditoria)
-- ============================================================================

-- Registro de Lotes de Carga Masiva
CREATE TABLE auditoria.lotes_carga (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corredora_id UUID NOT NULL REFERENCES core.corredoras(id),
    usuario_id UUID NOT NULL REFERENCES core.usuarios(id),
    nombre_archivo VARCHAR(150) NOT NULL,
    hash_sha256 VARCHAR(64) NOT NULL,                 -- Integridad del archivo recibido
    total_filas INT NOT NULL DEFAULT 0,
    filas_procesadas INT NOT NULL DEFAULT 0,
    filas_actualizadas INT NOT NULL DEFAULT 0,
    filas_erroneas INT NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('EN_PROCESO', 'EXITOSA', 'CON_ERRORES', 'FALLIDA')),
    errores_detalle JSONB DEFAULT '[]'::jsonb,        -- Array de errores por fila
    iniciado_el TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finalizado_el TIMESTAMPTZ
);

-- Registro de Auditoría Inmutable (Append-Only)
CREATE TABLE auditoria.trazabilidad (
    id BIGSERIAL PRIMARY KEY,
    corredora_id UUID NOT NULL REFERENCES core.corredoras(id),
    usuario_id UUID REFERENCES core.usuarios(id),
    tabla_afectada VARCHAR(60) NOT NULL,
    registro_id UUID NOT NULL,
    operacion VARCHAR(10) NOT NULL CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    valor_anterior JSONB,                             -- Snapshot previo
    valor_nuevo JSONB,                                -- Snapshot nuevo
    direccion_ip VARCHAR(45) NOT NULL,
    user_agent TEXT,
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Evitar modificaciones o eliminaciones en la tabla de auditoría (Ley 21.663)
CREATE OR REPLACE FUNCTION auditoria.fn_proteger_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Operación denegada: La tabla de trazabilidad es estrictamente inmutable.';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inmutabilidad_auditoria
BEFORE UPDATE OR DELETE ON auditoria.trazabilidad
FOR EACH ROW EXECUTE FUNCTION auditoria.fn_proteger_auditoria();

-- ============================================================================
-- 5. ÍNDICES DE ALTO RENDIMIENTO
-- ============================================================================
CREATE INDEX idx_calif_corredora ON tributario.calificaciones_cabecera(corredora_id);
CREATE INDEX idx_calif_evento ON tributario.calificaciones_cabecera(evento_id);
CREATE INDEX idx_factores_calif ON tributario.factores_mensuales(calificacion_id);
CREATE INDEX idx_eventos_ejercicio ON tributario.eventos_capital(ejercicio_tributario, fecha_pago);
CREATE INDEX idx_trazabilidad_filtro ON auditoria.trazabilidad(corredora_id, fecha_evento);
