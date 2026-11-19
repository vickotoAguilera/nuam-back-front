from fastapi import FastAPI

from app.api.router import api_router

app = FastAPI(
    title="Mantenedor de Calificaciones Tributarias",
    description="API para la gestión de calificaciones tributarias de nuam.",
    version="1.0.0"
)

app.include_router(api_router)