-- Script de inicialización de la base de datos Facultad
-- Este archivo se ejecuta automáticamente cuando Docker inicia MySQL

-- Verificar que la base de datos existe (debería existir por MYSQL_DATABASE)
USE facultad;

-- Crear tabla de alumnos si no existe
CREATE TABLE IF NOT EXISTS alumno (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    fecha_inscripcion DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Crear tabla de asignaturas si no existe
CREATE TABLE IF NOT EXISTS asignatura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    creditos INT,
    descripcion TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Crear tabla de profesores si no existe
CREATE TABLE IF NOT EXISTS profesor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    departamento VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Crear tabla de matrículas si no existe
CREATE TABLE IF NOT EXISTS matricula (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alumno_id INT NOT NULL,
    asignatura_id INT NOT NULL,
    fecha_matricula DATETIME DEFAULT CURRENT_TIMESTAMP,
    calificacion DECIMAL(3,1),
    estado ENUM('activo', 'completado', 'cancelado') DEFAULT 'activo',
    FOREIGN KEY (alumno_id) REFERENCES alumno(id) ON DELETE CASCADE,
    FOREIGN KEY (asignatura_id) REFERENCES asignatura(id) ON DELETE CASCADE,
    UNIQUE KEY unique_matricula (alumno_id, asignatura_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Crear índices para mejoras de rendimiento
CREATE INDEX IF NOT EXISTS idx_alumno_email ON alumno(email);
CREATE INDEX IF NOT EXISTS idx_alumno_matricula ON alumno(matricula);
CREATE INDEX IF NOT EXISTS idx_asignatura_codigo ON asignatura(codigo);
CREATE INDEX IF NOT EXISTS idx_profesor_email ON profesor(email);
CREATE INDEX IF NOT EXISTS idx_matricula_alumno ON matricula(alumno_id);
CREATE INDEX IF NOT EXISTS idx_matricula_asignatura ON matricula(asignatura_id);

-- Insertar datos de prueba (opcional)
INSERT IGNORE INTO alumno (nombre, apellido, email, matricula) VALUES 
('Juan', 'García', 'juan.garcia@facultad.edu', 'ALU001'),
('María', 'López', 'maria.lopez@facultad.edu', 'ALU002'),
('Carlos', 'Martínez', 'carlos.martinez@facultad.edu', 'ALU003');

INSERT IGNORE INTO asignatura (nombre, codigo, creditos, descripcion) VALUES 
('Programación I', 'PROG001', 6, 'Introducción a la programación en Python'),
('Bases de Datos', 'BD001', 6, 'Fundamentos de bases de datos relacionales'),
('Algoritmos', 'ALG001', 6, 'Análisis y diseño de algoritmos');

INSERT IGNORE INTO profesor (nombre, apellido, email, departamento) VALUES 
('Roberto', 'Fernández', 'roberto.fernandez@facultad.edu', 'Informática'),
('Sandra', 'González', 'sandra.gonzalez@facultad.edu', 'Informática');
