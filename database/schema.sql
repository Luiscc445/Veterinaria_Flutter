-- ============================================================================
-- ESQUEMA COMPLETO BASE DE DATOS - SISTEMA RAMBOPET
-- Sistema de Gestión Integral para Clínica Veterinaria
-- ============================================================================
-- Versión: 1.0.0
-- Fecha: Noviembre 2025
-- Base de Datos: PostgreSQL (Supabase)
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONES NECESARIAS
-- ============================================================================

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Habilitar extensión para funciones de encriptación
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 2. TIPOS ENUMERADOS (ENUMS)
-- ============================================================================

-- Roles de usuario en el sistema
CREATE TYPE rol_usuario AS ENUM ('admin', 'medico', 'recepcion', 'tutor');

-- Estados de aprobación de mascotas
CREATE TYPE estado_aprobacion AS ENUM ('pendiente', 'aprobado', 'rechazado');

-- Estados de citas
CREATE TYPE estado_cita AS ENUM (
    'reservada',      -- Cita creada por tutor
    'confirmada',     -- Confirmada por recepción
    'en_sala',        -- Paciente en sala de espera/consultorio
    'atendida',       -- Consulta completada
    'reprogramada',   -- Cita movida a otra fecha
    'cancelada'       -- Cita cancelada
);

-- Tipos de movimiento de inventario
CREATE TYPE tipo_movimiento_inventario AS ENUM (
    'entrada',        -- Compra/recepción de medicamentos
    'salida',         -- Venta directa
    'consumo',        -- Uso en consulta
    'ajuste',         -- Ajuste por inventario físico
    'vencimiento',    -- Retiro por vencimiento
    'devolucion'      -- Devolución a proveedor
);

-- Tipos de servicios veterinarios
CREATE TYPE tipo_servicio AS ENUM (
    'consulta_general',
    'vacunacion',
    'desparasitacion',
    'cirugia',
    'emergencia',
    'control',
    'estetica',
    'laboratorio',
    'hospitalizacion',
    'eutanasia'
);

