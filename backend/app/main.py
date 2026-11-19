from fastapi import FastAPI

app = FastAPI(
    title="Mantenedor de Calificaciones Tributarias",
    description="API para la gestión de calificaciones tributarias de nuam.",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "message": "API del Mantenedor de Calificaciones Tributarias",
        "status": "online"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }