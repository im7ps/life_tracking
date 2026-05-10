from pydantic import BaseModel, Field
from typing import Optional, List

class UserOnboardingData(BaseModel):
    """Informazioni raccolte durante il primo incontro con l'utente."""

    name: str | None = Field(
        default=None, 
        description="Il nome o nickname con cui l'utente vuole essere chiamato."
    )
    main_activity: str | None = Field(
        default=None, 
        description="L'attività principale a cui l'utente vuole dedicarsi."
    )
    timezone: str | None = Field(
        default=None,
        description="Timezone dell'utente, utile per reminder e scheduling."
    )

    @property
    def is_complete(self) -> bool:
        """Verifica se abbiamo tutte le info per chiudere l'onboarding."""
        return len(self.missing_fields) == 0

    @property
    def missing_fields(self) -> List[str]:
        """Restituisce la lista dei campi ancora da raccogliere."""
        missing = []
        if not self.name: missing.append("name")
        if not self.main_activity: missing.append("main_activity")
        if not self.timezone: missing.append("timezone")
        return missing