-- ============================================================================
-- 3. TABLAS PRINCIPALES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 3.1 TABLA: users (Usuarios del sistema - integrada con Supabase Auth)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre_completo VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    rol rol_usuario NOT NULL DEFAULT 'tutor',
    avatar_url TEXT,
    activo BOOLEAN DEFAULT TRUE,
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_rol ON users(rol);
CREATE INDEX idx_users_auth_user_id ON users(auth_user_id);
CREATE INDEX idx_users_activo ON users(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.2 TABLA: tutores (Dueños de mascotas)
-- ----------------------------------------------------------------------------
CREATE TABLE tutores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dni VARCHAR(20) UNIQUE,
    direccion TEXT,
    ciudad VARCHAR(100),
    provincia VARCHAR(100),
    codigo_postal VARCHAR(10),
    contacto_emergencia VARCHAR(255),
    telefono_emergencia VARCHAR(20),
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para tutores
CREATE INDEX idx_tutores_user_id ON tutores(user_id);
CREATE INDEX idx_tutores_dni ON tutores(dni);

-- ----------------------------------------------------------------------------
-- 3.3 TABLA: mascotas (Pacientes)
-- ----------------------------------------------------------------------------
CREATE TABLE mascotas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tutor_id UUID NOT NULL REFERENCES tutores(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL, -- perro, gato, ave, etc.
    raza VARCHAR(100),
    sexo VARCHAR(10), -- macho, hembra
    fecha_nacimiento DATE,
    peso_kg DECIMAL(6,2),
    color VARCHAR(100),
    senias_particulares TEXT,
    microchip VARCHAR(50) UNIQUE,
    foto_url TEXT,
    estado estado_aprobacion DEFAULT 'pendiente',
    aprobado_por UUID REFERENCES users(id),
    fecha_aprobacion TIMESTAMP WITH TIME ZONE,
    motivo_rechazo TEXT,
    alergias TEXT,
    condiciones_preexistentes TEXT,
    esterilizado BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para mascotas
CREATE INDEX idx_mascotas_tutor_id ON mascotas(tutor_id);
CREATE INDEX idx_mascotas_estado ON mascotas(estado);
CREATE INDEX idx_mascotas_especie ON mascotas(especie);
CREATE INDEX idx_mascotas_microchip ON mascotas(microchip);
CREATE INDEX idx_mascotas_activo ON mascotas(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.4 TABLA: servicios (Catálogo de servicios veterinarios)
-- ----------------------------------------------------------------------------
CREATE TABLE servicios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    tipo tipo_servicio NOT NULL,
    descripcion TEXT,
    duracion_minutos INTEGER DEFAULT 30,
    precio_base DECIMAL(10,2),
    requiere_especializacion BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para servicios
CREATE INDEX idx_servicios_tipo ON servicios(tipo);
CREATE INDEX idx_servicios_activo ON servicios(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.5 TABLA: profesionales (Médicos veterinarios)
-- ----------------------------------------------------------------------------
CREATE TABLE profesionales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    matricula_profesional VARCHAR(50) UNIQUE NOT NULL,
    especialidades TEXT[],
    biografia TEXT,
    anios_experiencia INTEGER,
    horario_atencion JSONB, -- {lunes: {inicio: "09:00", fin: "18:00"}, ...}
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para profesionales
CREATE INDEX idx_profesionales_user_id ON profesionales(user_id);
CREATE INDEX idx_profesionales_matricula ON profesionales(matricula_profesional);
CREATE INDEX idx_profesionales_activo ON profesionales(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.6 TABLA: consultorios (Salas de atención)
-- ----------------------------------------------------------------------------
CREATE TABLE consultorios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    numero VARCHAR(10) UNIQUE NOT NULL,
    piso VARCHAR(10),
    equipamiento TEXT[],
    capacidad INTEGER DEFAULT 1,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para consultorios
CREATE INDEX idx_consultorios_numero ON consultorios(numero);
CREATE INDEX idx_consultorios_activo ON consultorios(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.7 TABLA: citas (Sistema de reservas)
-- ----------------------------------------------------------------------------
CREATE TABLE citas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mascota_id UUID NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    tutor_id UUID NOT NULL REFERENCES tutores(id) ON DELETE CASCADE,
    servicio_id UUID NOT NULL REFERENCES servicios(id),
    profesional_id UUID NOT NULL REFERENCES profesionales(id),
    consultorio_id UUID REFERENCES consultorios(id),
    fecha_hora TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_hora_fin TIMESTAMP WITH TIME ZONE,
    estado estado_cita DEFAULT 'reservada',
    motivo_consulta TEXT,
    observaciones TEXT,
    recordatorio_enviado BOOLEAN DEFAULT FALSE,
    confirmada_por UUID REFERENCES users(id),
    fecha_confirmacion TIMESTAMP WITH TIME ZONE,
    check_in_realizado BOOLEAN DEFAULT FALSE,
    hora_check_in TIMESTAMP WITH TIME ZONE,
    hora_inicio_atencion TIMESTAMP WITH TIME ZONE,
    hora_fin_atencion TIMESTAMP WITH TIME ZONE,
    motivo_cancelacion TEXT,
    cita_reprogramada_id UUID REFERENCES citas(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para citas
CREATE INDEX idx_citas_mascota_id ON citas(mascota_id);
CREATE INDEX idx_citas_tutor_id ON citas(tutor_id);
CREATE INDEX idx_citas_servicio_id ON citas(servicio_id);
CREATE INDEX idx_citas_profesional_id ON citas(profesional_id);
CREATE INDEX idx_citas_consultorio_id ON citas(consultorio_id);
CREATE INDEX idx_citas_fecha_hora ON citas(fecha_hora);
CREATE INDEX idx_citas_estado ON citas(estado);
CREATE INDEX idx_citas_fecha_estado ON citas(fecha_hora, estado);

-- ----------------------------------------------------------------------------
-- 3.8 TABLA: historias_clinicas (HCE - Historia Clínica Electrónica)
-- ----------------------------------------------------------------------------
CREATE TABLE historias_clinicas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mascota_id UUID NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    numero_historia VARCHAR(50) UNIQUE NOT NULL,
    fecha_apertura TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    observaciones_generales TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para historias_clinicas
CREATE INDEX idx_historias_mascota_id ON historias_clinicas(mascota_id);
CREATE INDEX idx_historias_numero ON historias_clinicas(numero_historia);

-- ----------------------------------------------------------------------------
-- 3.9 TABLA: episodios (Consultas/Eventos individuales)
-- ----------------------------------------------------------------------------
CREATE TABLE episodios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    historia_clinica_id UUID NOT NULL REFERENCES historias_clinicas(id) ON DELETE CASCADE,
    cita_id UUID REFERENCES citas(id),
    profesional_id UUID NOT NULL REFERENCES profesionales(id),
    fecha_episodio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tipo_episodio tipo_servicio NOT NULL,
    motivo_consulta TEXT NOT NULL,
    anamnesis TEXT, -- Historia del problema actual
    examen_fisico TEXT,
    temperatura_celsius DECIMAL(4,2),
    frecuencia_cardiaca INTEGER,
    frecuencia_respiratoria INTEGER,
    peso_kg DECIMAL(6,2),
    diagnostico TEXT,
    plan_tratamiento TEXT,
    indicaciones_tutor TEXT,
    proxima_visita DATE,
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para episodios
CREATE INDEX idx_episodios_historia_id ON episodios(historia_clinica_id);
CREATE INDEX idx_episodios_cita_id ON episodios(cita_id);
CREATE INDEX idx_episodios_profesional_id ON episodios(profesional_id);
CREATE INDEX idx_episodios_fecha ON episodios(fecha_episodio);
CREATE INDEX idx_episodios_tipo ON episodios(tipo_episodio);

-- ----------------------------------------------------------------------------
-- 3.10 TABLA: adjuntos (Archivos, imágenes, documentos)
-- ----------------------------------------------------------------------------
CREATE TABLE adjuntos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    episodio_id UUID REFERENCES episodios(id) ON DELETE CASCADE,
    mascota_id UUID REFERENCES mascotas(id) ON DELETE CASCADE,
    tipo_adjunto VARCHAR(50) NOT NULL, -- imagen, documento, radiografia, laboratorio, etc.
    nombre_archivo VARCHAR(255) NOT NULL,
    url_archivo TEXT NOT NULL, -- URL de Supabase Storage
    tamano_bytes BIGINT,
    mime_type VARCHAR(100),
    descripcion TEXT,
    subido_por UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para adjuntos
CREATE INDEX idx_adjuntos_episodio_id ON adjuntos(episodio_id);
CREATE INDEX idx_adjuntos_mascota_id ON adjuntos(mascota_id);
CREATE INDEX idx_adjuntos_tipo ON adjuntos(tipo_adjunto);

-- ----------------------------------------------------------------------------
-- 3.11 TABLA: farmacos (Catálogo de medicamentos)
-- ----------------------------------------------------------------------------
CREATE TABLE farmacos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre_comercial VARCHAR(255) NOT NULL,
    nombre_generico VARCHAR(255) NOT NULL,
    laboratorio VARCHAR(255),
    principio_activo TEXT NOT NULL,
    concentracion VARCHAR(100),
    forma_farmaceutica VARCHAR(100), -- comprimido, jarabe, inyectable, etc.
    unidad_medida VARCHAR(50), -- mg, ml, unidad, etc.
    via_administracion TEXT[], -- oral, intravenosa, subcutánea, etc.
    indicaciones TEXT,
    contraindicaciones TEXT,
    efectos_secundarios TEXT,
    dosis_recomendada TEXT,
    requiere_receta BOOLEAN DEFAULT TRUE,
    stock_minimo INTEGER DEFAULT 10,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices para farmacos
CREATE INDEX idx_farmacos_nombre_comercial ON farmacos(nombre_comercial);
CREATE INDEX idx_farmacos_nombre_generico ON farmacos(nombre_generico);
CREATE INDEX idx_farmacos_activo ON farmacos(activo) WHERE deleted_at IS NULL;

-- ----------------------------------------------------------------------------
-- 3.12 TABLA: lotes_farmacos (Control de stock y vencimientos)
-- ----------------------------------------------------------------------------
CREATE TABLE lotes_farmacos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmaco_id UUID NOT NULL REFERENCES farmacos(id) ON DELETE CASCADE,
    numero_lote VARCHAR(100) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cantidad_inicial INTEGER NOT NULL,
    cantidad_actual INTEGER NOT NULL,
    precio_compra DECIMAL(10,2),
    precio_venta DECIMAL(10,2),
    proveedor VARCHAR(255),
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    ubicacion_almacen VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT cantidad_positiva CHECK (cantidad_actual >= 0),
    CONSTRAINT cantidad_coherente CHECK (cantidad_actual <= cantidad_inicial)
);

-- Índices para lotes_farmacos
CREATE INDEX idx_lotes_farmaco_id ON lotes_farmacos(farmaco_id);
CREATE INDEX idx_lotes_numero_lote ON lotes_farmacos(numero_lote);
CREATE INDEX idx_lotes_fecha_vencimiento ON lotes_farmacos(fecha_vencimiento);
CREATE INDEX idx_lotes_activo ON lotes_farmacos(activo) WHERE deleted_at IS NULL;
CREATE INDEX idx_lotes_vencidos ON lotes_farmacos(fecha_vencimiento) WHERE fecha_vencimiento < CURRENT_DATE;
CREATE INDEX idx_lotes_por_vencer ON lotes_farmacos(fecha_vencimiento) WHERE fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days';

-- ----------------------------------------------------------------------------
-- 3.13 TABLA: inventario_movimientos (Trazabilidad de entradas/salidas)
-- ----------------------------------------------------------------------------
CREATE TABLE inventario_movimientos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lote_farmaco_id UUID NOT NULL REFERENCES lotes_farmacos(id) ON DELETE CASCADE,
    tipo_movimiento tipo_movimiento_inventario NOT NULL,
    cantidad INTEGER NOT NULL,
    cantidad_anterior INTEGER NOT NULL,
    cantidad_posterior INTEGER NOT NULL,
    motivo TEXT,
    documento_referencia VARCHAR(100), -- factura, orden, etc.
    realizado_por UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para inventario_movimientos
CREATE INDEX idx_inventario_lote_id ON inventario_movimientos(lote_farmaco_id);
CREATE INDEX idx_inventario_tipo ON inventario_movimientos(tipo_movimiento);
CREATE INDEX idx_inventario_fecha ON inventario_movimientos(created_at);
CREATE INDEX idx_inventario_usuario ON inventario_movimientos(realizado_por);

-- ----------------------------------------------------------------------------
-- 3.14 TABLA: consumos_farmacos (Prescripciones por episodio)
-- ----------------------------------------------------------------------------
CREATE TABLE consumos_farmacos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    episodio_id UUID NOT NULL REFERENCES episodios(id) ON DELETE CASCADE,
    mascota_id UUID NOT NULL REFERENCES mascotas(id) ON DELETE CASCADE,
    farmaco_id UUID NOT NULL REFERENCES farmacos(id),
    lote_farmaco_id UUID REFERENCES lotes_farmacos(id),
    cantidad DECIMAL(10,2) NOT NULL,
    unidad VARCHAR(50) NOT NULL,
    dosis_indicada TEXT NOT NULL,
    frecuencia TEXT NOT NULL, -- cada 8 horas, dos veces al día, etc.
    duracion_dias INTEGER,
    via_administracion VARCHAR(100) NOT NULL,
    indicaciones_especiales TEXT,
    prescrito_por UUID NOT NULL REFERENCES profesionales(id),
    fecha_prescripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    descontado_inventario BOOLEAN DEFAULT FALSE,
    fecha_descuento TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para consumos_farmacos
CREATE INDEX idx_consumos_episodio_id ON consumos_farmacos(episodio_id);
CREATE INDEX idx_consumos_mascota_id ON consumos_farmacos(mascota_id);
CREATE INDEX idx_consumos_farmaco_id ON consumos_farmacos(farmaco_id);
CREATE INDEX idx_consumos_lote_id ON consumos_farmacos(lote_farmaco_id);
CREATE INDEX idx_consumos_prescrito_por ON consumos_farmacos(prescrito_por);
CREATE INDEX idx_consumos_fecha ON consumos_farmacos(fecha_prescripcion);
CREATE INDEX idx_consumos_descontado ON consumos_farmacos(descontado_inventario);

-- ----------------------------------------------------------------------------
-- 3.15 TABLA: auditoria (Registro de acciones importantes)
-- ----------------------------------------------------------------------------
CREATE TABLE auditoria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tabla VARCHAR(100) NOT NULL,
    registro_id UUID NOT NULL,
    accion VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE, APPROVE, etc.
    usuario_id UUID REFERENCES users(id),
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    direccion_ip INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para auditoria
CREATE INDEX idx_auditoria_tabla ON auditoria(tabla);
CREATE INDEX idx_auditoria_registro_id ON auditoria(registro_id);
CREATE INDEX idx_auditoria_usuario_id ON auditoria(usuario_id);
CREATE INDEX idx_auditoria_fecha ON auditoria(created_at);
CREATE INDEX idx_auditoria_accion ON auditoria(accion);

-- ============================================================================
-- 4. FUNCIONES ALMACENADAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4.1 FUNCIÓN: Actualizar timestamp updated_at automáticamente
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.2 FUNCIÓN: Registrar en auditoría automáticamente
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION registrar_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    registro_id UUID;
    datos_anteriores JSONB;
    datos_nuevos JSONB;
BEGIN
    -- Determinar el ID del registro
    IF TG_OP = 'DELETE' THEN
        registro_id := OLD.id;
        datos_anteriores := row_to_json(OLD)::JSONB;
        datos_nuevos := NULL;
    ELSE
        registro_id := NEW.id;
        datos_anteriores := CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD)::JSONB ELSE NULL END;
        datos_nuevos := row_to_json(NEW)::JSONB;
    END IF;

    -- Insertar en auditoría
    INSERT INTO auditoria (tabla, registro_id, accion, usuario_id, datos_anteriores, datos_nuevos)
    VALUES (
        TG_TABLE_NAME,
        registro_id,
        TG_OP,
        auth.uid(), -- ID de usuario actual de Supabase Auth
        datos_anteriores,
        datos_nuevos
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 4.3 FUNCIÓN: Descontar automáticamente del inventario
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION descontar_inventario_automatico()
RETURNS TRIGGER AS $$
DECLARE
    lote_seleccionado UUID;
    cantidad_disponible INTEGER;
BEGIN
    -- Solo proceder si no se ha descontado aún
    IF NEW.descontado_inventario = FALSE AND NEW.lote_farmaco_id IS NOT NULL THEN
        -- Verificar cantidad disponible en el lote
        SELECT cantidad_actual INTO cantidad_disponible
        FROM lotes_farmacos
        WHERE id = NEW.lote_farmaco_id;

        IF cantidad_disponible >= NEW.cantidad THEN
            -- Descontar del lote
            UPDATE lotes_farmacos
            SET cantidad_actual = cantidad_actual - NEW.cantidad,
                updated_at = NOW()
            WHERE id = NEW.lote_farmaco_id;

            -- Registrar movimiento
            INSERT INTO inventario_movimientos (
                lote_farmaco_id,
                tipo_movimiento,
                cantidad,
                cantidad_anterior,
                cantidad_posterior,
                motivo,
                realizado_por
            ) VALUES (
                NEW.lote_farmaco_id,
                'consumo',
                NEW.cantidad,
                cantidad_disponible,
                cantidad_disponible - NEW.cantidad,
                'Consumo en episodio ' || NEW.episodio_id,
                auth.uid()
            );

            -- Marcar como descontado
            NEW.descontado_inventario := TRUE;
            NEW.fecha_descuento := NOW();
        ELSE
            RAISE EXCEPTION 'Stock insuficiente en lote. Disponible: %, Requerido: %', cantidad_disponible, NEW.cantidad;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.4 FUNCIÓN: Generar número de historia clínica automático
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generar_numero_historia()
RETURNS TRIGGER AS $$
DECLARE
    contador INTEGER;
    anio VARCHAR(4);
BEGIN
    IF NEW.numero_historia IS NULL OR NEW.numero_historia = '' THEN
        anio := EXTRACT(YEAR FROM NOW())::VARCHAR;

        -- Contar historias del año actual
        SELECT COUNT(*) + 1 INTO contador
        FROM historias_clinicas
        WHERE EXTRACT(YEAR FROM fecha_apertura) = EXTRACT(YEAR FROM NOW());

        -- Formato: HC-YYYY-NNNN (ejemplo: HC-2025-0001)
        NEW.numero_historia := 'HC-' || anio || '-' || LPAD(contador::TEXT, 4, '0');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.5 FUNCIÓN: Notificar nuevas mascotas registradas (para administración)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION notificar_nueva_mascota()
RETURNS TRIGGER AS $$
BEGIN
    -- Esta función puede integrarse con pg_notify o sistemas externos
    -- Por ahora, solo registra en auditoría
    IF NEW.estado = 'pendiente' THEN
        PERFORM pg_notify(
            'nueva_mascota',
            json_build_object(
                'mascota_id', NEW.id,
                'tutor_id', NEW.tutor_id,
                'nombre', NEW.nombre,
                'especie', NEW.especie,
                'fecha_registro', NEW.created_at
            )::text
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.6 FUNCIÓN: Calcular stock total de un fármaco
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calcular_stock_total_farmaco(farmaco_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN
    SELECT COALESCE(SUM(cantidad_actual), 0) INTO total
    FROM lotes_farmacos
    WHERE farmaco_id = farmaco_uuid
      AND activo = TRUE
      AND deleted_at IS NULL
      AND fecha_vencimiento > CURRENT_DATE;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.7 FUNCIÓN: Obtener próximas citas de una mascota
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION obtener_proximas_citas_mascota(mascota_uuid UUID, limite INTEGER DEFAULT 5)
RETURNS TABLE (
    cita_id UUID,
    fecha_hora TIMESTAMP WITH TIME ZONE,
    servicio_nombre VARCHAR,
    profesional_nombre VARCHAR,
    estado estado_cita
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.fecha_hora,
        s.nombre,
        u.nombre_completo,
        c.estado
    FROM citas c
    INNER JOIN servicios s ON c.servicio_id = s.id
    INNER JOIN profesionales p ON c.profesional_id = p.id
    INNER JOIN users u ON p.user_id = u.id
    WHERE c.mascota_id = mascota_uuid
      AND c.fecha_hora >= NOW()
      AND c.estado NOT IN ('cancelada')
      AND c.deleted_at IS NULL
    ORDER BY c.fecha_hora ASC
    LIMIT limite;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- 4.8 FUNCIÓN: Validar disponibilidad de cita
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION validar_disponibilidad_cita(
    profesional_uuid UUID,
    fecha_hora_inicio TIMESTAMP WITH TIME ZONE,
    duracion_minutos INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    citas_conflictivas INTEGER;
    fecha_hora_final TIMESTAMP WITH TIME ZONE;
BEGIN
    fecha_hora_final := fecha_hora_inicio + (duracion_minutos || ' minutes')::INTERVAL;

    SELECT COUNT(*) INTO citas_conflictivas
    FROM citas
    WHERE profesional_id = profesional_uuid
      AND estado NOT IN ('cancelada', 'reprogramada')
      AND deleted_at IS NULL
      AND (
          (fecha_hora >= fecha_hora_inicio AND fecha_hora < fecha_hora_final)
          OR
          (fecha_hora_fin > fecha_hora_inicio AND fecha_hora_fin <= fecha_hora_final)
          OR
          (fecha_hora <= fecha_hora_inicio AND fecha_hora_fin >= fecha_hora_final)
      );

    RETURN citas_conflictivas = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. TRIGGERS
-- ============================================================================

-- Triggers para updated_at automático
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_tutores_updated_at BEFORE UPDATE ON tutores FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_mascotas_updated_at BEFORE UPDATE ON mascotas FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_servicios_updated_at BEFORE UPDATE ON servicios FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_profesionales_updated_at BEFORE UPDATE ON profesionales FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_consultorios_updated_at BEFORE UPDATE ON consultorios FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_citas_updated_at BEFORE UPDATE ON citas FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_historias_updated_at BEFORE UPDATE ON historias_clinicas FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_episodios_updated_at BEFORE UPDATE ON episodios FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_farmacos_updated_at BEFORE UPDATE ON farmacos FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_lotes_updated_at BEFORE UPDATE ON lotes_farmacos FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();
CREATE TRIGGER trigger_consumos_updated_at BEFORE UPDATE ON consumos_farmacos FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();

-- Triggers para auditoría automática (tablas críticas)
CREATE TRIGGER trigger_audit_users AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
CREATE TRIGGER trigger_audit_mascotas AFTER INSERT OR UPDATE OR DELETE ON mascotas FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
CREATE TRIGGER trigger_audit_citas AFTER INSERT OR UPDATE OR DELETE ON citas FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
CREATE TRIGGER trigger_audit_episodios AFTER INSERT OR UPDATE OR DELETE ON episodios FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
CREATE TRIGGER trigger_audit_consumos AFTER INSERT OR UPDATE OR DELETE ON consumos_farmacos FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();
CREATE TRIGGER trigger_audit_inventario AFTER INSERT OR UPDATE OR DELETE ON inventario_movimientos FOR EACH ROW EXECUTE FUNCTION registrar_auditoria();

-- Trigger para descuento automático de inventario
CREATE TRIGGER trigger_descontar_inventario BEFORE INSERT OR UPDATE ON consumos_farmacos FOR EACH ROW EXECUTE FUNCTION descontar_inventario_automatico();

-- Trigger para generar número de historia clínica
CREATE TRIGGER trigger_generar_numero_historia BEFORE INSERT ON historias_clinicas FOR EACH ROW EXECUTE FUNCTION generar_numero_historia();

-- Trigger para notificar nuevas mascotas
CREATE TRIGGER trigger_notificar_nueva_mascota AFTER INSERT ON mascotas FOR EACH ROW EXECUTE FUNCTION notificar_nueva_mascota();

-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutores ENABLE ROW LEVEL SECURITY;
ALTER TABLE mascotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicios ENABLE ROW LEVEL SECURITY;
ALTER TABLE profesionales ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE citas ENABLE ROW LEVEL SECURITY;
ALTER TABLE historias_clinicas ENABLE ROW LEVEL SECURITY;
ALTER TABLE episodios ENABLE ROW LEVEL SECURITY;
ALTER TABLE adjuntos ENABLE ROW LEVEL SECURITY;
ALTER TABLE farmacos ENABLE ROW LEVEL SECURITY;
ALTER TABLE lotes_farmacos ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario_movimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumos_farmacos ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 6.1 POLICIES para USERS
-- ----------------------------------------------------------------------------

-- Admin: acceso total
CREATE POLICY "Admin acceso total a users" ON users
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Usuarios ven su propio perfil
CREATE POLICY "Usuarios ven su perfil" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Usuarios actualizan su propio perfil (excepto rol)
CREATE POLICY "Usuarios actualizan su perfil" ON users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id AND
        rol = (SELECT rol FROM users WHERE id = auth.uid()) -- No pueden cambiar su rol
    );

-- ----------------------------------------------------------------------------
-- 6.2 POLICIES para TUTORES
-- ----------------------------------------------------------------------------

-- Admin y recepción: acceso total
CREATE POLICY "Admin y recepción acceso total a tutores" ON tutores
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol IN ('admin', 'recepcion')
        )
    );

-- Tutores ven su propio registro
CREATE POLICY "Tutores ven su registro" ON tutores
    FOR SELECT
    USING (user_id = auth.uid());

-- Tutores actualizan su propio registro
CREATE POLICY "Tutores actualizan su registro" ON tutores
    FOR UPDATE
    USING (user_id = auth.uid());

-- Médicos ven tutores de sus pacientes
CREATE POLICY "Médicos ven tutores de pacientes" ON tutores
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            INNER JOIN citas c ON p.id = c.profesional_id
            INNER JOIN mascotas m ON c.mascota_id = m.id
            WHERE u.id = auth.uid() AND m.tutor_id = tutores.id AND u.rol = 'medico'
        )
    );

-- ----------------------------------------------------------------------------
-- 6.3 POLICIES para MASCOTAS
-- ----------------------------------------------------------------------------

-- Admin y recepción: acceso total
CREATE POLICY "Admin y recepción acceso total a mascotas" ON mascotas
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol IN ('admin', 'recepcion')
        )
    );

-- Tutores ven sus propias mascotas
CREATE POLICY "Tutores ven sus mascotas" ON mascotas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = mascotas.tutor_id
        )
    );

-- Tutores crean sus mascotas
CREATE POLICY "Tutores crean mascotas" ON mascotas
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = tutor_id
        )
    );

