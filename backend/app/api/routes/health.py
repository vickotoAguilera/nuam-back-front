from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def root():
    return {
        "message": "API del Mantenedor de Calificaciones Tributarias",
        "status": "online"
    }


@router.get("/health")
def health_check():
    return {
        "status": "healthy"
    }