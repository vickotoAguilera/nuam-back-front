
from fastapi import APIRouter

router = APIRouter(
    prefix="/reportes",
    tags=["Reportes"]
)


@router.get("/calificaciones")
def reporte_calificaciones():
    return {
        "message": "Generar reporte de calificaciones",
        "status": "available"
    }


@router.get("/cargas")
def reporte_cargas():
    return {
        "message": "Generar reporte de cargas masivas",
        "status": "available"
    }