-- Tutores actualizan sus mascotas (solo si no están aprobadas aún)
CREATE POLICY "Tutores actualizan sus mascotas" ON mascotas
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = mascotas.tutor_id
        ) AND estado = 'pendiente'
    );

-- Médicos ven mascotas de sus citas
CREATE POLICY "Médicos ven mascotas de sus citas" ON mascotas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            INNER JOIN citas c ON p.id = c.profesional_id
            WHERE u.id = auth.uid() AND c.mascota_id = mascotas.id AND u.rol = 'medico'
        )
    );

-- ----------------------------------------------------------------------------
-- 6.4 POLICIES para CITAS
-- ----------------------------------------------------------------------------

-- Admin y recepción: acceso total
CREATE POLICY "Admin y recepción acceso total a citas" ON citas
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol IN ('admin', 'recepcion')
        )
    );

-- Tutores ven sus propias citas
CREATE POLICY "Tutores ven sus citas" ON citas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = citas.tutor_id
        )
    );

-- Tutores crean sus citas
CREATE POLICY "Tutores crean citas" ON citas
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = tutor_id
        )
    );

-- Tutores cancelan sus citas (solo si no están atendidas)
CREATE POLICY "Tutores cancelan sus citas" ON citas
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM tutores WHERE user_id = auth.uid() AND id = citas.tutor_id
        ) AND estado NOT IN ('atendida')
    )
    WITH CHECK (estado = 'cancelada');

