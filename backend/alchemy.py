# alchemy.py
# Sets up SqlAlchemy and our database connection

from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SqlAlchemy setup
Base = declarative_base()
Session = sessionmaker()

# initialize db
engine = create_engine('mysql+mysqldb://hackallstar:lumpyspace@mysql.dvanoni.com/thehack')
Session.configure(bind=engine)

