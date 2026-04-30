from pydantic import BaseModel, Field
from typing import Optional, List

class UserOnboardingData(BaseModel):
    """Informazioni raccolte durante il primo incontro con l'utente."""

    name: str | None = Field(
        default=None, 
        description="Il nome o nickname con cui l'utente vuole essere chiamato."
    )
    identity_vision: str | None = Field(
        default=None,
        description="La visione di sè (es 'Voglio essere più produttivo')."
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
        return all([self.name, self.identity_vision, self.main_activity, self.timezone])