-- Médicos ven sus citas asignadas
CREATE POLICY "Médicos ven sus citas" ON citas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            WHERE u.id = auth.uid() AND p.id = citas.profesional_id AND u.rol = 'medico'
        )
    );

-- Médicos actualizan estado de sus citas
CREATE POLICY "Médicos actualizan sus citas" ON citas
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            WHERE u.id = auth.uid() AND p.id = citas.profesional_id AND u.rol = 'medico'
        )
    );

-- ----------------------------------------------------------------------------
-- 6.5 POLICIES para HISTORIAS CLÍNICAS y EPISODIOS
-- ----------------------------------------------------------------------------

-- Admin: acceso total
CREATE POLICY "Admin acceso total a historias" ON historias_clinicas
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Tutores ven historias de sus mascotas
CREATE POLICY "Tutores ven historias de sus mascotas" ON historias_clinicas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM mascotas m
            INNER JOIN tutores t ON m.tutor_id = t.id
            WHERE t.user_id = auth.uid() AND m.id = historias_clinicas.mascota_id
        )
    );

-- Médicos ven y gestionan historias de sus pacientes
CREATE POLICY "Médicos acceso a historias de sus pacientes" ON historias_clinicas
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            INNER JOIN citas c ON p.id = c.profesional_id
            WHERE u.id = auth.uid() AND c.mascota_id = historias_clinicas.mascota_id AND u.rol = 'medico'
        )
    );

