
from fastapi import APIRouter, UploadFile, File

router = APIRouter(
    prefix="/cargas-masivas",
    tags=["Cargas masivas"]
)


@router.post("/")
async def cargar_archivo(archivo: UploadFile = File(...)):
    return {
        "message": "Procesar carga masiva",
        "filename": archivo.filename,
        "status": "available"
    }


@router.get("/")
def listar_cargas():
    return {
        "message": "Listar cargas masivas",
        "status": "available"
    }


@router.get("/{id}")
def buscar_carga(id: str):
    return {
        "message": "Consultar carga masiva",
        "id": id,
        "status": "available"
    }


@router.get("/{id}/errores")
def consultar_errores(id: str):
    return {
        "message": "Consultar errores de carga",
        "id": id,
        "status": "available"
    }
