
from fastapi import FastAPI

from app.api.router import api_router
from app.api.routes import health

app = FastAPI(
    title="Mantenedor de Calificaciones Tributarias",
    description="API para la gestion de calificaciones tributarias de nuam.",
    version="1.0.0"
)

# Rutas generales
app.include_router(health.router)

# Rutas principales de la API
app.include_router(api_router, prefix="/api/v1")
