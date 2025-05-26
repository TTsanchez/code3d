from datetime import datetime
from app import db
from flask_login import UserMixin
from sqlalchemy.sql import func


class Users(db.Model, UserMixin):
    __tablename__ = 'users'

    user_id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    father_name = db.Column(db.String(50))
    gender = db.Column(db.String(6))
    email = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())
    superuser = db.Column(db.Boolean, default=False)

    # Связи
    posts = db.relationship('Posts', backref='author', lazy=True)
    comments = db.relationship('Comments', back_populates='author', lazy=True)

    sent_messages = db.relationship('PrivateMessage', foreign_keys='PrivateMessage.sender_id', backref='sender',
                                    lazy=True)
    received_messages = db.relationship('PrivateMessage', foreign_keys='PrivateMessage.receiver_id', backref='receiver',
                                        lazy=True)
    post_likes = db.relationship('PostLike', backref='user', lazy=True)
    comment_likes = db.relationship('CommentLike', backref='user', lazy=True)

    def get_id(self):
        return str(self.user_id)


class Posts(db.Model):
    __tablename__ = 'posts'

    post_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())
    updated_at = db.Column(db.DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    technology3d = db.Column(db.String(8))
    title = db.Column(db.String(255), nullable=False)
    content = db.Column(db.Text)
    code3d = db.Column(db.Text, nullable=False)

    # Связи
    comments = db.relationship('Comments', backref='posts', lazy=True, cascade='all, delete-orphan')
    likes = db.relationship('PostLike', backref='posts', lazy=True, cascade='all, delete-orphan')


class Comments(db.Model):
    __tablename__ = 'comments'

    comment_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.post_id'), nullable=False)
    parent_comment_id = db.Column(db.Integer, db.ForeignKey('comments.comment_id'))
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())

    # Связи
    replies = db.relationship('Comments', backref=db.backref('parent', remote_side=[comment_id]), lazy=True)
    likes = db.relationship('CommentLike', backref='comment', lazy=True, cascade='all, delete-orphan')
    author = db.relationship('Users', back_populates='comments')


class PostLike(db.Model):
    __tablename__ = 'post_likes'

    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.post_id'), primary_key=True)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())


class CommentLike(db.Model):
    __tablename__ = 'comment_likes'

    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    comment_id = db.Column(db.Integer, db.ForeignKey('comments.comment_id'), primary_key=True)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())


class PrivateMessage(db.Model):
    __tablename__ = 'private_messages'

    message_id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    receiver_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    content = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime(timezone=True), server_default=func.now())
    read_at = db.Column(db.DateTime(timezone=True))


class DeletedMessage(db.Model):
    __tablename__ = 'deleted_messages'

    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    message_id = db.Column(db.Integer, db.ForeignKey('private_messages.message_id'), primary_key=True)
    deleted_at = db.Column(db.DateTime(timezone=True), server_default=func.now())