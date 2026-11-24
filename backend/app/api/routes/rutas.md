Módulo	            Responsabilidad
health.py	        Estado de la API
calificaciones.py	CRUD de calificaciones
calculos.py	        Cálculo y validación de factores
cargas_masivas.py	Carga y consulta de archivos CSV
auth.py	            Inicio de sesión y MFA
usuarios.py	        Consulta y administración de usuarios
auditoria.py	    Consulta de registros de auditoría
reportes.py	        Consulta y exportación de reportes



ENDPOINTS
Método	        Endpoint	                    Función
GET	            /calificaciones	                Listar calificaciones
GET	            /calificaciones/{id}	        Buscar por ID
POST	        /calificaciones	                Crear calificación
PUT	            /calificaciones/{id}	        Modificar calificación
DELETE	        /calificaciones/{id}	        Eliminar calificación
POST	        /calculos/factores	            Calcular factores
POST	        /calculos/validar	            Validar factores
POST	        /cargas-masivas	                Cargar CSV
GET	            /cargas-masivas	                Listar cargas
GET	            /cargas-masivas/{id}	        Consultar una carga
GET	            /cargas-masivas/{id}/errores	Consultar errores
POST	        /auth/login	                    Iniciar sesión
POST	        /auth/mfa/verify	            Verificar MFA
GET	            /auth/me	                    Consultar usuario autenticado
GET	            /usuarios	                    Listar usuarios
GET	            /usuarios/{id}	                Consultar usuario
PUT	            /usuarios/{id}/rol	            Modificar rol
GET	            /auditoria	                    Listar registros
GET	            /auditoria/{id}	                Consultar registro
GET	            /reportes/calificaciones	    Reporte de calificaciones
GET	            /reportes/cargas	            Reporte de cargas