
from fastapi import APIRouter

router = APIRouter(
    prefix="/auditoria",
    tags=["Auditoria"]
)


@router.get("/")
def listar_registros():
    return {
        "message": "Listar registros de auditoria",
        "status": "available"
    }


@router.get("/{id}")
def buscar_registro(id: str):
    return {
        "message": "Consultar registro de auditoria",
        "id": id,
        "status": "available"
    }
