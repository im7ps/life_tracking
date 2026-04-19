from typing import List, Literal, Union
from pydantic import AnyHttpUrl, field_validator, model_validator, TypeAdapter
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", 
        case_sensitive=True,
        extra='ignore'
    )

    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24

    # Environment Tier: controlla il comportamento di sicurezza
    ENVIRONMENT: Literal["local", "staging", "production"] = "local"

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = True

    # Google & LangChain
    GOOGLE_API_KEY: str | None = None
    LANGCHAIN_TRACING_V2: str = "true"
    LANGCHAIN_API_KEY: str | None = None
    LANGCHAIN_PROJECT: str = "whativedone-chat"

    # Database Settings
    POSTGRES_POOL_SIZE: int = 5  # Default SQLAlchemy
    POSTGRES_MAX_OVERFLOW: int = 10  # Default SQLAlchemy

    # CORS Origins: Validazione stretta degli URL.
    # In produzione DEVE essere popolato e NON deve contenere localhost.
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        """
        Parsa una stringa separata da virgole in una lista, se necessario.
        Utile per ambienti che non supportano array JSON nelle env vars.
        """
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        return v

    @model_validator(mode="after")
    def validate_security_config(self) -> "Settings":
        """
        Applica regole di sicurezza fail-fast basate sull'ambiente.
        """
        # Regole per PRODUZIONE
        if self.ENVIRONMENT == "production":
            if not self.BACKEND_CORS_ORIGINS:
                raise ValueError("BACKEND_CORS_ORIGINS cannot be empty in production.")
            
            for origin in self.BACKEND_CORS_ORIGINS:
                # origin.host restituisce la parte host (es. 'localhost', 'my-site.com')
                if origin.host in ("localhost", "127.0.0.1", "::1"):
                    raise ValueError(f"Localhost origin ({origin}) is not allowed in production.")

        # Regole per LOCAL/DEVELOPMENT
        elif self.ENVIRONMENT == "local":
            # Fallback automatico se non settato
            if not self.BACKEND_CORS_ORIGINS:
                # Usiamo TypeAdapter per validare e convertire le stringhe in AnyHttpUrl
                adapter = TypeAdapter(List[AnyHttpUrl])
                self.BACKEND_CORS_ORIGINS = adapter.validate_python([
                    "http://localhost:3000",
                    "http://localhost:8080"
                ])
        
        return self

settings = Settings()
