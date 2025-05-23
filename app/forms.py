#Форма заполнения поста
from flask_wtf import FlaskForm
from wtforms import TextAreaField, SelectField, SubmitField, StringField, PasswordField, BooleanField, HiddenField
from wtforms.validators import DataRequired, Length, Optional, EqualTo, Email, Regexp


class CreatePostForm(FlaskForm):
    type_of_work = TextAreaField('Тип работы', validators=[Optional()])
    title = TextAreaField('Заголовок', validators=[DataRequired()])
    content = TextAreaField('Текст', validators=[DataRequired()])
    technology3d = SelectField('', choices=[('', ''),('x3dom', 'X3DOM'), ('verge3d', 'VERGE3D'), ('three.js', 'Three.js')],
                         validators=[DataRequired()])
    code3d = TextAreaField('Место для проекта', validators=[DataRequired()])
    submit = SubmitField('Опубликовать')


#Форма регистрации
class RegistrationForm(FlaskForm):
    username = StringField('Никнейм', validators=[
        DataRequired(message="Поле Никнейм обязательно"),
        Length(min=4, max=20, message="Ник должен быть от 4 до 20 символов"),
        Regexp('^[а-яА-ЯёЁa-zA-Z0-9_]+$',
               message="Никнейм содержит недопустимые символы")
    ])

    first_name = StringField('Имя', validators=[
        DataRequired(message="Поле Имя обязательно"),
        Length(min=2, max=20, message="Имя должно быть от 2 до 20 символов"),
        Regexp('^[а-яА-ЯёЁa-zA-Z-]+$',
               message="Имя может содержать только буквы и дефис")
    ])

    last_name = StringField('Фамилия', validators=[
        DataRequired(message="Поле Фамилия обязательно"),
        Length(min=2, max=20, message="Фамилия должна быть от 2 до 20 символов"),
        Regexp('^[а-яА-ЯёЁa-zA-Z-]+$',
               message="Фамилия может содержать только буквы и дефис")
    ])

    father_name = StringField('Отчество', validators=[
        Optional(),
        Length(min=2, max=30, message="Отчество должно быть от 2 до 20 символов"),
        Regexp('^[а-яА-ЯёЁa-zA-Z-]+$',
               message="Фамилия может содержать только буквы и дефис")
    ])

    email = StringField('Email', validators=[
        DataRequired(message="Поле Email обязательно"),
        Email(message="Некорректный email"),
        Length(max=100)
    ])

    gender = SelectField('Пол', choices=[
        ('male', 'Мужской'),
        ('female', 'Женский'),
        ('other', 'Другое')
    ], validators=[DataRequired(message="Выберите пол")])

    password = PasswordField('Пароль', validators=[
        DataRequired(message="Поле Пароль обязательно"),
        Length(min=6, max=20, message="Пароль должен быть от 6 до 20 символов")
    ])

    confirm_password = PasswordField('Подтвердите пароль', validators=[
        DataRequired(message="Поле Подтверждение пароля обязательно"),
        EqualTo('password', message="Пароли не совпадают")
    ])

    submit = SubmitField('Зарегистрироваться')


#Форма входа
class AuthorizationForm(FlaskForm):
    username = StringField('Никнейм', validators=[DataRequired(), Length(min=4, max=20)])
    password = PasswordField('Пароль', validators=[DataRequired(), Length(min=6, max=20)])
    remember_me = BooleanField('Запомнить меня')
    submit = SubmitField('Войти')


class CommentForm(FlaskForm):
    parent_comment_id = HiddenField()
    content = TextAreaField('Комментарий', validators=[DataRequired(message="Комментарий не может быть пустым.")])
    submit = SubmitField('Отправить')