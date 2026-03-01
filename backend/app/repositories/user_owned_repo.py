import uuid
from typing import Type, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.repositories.base_repo import BaseRepo, ModelType, CreateSchemaType, UpdateSchemaType

class UserOwnedRepo(BaseRepo[ModelType, CreateSchemaType, UpdateSchemaType]):
    """
    Repository base per entità che appartengono a un utente specifico.
    Eredita le operazioni base (update, delete, create_batch) da BaseRepo.
    """
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        super().__init__(model, session)

    async def create(self, obj_in: CreateSchemaType, user_id: uuid.UUID) -> ModelType:
        """Crea un record associandolo all'utente specificato."""
        db_obj = self.model(**obj_in.model_dump(), user_id=user_id)
        self.session.add(db_obj)
        await self.session.flush()
        await self.session.refresh(db_obj)
        return db_obj

    async def create_for_user(self, user_id: uuid.UUID, obj_in: CreateSchemaType) -> ModelType:
        """Alias per coerenza con i nomi chiamati nei service."""
        return await self.create(obj_in, user_id)

    async def create_batch_for_user(self, objs_in: List[CreateSchemaType], user_id: uuid.UUID) -> List[ModelType]:
        """Wrapper tipizzato per creare batch per uno specifico utente."""
        return await self.create_batch(objs_in, user_id=user_id)

    async def get_by_id(self, obj_id: uuid.UUID, user_id: uuid.UUID) -> Optional[ModelType]:
        """Recupera un oggetto solo se appartiene all'utente specificato."""
        statement = select(self.model).where(self.model.id == obj_id, self.model.user_id == user_id)
        result = await self.session.execute(statement)
        return result.scalars().first()

    async def get_all_by_user(self, user_id: uuid.UUID) -> List[ModelType]:
        """Recupera tutti gli oggetti di un utente."""
        statement = select(self.model).where(self.model.user_id == user_id)
        result = await self.session.execute(statement)
        return result.scalars().all()
    
    async def update_for_user(self, user_id: uuid.UUID, obj_id: uuid.UUID, obj_in: UpdateSchemaType) -> Optional[ModelType]:
        """Aggiorna un oggetto solo se appartiene all'utente specificato."""
        from sqlalchemy.orm import selectinload
        
        # Carichiamo l'oggetto con le relazioni necessarie
        statement = select(self.model).where(
            self.model.id == obj_id, 
            self.model.user_id == user_id
        )
        if hasattr(self.model, 'dimension'):
            statement = statement.options(selectinload(self.model.dimension))
            
        result = await self.session.execute(statement)
        db_obj = result.scalar_one_or_none()
        
        if not db_obj:
            return None
        return await self.update(db_obj, obj_in)

    async def delete_for_user(self, user_id: uuid.UUID, obj_id: uuid.UUID) -> bool:
        """Cancella un oggetto solo se appartiene all'utente specificato."""
        db_obj = await self.get_by_id(obj_id, user_id)
        if not db_obj:
            return False
        await self.delete(db_obj)
        return True
