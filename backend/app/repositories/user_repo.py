from typing import Optional
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.models.user import User
from app.schemas.user import UserUpdateDB


class UserRepo:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.model = User

    async def create(self, user_model: User) -> User:
        """
        Creates a user record in the database from a User model.
        Password must already be hashed.
        """
        self.session.add(user_model)
        await self.session.flush()
        await self.session.refresh(user_model)
        return user_model

    async def get_by_username(self, username: str) -> User | None:
        """
        Retrieves a user by their username, case-insensitively.
        """
        statement = select(self.model).where(self.model.username.ilike(username))
        result = await self.session.execute(statement)
        return result.scalars().first()
    
    async def get_by_email(self, email: str) -> User | None:
        """
        Retrieves a user by their email, case-insensitively.
        """
        statement = select(self.model).where(self.model.email.ilike(email))
        result = await self.session.execute(statement)
        return result.scalars().first()

    # --- Metodi Aggiunti manualmente (Decoupling da BaseRepo) ---

    async def get(self, id: uuid.UUID) -> Optional[User]:
        """Recupera un utente per ID."""
        statement = select(self.model).where(self.model.id == id)
        result = await self.session.execute(statement)
        return result.scalars().first()

    async def update(self, db_user: User, user_update: UserUpdateDB) -> User:
        """Aggiorna i dati dell'utente."""
        update_data = user_update.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_user, key, value)
        
        self.session.add(db_user)
        await self.session.flush()
        await self.session.refresh(db_user)
        return db_user

    async def delete(self, db_user: User) -> None:
        """Elimina l'utente."""
        await self.session.delete(db_user)
        await self.session.flush()
