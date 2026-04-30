from pydantic import BaseModel, Field
from typing import Optional, List

class UserOnboardingData(BaseModel):
    """Informazioni raccolte durante il primo incontro con l'utente."""

    display_name: str | None = Field(
    default=None, 
    description="Il nome o nickname con cui l'utente vuole essere chiamato."
    )
    main_focus: str | None = Field(
    default=None, 
    description="L'attività principale a cui l'utente vuole dedicarsi."
    )
    success_definition: str | None = Field(
    default=None, 
    description="Cosa significa per l'utente aver completato con successo il main focus."
    )
    wants_tutorial: bool | None = Field(
    default=None, 
    description="Se l'utente desidera ricevere spiegazioni sull'app invece di aggiungere altre task."
    )

    @property
    def is_complete(self) -> bool:
        """Verifica se abbiamo tutte le info per chiudere l'onboarding."""
        return all([self.display_name, self.main_focus, self.success_definition])