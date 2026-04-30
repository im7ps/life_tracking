from sqlalchemy.exc import IntegrityError
import uuid

from app.core.exceptions import EntityAlreadyExists
from app.core.security import get_password_hash
from app.models.user import User
from app.repositories.user_repo import UserRepo
from app.schemas.user import UserCreate, UserUpdate, UserUpdateDB


from sqlalchemy.ext.asyncio import AsyncSession

class UserService:
    def __init__(self, session: AsyncSession, user_repo: UserRepo):
        self.session = session
        self.user_repo = user_repo

    async def update_user(self, user: User, user_in: UserUpdate) -> User:
        """
        Updates the user's profile.
        Handles password hashing if password is updated.
        """
        # --- DTO TRANSFORMATION (Mapping) ---
        # Convertiamo il DTO di Input (UserUpdate) in un dizionario temporaneo
        # per manipolare i dati prima della persistenza.
        update_data = user_in.model_dump(exclude_unset=True)
        
        hashed_password = None
        if "password" in update_data and update_data["password"]:
            # SECURITY: Intercettiamo la password in chiaro.
            # La hashiamo immediatamente e la rimuoviamo dal set di dati
            # per evitare che giri in chiaro all'interno dell'applicazione.
            import asyncio
            loop = asyncio.get_running_loop()
            hashed_password = await loop.run_in_executor(None, get_password_hash, update_data["password"])
            del update_data["password"]
        
        # Creiamo il DTO Interno (UserUpdateDB).
        # Questo passaggio "sigilla" la trasformazione: da qui in poi,
        # il sistema lavora solo con dati sicuri e tipizzati (hashed_password).
        user_update_db = UserUpdateDB(**update_data)
        if hashed_password:
            user_update_db.hashed_password = hashed_password

        # Delegate to repository using the typed schema
        updated_user = await self.user_repo.update(user, user_update_db)
        await self.session.commit()
        await self.session.refresh(updated_user)
        return updated_user

    async def create_user(self, user_create: UserCreate) -> User:
        """
        Main service to create a user, handling business logic for validation and creation.
        Includes a race-condition check using DB integrity constraints.
        """
        # 1. Pre-check (Optimization to avoid DB exceptions for common cases)
        existing_user = await self.user_repo.get_by_username(user_create.username)
        if existing_user:
            raise EntityAlreadyExists("Username already registered")
            
        existing_email = await self.user_repo.get_by_email(user_create.email)
        if existing_email:
            raise EntityAlreadyExists("Email already registered")

        # 2. Hash the password
        import asyncio
        loop = asyncio.get_running_loop()
        hashed_password = await loop.run_in_executor(None, get_password_hash, user_create.password)

        # 3. Create the User model instance
        user_model = User(
            username=user_create.username,
            email=user_create.email,
            hashed_password=hashed_password,
        )

        # 4. Pass the prepared model to the repository with race-condition handling
        try:
            created_user = await self.user_repo.create(user_model)
            await self.session.commit()
            return created_user
        except IntegrityError:
            await self.session.rollback()
            # This catches cases where a duplicate was inserted between the pre-check and the commit
            raise EntityAlreadyExists("User with this email or username already exists")
        except Exception:
            await self.session.rollback()
            raise

    async def get_user_by_username(self, username: str) -> User | None:
        """
        Service to retrieve a user by username.
        """
        return await self.user_repo.get_by_username(username)

    async def get_user_by_id(self, user_id: uuid.UUID) -> User | None:
        """
        Service to retrieve a user by ID.
        """
        # Assumes the repository has a generic 'get' method accepting an ID
        return await self.user_repo.get(user_id)