-- EPISODIOS - Similar a historias
CREATE POLICY "Admin acceso total a episodios" ON episodios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

CREATE POLICY "Tutores ven episodios de sus mascotas" ON episodios
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM historias_clinicas hc
            INNER JOIN mascotas m ON hc.mascota_id = m.id
            INNER JOIN tutores t ON m.tutor_id = t.id
            WHERE t.user_id = auth.uid() AND hc.id = episodios.historia_clinica_id
        )
    );

CREATE POLICY "Médicos gestionan sus episodios" ON episodios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            WHERE u.id = auth.uid() AND p.id = episodios.profesional_id AND u.rol = 'medico'
        )
    );

-- ----------------------------------------------------------------------------
-- 6.6 POLICIES para INVENTARIO (Admin y Médicos)
-- ----------------------------------------------------------------------------

-- Fármacos: lectura para todos los autenticados, escritura solo admin
CREATE POLICY "Autenticados ven fármacos" ON farmacos
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Solo admin gestiona fármacos" ON farmacos
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Lotes: similar a fármacos
CREATE POLICY "Autenticados ven lotes" ON lotes_farmacos
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Solo admin gestiona lotes" ON lotes_farmacos
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Consumos: médicos crean, admin ve todo
CREATE POLICY "Médicos crean consumos" ON consumos_farmacos
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            WHERE u.id = auth.uid() AND p.id = consumos_farmacos.prescrito_por AND u.rol = 'medico'
        )
    );

