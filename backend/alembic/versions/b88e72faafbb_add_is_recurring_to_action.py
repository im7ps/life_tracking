"""add is_recurring to action

Revision ID: b88e72faafbb
Revises: becc1a2ef125
Create Date: 2026-03-01 00:40:07.727281

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel

# revision identifiers, used by Alembic.
revision: str = 'b88e72faafbb'
down_revision: Union[str, Sequence[str], None] = 'becc1a2ef125'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('action', sa.Column('is_recurring', sa.Boolean(), nullable=True))
    op.execute("UPDATE action SET is_recurring = FALSE WHERE is_recurring IS NULL")
    op.alter_column('action', 'is_recurring', nullable=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('action', 'is_recurring')
