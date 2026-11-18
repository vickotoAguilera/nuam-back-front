# nuam

Proyecto integrado de la carrera en INACAP. Este repositorio reúne el código de la aplicación de nuam, organizado en una rama por componente.

## Estructura de ramas

| Rama | Contenido | Quién sube aquí |
|------|-----------|-----------------|
| `main` | Este README. No se modifica por ahora. | Nadie |
| `backend` | API y lógica de servidor | Integrantes de backend |
| `frontend` | Interfaz de usuario | Integrantes de frontend |
| `database` | Modelo, scripts y migraciones de la base de datos | Integrantes de base de datos |

## Cómo trabajar

1. Clonar el repositorio: `git clone https://github.com/vickotoAguilera/nuam-back-front.git`
2. Cambiarse a la rama del componente: `git checkout backend` (o `frontend`, `database`).
3. Subir los cambios solo a la rama propia con `git push origin <rama>`.
4. No hacer commits directos en `main`.

## Convención de commits

Se usa Conventional Commits, por ejemplo `feat: agrega endpoint de login` o `fix: corrige validación de RUT`.

## Seguridad

No subir contraseñas, llaves ni archivos `.env`.