CREATE POLICY "Admin ve todos los consumos" ON consumos_farmacos
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol IN ('admin', 'medico')
        )
    );

CREATE POLICY "Tutores ven consumos de sus mascotas" ON consumos_farmacos
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM mascotas m
            INNER JOIN tutores t ON m.tutor_id = t.id
            WHERE t.user_id = auth.uid() AND m.id = consumos_farmacos.mascota_id
        )
    );

-- ----------------------------------------------------------------------------
-- 6.7 POLICIES para AUDITORÍA (Solo Admin)
-- ----------------------------------------------------------------------------

CREATE POLICY "Solo admin ve auditoría" ON auditoria
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- ----------------------------------------------------------------------------
-- 6.8 POLICIES para SERVICIOS, PROFESIONALES, CONSULTORIOS
-- ----------------------------------------------------------------------------

-- Todos los autenticados pueden ver servicios
CREATE POLICY "Autenticados ven servicios" ON servicios
    FOR SELECT
    USING (auth.uid() IS NOT NULL AND activo = TRUE);

CREATE POLICY "Solo admin gestiona servicios" ON servicios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Todos los autenticados pueden ver profesionales activos
CREATE POLICY "Autenticados ven profesionales" ON profesionales
    FOR SELECT
    USING (auth.uid() IS NOT NULL AND activo = TRUE);

