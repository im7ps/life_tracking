"""add timer and scheduling fields to action

Revision ID: 8ff36a3e0197
Revises: 00b42cbf7cd3
Create Date: 2026-03-01 00:27:24.837114

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '8ff36a3e0197'
down_revision: Union[str, Sequence[str], None] = '00b42cbf7cd3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # 1. Aggiungiamo le colonne come nullable per evitare errori NOT NULL
    op.add_column('action', sa.Column('is_running', sa.Boolean(), nullable=True))
    op.add_column('action', sa.Column('last_started_at', sa.DateTime(), nullable=True))
    op.add_column('action', sa.Column('total_seconds', sa.Integer(), nullable=True))
    op.add_column('action', sa.Column('scheduled_date', sa.DateTime(), nullable=True))
    
    # 2. Impostiamo valori di default per le righe esistenti
    op.execute("UPDATE action SET is_running = FALSE WHERE is_running IS NULL")
    op.execute("UPDATE action SET total_seconds = 0 WHERE total_seconds IS NULL")
    
    # 3. Rendiamo le colonne NOT NULL dove richiesto
    op.alter_column('action', 'is_running', nullable=False)
    op.alter_column('action', 'total_seconds', nullable=False)
    
    op.create_index(op.f('ix_action_scheduled_date'), 'action', ['scheduled_date'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f('ix_action_scheduled_date'), table_name='action')
    op.drop_column('action', 'scheduled_date')
    op.drop_column('action', 'total_seconds')
    op.drop_column('action', 'last_started_at')
    op.drop_column('action', 'is_running')
