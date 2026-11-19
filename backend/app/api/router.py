from fastapi import APIRouter

from app.api.routes import health, calificaciones

api_router = APIRouter()

api_router.include_router(health.router)
api_router.include_router(calificaciones.router)