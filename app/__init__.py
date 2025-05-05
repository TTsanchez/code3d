from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.config import Config
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect()

db = SQLAlchemy()

app = Flask(__name__)
app.config.from_object(Config)
csrf.init_app(app)
db.init_app(app)

from app import routes, forms, classes_bd