CREATE POLICY "Solo admin gestiona profesionales" ON profesionales
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Consultorios: lectura para todos, escritura solo admin y recepción
CREATE POLICY "Autenticados ven consultorios" ON consultorios
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admin y recepción gestionan consultorios" ON consultorios
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol IN ('admin', 'recepcion')
        )
    );

-- ----------------------------------------------------------------------------
-- 6.9 POLICIES para ADJUNTOS
-- ----------------------------------------------------------------------------

CREATE POLICY "Admin acceso total a adjuntos" ON adjuntos
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND rol = 'admin'
        )
    );

CREATE POLICY "Tutores ven adjuntos de sus mascotas" ON adjuntos
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM mascotas m
            INNER JOIN tutores t ON m.tutor_id = t.id
            WHERE t.user_id = auth.uid() AND m.id = adjuntos.mascota_id
        )
    );

CREATE POLICY "Médicos gestionan adjuntos de sus episodios" ON adjuntos
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users u
            INNER JOIN profesionales p ON u.id = p.user_id
            INNER JOIN episodios e ON p.id = e.profesional_id
            WHERE u.id = auth.uid() AND e.id = adjuntos.episodio_id AND u.rol = 'medico'
        )
    );

-- ============================================================================
-- 7. COMENTARIOS EN TABLAS Y COLUMNAS (Documentación)
-- ============================================================================

