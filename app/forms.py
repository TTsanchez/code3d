#Форма заполнения поста
from flask_wtf import FlaskForm
from wtforms import TextAreaField, SelectField, SubmitField, StringField, PasswordField, BooleanField
from wtforms.validators import DataRequired, Length, Optional


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
    username = StringField('Никнейм', validators=[DataRequired(), Length(min=4, max=20)])
    first_name = StringField('Имя', validators=[DataRequired(), Length(min=2, max=20)])
    last_name = StringField('Фамилия', validators=[DataRequired(), Length(min=2, max=20)])
    father_name = StringField('Отчество', validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Почта', validators=[DataRequired(), Length(min=4, max=100)])
    gender = SelectField('Пол', choices=[('male', 'Male'), ('female', 'Female'), ('other', 'Other')],
                         validators=[DataRequired()])
    password = PasswordField('Пароль', validators=[DataRequired(), Length(min=6, max=20)])
    confirm_password = PasswordField('Подтверждение пароля', validators=[DataRequired(), Length(min=6, max=20)])
    submit = SubmitField('Зарегистрироваться')


#Форма входа
class AuthorizationForm(FlaskForm):
    username = StringField('Никнейм', validators=[DataRequired(), Length(min=4, max=20)])
    password = PasswordField('Пароль', validators=[DataRequired(), Length(min=6, max=20)])
    remember_me = BooleanField('Запомнить меня')
    submit = SubmitField('Войти')