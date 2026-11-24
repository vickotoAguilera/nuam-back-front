
from fastapi import APIRouter

router = APIRouter(
    prefix="/calculos",
    tags=["Calculos tributarios"]
)


@router.post("/factores")
def calcular_factores():
    return {
        "message": "Calcular factores tributarios",
        "status": "available"
    }


@router.post("/validar")
def validar_factores():
    return {
        "message": "Validar factores tributarios",
        "status": "available"
    }
