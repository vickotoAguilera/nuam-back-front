
from fastapi import APIRouter

from app.api.routes import (
    calificaciones,
    calculos,
    cargas_masivas,
    auth,
    usuarios,
    auditoria,
    reportes
)

api_router = APIRouter()

api_router.include_router(calificaciones.router)
api_router.include_router(calculos.router)
api_router.include_router(cargas_masivas.router)
api_router.include_router(auth.router)
api_router.include_router(usuarios.router)
api_router.include_router(auditoria.router)
api_router.include_router(reportes.router)
