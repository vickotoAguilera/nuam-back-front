
from fastapi import APIRouter

router = APIRouter(
    prefix="/auth",
    tags=["Autenticacion"]
)


@router.post("/login")
def iniciar_sesion():
    return {
        "message": "Iniciar sesion",
        "status": "available"
    }


@router.post("/mfa/verify")
def verificar_mfa():
    return {
        "message": "Verificar segundo factor de autenticacion",
        "status": "available"
    }


@router.get("/me")
def usuario_actual():
    return {
        "message": "Consultar usuario autenticado",
        "status": "available"
    }
