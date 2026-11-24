
from fastapi import APIRouter

router = APIRouter(
    prefix="/usuarios",
    tags=["Usuarios"]
)


@router.get("/")
def listar_usuarios():
    return {
        "message": "Listar usuarios",
        "status": "available"
    }


@router.get("/{id}")
def buscar_usuario(id: str):
    return {
        "message": "Buscar usuario",
        "id": id,
        "status": "available"
    }


@router.put("/{id}/rol")
def modificar_rol(id: str):
    return {
        "message": "Modificar rol de usuario",
        "id": id,
        "status": "available"
    }
