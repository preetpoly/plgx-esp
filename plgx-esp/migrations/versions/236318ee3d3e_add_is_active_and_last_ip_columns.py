"""Add is_active and last_ip columns to node table

Revision ID: 236318ee3d3e
Revises: 54ef3f06612c
Create Date: 2016-06-21 10:48:13.099132

"""

# revision identifiers, used by Alembic.
revision = '236318ee3d3e'
down_revision = '54ef3f06612c'

from alembic import op
import sqlalchemy as sa
import polylogyx.database
from sqlalchemy.dialects import postgresql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.add_column('node', sa.Column('is_active', sa.Boolean(), server_default='1', nullable=False))
    op.add_column('node', sa.Column('last_ip', postgresql.INET(), nullable=True))
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('node', 'last_ip')
    op.drop_column('node', 'is_active')
    ### end Alembic commands ###
