
from enum import Enum


class TipoCertificado(str, Enum):
    CERT_70 = "CERT_70"
    CERT_44 = "CERT_44"


class OrigenDatos(str, Enum):
    CARGA_MASIVA_CSV = "CARGA_MASIVA_CSV"
    INGRESO_MANUAL = "INGRESO_MANUAL"
    API_REST = "API_REST"


class EstadoCalificacion(str, Enum):
    BORRADOR = "BORRADOR"
    ACTIVA = "ACTIVA"
    OBSOLETA = "OBSOLETA"
    ANULADA = "ANULADA"
