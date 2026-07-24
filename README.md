# 🛒 AndyStoreDB

AndyStoreDB es un proyecto desarrollado en **Microsoft SQL Server** como parte de la asignatura **Bases de Datos Avanzadas**. El objetivo del proyecto fue diseñar e implementar una base de datos para la administración de una tienda minorista, aplicando conceptos de modelado relacional, optimización de consultas, seguridad y administración de bases de datos.

La base de datos permite gestionar la información de clientes, productos, categorías, marcas, proveedores, empleados, sucursales, inventario, compras y ventas, garantizando la integridad de la información mediante el uso de llaves primarias, llaves foráneas y restricciones de integridad referencial.

## Tecnologías utilizadas

* Microsoft SQL Server
* T-SQL
* SQL Server Management Studio (SSMS)
* Archivos CSV para la carga inicial de datos

## Funcionalidades implementadas

* Diseño de una base de datos relacional normalizada.
* Implementación de relaciones entre tablas mediante llaves foráneas.
* Creación de índices para optimizar el rendimiento de las consultas.
* Desarrollo de vistas para facilitar la consulta de información.
* Implementación de procedimientos almacenados para automatizar procesos de negocio.
* Creación de triggers para controlar cambios en la información y mantener auditorías.
* Registro de auditorías sobre modificaciones de precios, cambios de inventario y eliminación de registros.
* Configuración de usuarios, roles y permisos para controlar el acceso a la base de datos.
* Implementación de estrategias de respaldo (Backups Full, Diferencial y Transaction Log).
* Desarrollo de consultas avanzadas utilizando diferentes tipos de JOIN y funciones de agregación.

## Carga de datos

La información inicial de la base de datos fue importada mediante archivos CSV. Por esta razón, el repositorio incluye tanto el script SQL como los archivos de datos necesarios para reconstruir completamente la base de datos.

## Cómo ejecutar el proyecto

1. Ejecutar el script `AndyStoreDB.sql` en Microsoft SQL Server.
2. Importar los archivos CSV correspondientes a cada tabla.
3. Ejecutar las consultas de prueba incluidas en el script para verificar el correcto funcionamiento de la base de datos.

## Objetivos de aprendizaje

Este proyecto me permitió fortalecer conocimientos en:

* Diseño y modelado de bases de datos relacionales.
* Programación en T-SQL.
* Optimización mediante índices.
* Procedimientos almacenados y vistas.
* Triggers y auditoría de datos.
* Gestión de usuarios, roles y permisos.
* Estrategias de respaldo y recuperación de bases de datos.
* Desarrollo de consultas SQL para el análisis de información.

## Autor

**Andrea Yurany Lara Mancipe**

Proyecto académico desarrollado con fines educativos y como parte de mi portafolio profesional.
