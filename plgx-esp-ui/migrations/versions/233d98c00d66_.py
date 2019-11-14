"""empty message

Revision ID: 233d98c00d66
Revises: 5706960fcdb4
Create Date: 2019-01-09 03:06:20.981878

"""

# revision identifiers, used by Alembic.
revision = '233d98c00d66'
down_revision = '5706960fcdb4'

from alembic import op
import sqlalchemy as sa
import polylogyx.database
from sqlalchemy.dialects import postgresql

def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###

    op.add_column('carve_session', sa.Column('blocks_received', postgresql.JSONB(), nullable=True))

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###

    op.drop_column('carve_session', 'blocks_received')

    # ### end Alembic commands ###