COMMENT ON TABLE users IS 'Usuarios del sistema integrados con Supabase Auth';
COMMENT ON TABLE tutores IS 'Dueños/responsables de mascotas';
COMMENT ON TABLE mascotas IS 'Pacientes veterinarios con aprobación administrativa';
COMMENT ON TABLE citas IS 'Sistema de reservas y gestión de citas';
COMMENT ON TABLE historias_clinicas IS 'Historia clínica electrónica por mascota';
COMMENT ON TABLE episodios IS 'Consultas/eventos individuales dentro de una historia clínica';
COMMENT ON TABLE farmacos IS 'Catálogo maestro de medicamentos veterinarios';
COMMENT ON TABLE lotes_farmacos IS 'Control de stock, lotes y vencimientos de fármacos';
COMMENT ON TABLE consumos_farmacos IS 'Prescripciones y consumos de medicamentos por episodio';
COMMENT ON TABLE inventario_movimientos IS 'Trazabilidad completa de movimientos de inventario';
COMMENT ON TABLE auditoria IS 'Registro de auditoría de todas las acciones críticas del sistema';

COMMENT ON COLUMN mascotas.estado IS 'pendiente: aguarda aprobación, aprobado: puede recibir atención, rechazado: requiere correcciones';
COMMENT ON COLUMN citas.estado IS 'Flujo: reservada -> confirmada -> en_sala -> atendida (o cancelada/reprogramada)';
COMMENT ON COLUMN consumos_farmacos.descontado_inventario IS 'TRUE cuando se ha descontado automáticamente del inventario';

-- ============================================================================
-- FIN DEL ESQUEMA
-- ============================================================================

-- Para ejecutar este esquema:
-- 1. Copia todo este contenido
-- 2. Ve a Supabase Dashboard > SQL Editor
-- 3. Pega y ejecuta (puede tomar algunos segundos)
-- 4. Verifica que todas las tablas, funciones y políticas se crearon correctamente
