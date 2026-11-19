from fastapi import APIRouter

router = APIRouter(
    prefix="/calificaciones",
    tags=["Calificaciones tributarias"]
)


@router.get("/")
def listar_calificaciones():
    return {
        "message": "Modulo de calificaciones tributarias",
        "status": "available"
    }