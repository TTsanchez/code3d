import datetime
from datetime import datetime
from flask import render_template, jsonify, redirect, url_for, flash, request
from flask_login import current_user, login_manager, login_user, login_required, logout_user, LoginManager
from flask_wtf.csrf import CSRFError
from sqlalchemy import desc
from sqlalchemy.exc import SQLAlchemyError
from werkzeug.security import generate_password_hash, check_password_hash
import re
from app import app, db
from app.classes_bd import Posts, Users, PostLike
from app.forms import CreatePostForm, RegistrationForm, AuthorizationForm

login_manager = LoginManager()
login_manager.init_app(app)


@login_manager.user_loader
def load_user(user_id):
    return Users.query.get(user_id)

# Настроил с Cloudflare
# @app.before_request
# def redirect_www_to_non_www():
#     """Перенаправляет www.code3d.ru → code3d.ru"""
#     if request.host.startswith('www.'):
#         return redirect(request.url.replace('www.', '', 1), code=301)


@app.route('/')
@app.route('/home')
def index():
    return render_template("index.html")


@app.route('/posts')
def posts():
    # Получаем параметр сортировки
    sort_order = request.args.get('sort', 'desc')  # По умолчанию 'desc'
    if sort_order not in ['asc', 'desc']:
        sort_order = 'desc'

    # Запрос с join между Post и User
    posts_query = db.session.query(
        Posts.post_id.label('post_id'),
        Posts.created_at,
        Posts.title,
        Posts.content,
        Posts.code3d,
        Posts.technology3d,
        Posts.user_id,
        Users.username
    ).join(Users, Posts.user_id == Users.user_id)

    # Сортировка
    if sort_order == 'asc':
        posts_query = posts_query.order_by(Posts.created_at.asc())
    else:
        posts_query = posts_query.order_by(Posts.created_at.desc())

    # Получаем все посты
    posts_with_users = posts_query.all()

    return render_template("posts.html",
                           posts=posts_with_users,
                           sort=sort_order)


@app.route('/sort_posts')
def sort_posts():
    sorted_posts = Posts.query.order_by(desc(Posts.created_at)).all()
    return jsonify([post.__dict__ for post in sorted_posts])


@app.route('/forum')
def forum():
    if current_user.is_authenticated:
        return render_template("forum.html")
    else:
        return render_template("unauthorized.html")


@app.route('/post/<int:post_id>')
def post(post_id):
    try:
        #
        post = Posts.query.filter_by(post_id=post_id).first()

        if not post:  # Явная проверка на существование поста
            return render_template('404.html', error="Пост не найден"), 404

        # Упрощено: получаем пользователя напрямую через связь
        user = Users.query.get(post.user_id)

        if not user:  # Проверка на существование пользователя
            return render_template('404.html', error="Автор не найден"), 404

        return render_template("post.html", post=post, user=user)

    except Exception as e:
        app.logger.error(f"Ошибка при загрузке поста: {str(e) | e}")
        return render_template('500.html', error="Ошибка сервера"), 500


@app.route('/about')
def about():
    return render_template("about.html")


@app.errorhandler(CSRFError)
def handle_csrf_error(e):
    return render_template('400.html', reason=e.description), 400


@app.route('/profile')
def profile():
    if current_user.is_authenticated:
        code_template = render_template('base_post.html')
        return redirect(url_for('user', user_identifier=current_user.username))
    else:
        return render_template("unauthorized.html")


@app.route('/newpost', methods=['GET', 'POST'])
def newpost():
    if not current_user.is_authenticated:
        return render_template("unauthorized.html")

    form = CreatePostForm()
    user = Users.query.filter_by(username=current_user.username).first()

    if form.validate_on_submit():
        try:
            code3d_value = form.code3d.data

            # Проверка для x3dom
            if form.technology3d.data == 'x3dom':
                if not (code3d_value.startswith('<scene') and code3d_value.endswith('</scene>')):
                    flash('Поле должно начинаться с тега <scene> и заканчиваться тегом </scene>', 'error')
                    return render_template('newpost.html', form=form)

            # Проверка для verge3d
            elif form.technology3d.data == 'verge3d':
                base_url_pattern = r'https://(.*?).github.io/'
                if not (code3d_value.startswith('https://v3d.net/') or re.match(base_url_pattern, code3d_value)):
                    flash('Некорректная ссылка. Принимаются ссылки https://v3d.net/*** и https://***.github.io/***',
                          'error')
                    return render_template('newpost.html', form=form)

            elif form.technology3d.data == 'three.js':
                if not ('THREE.Scene' in code3d_value or 'new THREE.' in code3d_value):
                    flash('Код должен содержать Three.js сцену (например, new THREE.Scene())', 'error')
                    return render_template('newpost.html', form=form)

            # Создание поста
            post = Posts(
                title=form.title.data,
                content=form.content.data,
                code3d=code3d_value,
                technology3d=form.technology3d.data,
                type_of_work=form.type_of_work.data,
                user_id=user.user_id,  # Указываем текущего пользователя
                created_at=datetime.utcnow()
            )

            db.session.add(post)
            db.session.commit()
            return redirect(url_for('profile'))

        except Exception as e:
            db.session.rollback()
            flash(f'Ошибка при создании поста: {str(e)}', 'error')
            app.logger.error(f"Error creating post: {str(e)}")

    return render_template('newpost.html', form=form)


@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegistrationForm()
    if form.validate_on_submit():
        # Проверка занятости логина
        if check_username_exists(form.username.data):
            flash('Логин занят', 'name')
            return render_template('register.html', title='Register', form=form)
        # Проверка занятости почты
        if Users.query.filter_by(email=form.email.data).first():
            flash('Почта уже зарегистрирована', 'email')
            return render_template('register.html', title='Register', form=form)
        # Проверка совпадения паролей
        if form.password.data != form.confirm_password.data:
            flash('Пароли не совпадают', 'password')
            return render_template('register.html', title='Register', form=form)
        hashed_password = generate_password_hash(form.password.data)
        user = Users(username=form.username.data, first_name=form.first_name.data, last_name=form.last_name.data,
                     father_name=form.father_name.data, email=form.email.data,
                     gender=form.gender.data, password_hash=hashed_password, created_at=datetime.utcnow())
        db.session.add(user)
        db.session.commit()
        flash('Успешная регистрация', 'done')
        return render_template('register.html', title='Register', form=form)
    return render_template('register.html', title='Register', form=form)


@app.route('/login', methods=['GET', 'POST'])
def login():
    form = AuthorizationForm()
    if form.validate_on_submit():
        if request.method == 'POST':
            username = form.username.data
            password = form.password.data
            if not check_username_exists(username):
                flash('Пользователь не найден', 'name')
                return render_template('login.html', title='Login', form=form)
            user = Users.query.filter_by(username=username).first()
            if user and check_password_hash(user.password_hash, password):
                login_user(user, remember=form.remember_me.data)
                return redirect(url_for('profile'))
            flash('Неверный пароль', 'password')
            return render_template('login.html', title='Login', form=form)
    return render_template('login.html', title='Login', form=form)


@app.route('/user/<string:user_identifier>')
def user(user_identifier):
    if current_user.is_authenticated:
        try:
            # Находим пользователя по ID или username
            if user_identifier.isdigit():
                user = Users.query.get(int(user_identifier))
            else:
                user = Users.query.filter_by(username=user_identifier).first()

            if user:
                # Получаем все ID постов пользователя
                user_posts = Posts.query.filter_by(user_id=user.user_id).all()

                # Получаем сами посты по ID
                posts = []
                for post in user_posts:
                    # Используем кортеж значений в query.get()
                    post_data = Posts.query.get(post.post_id)

                    # Добавляем дату создания поста к данным
                    post_data.created_at_formatted = post_data.created_at.strftime('%Y-%m-%d %H:%M:%S')

                    posts.append(post_data)

                reversed_posts = posts[::-1]
                return render_template('profile.html', user=user, posts=reversed_posts)
            else:
                return render_template('404.html')
        except Exception as e:
            return render_template('500.html', error=e)  # Обработка ошибок базы данных
    else:
        return render_template("unauthorized.html")


@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))


def check_username_exists(username):
    existing_user = Users.query.filter_by(username=username).first()
    if existing_user:
        return True  # Имя пользователя уже занято
    else:
        return False  # Имя пользователя доступно


# Роут для удаления поста
@app.route('/delete_post', methods=['POST'])
def delete_post():
    try:
        # Валидация входных данных
        post_id = request.form.get('post_id')
        if not post_id or not post_id.isdigit():
            return jsonify({'error': 'Неверный ID поста'}), 400

        # Поиск поста с проверкой владельца
        post = Posts.query.filter_by(
            post_id=int(post_id),
            user_id=current_user.user_id  # Проверяем, что пост принадлежит текущему пользователю
        ).first()
        if not post:
            return jsonify({'error': 'Пост не найден или у вас нет прав на его удаление'}), 404

        # Удаление поста (каскадное удаление комментариев и лайков работает автоматически)
        db.session.delete(post)
        db.session.commit()

        return jsonify({'message': 'Пост успешно удален'})

    except SQLAlchemyError as e:
        db.session.rollback()
        app.logger.error(f'Ошибка при удалении поста {post_id}: {str(e)}')
        return jsonify({'error': 'Внутренняя ошибка сервера'}), 500


@app.route('/like/<int:post_id>', methods=['POST'])
@login_required
def like_post(post_id):
    post = Posts.query.get_or_404(post_id)

    # Проверяем, ставил ли пользователь лайк
    existing_like = PostLike.query.filter_by(user_id=current_user.user_id, post_id=post_id).first()

    if existing_like:
        # Удаляем лайк
        db.session.delete(existing_like)
        liked = False
    else:
        # Добавляем лайк
        new_like = PostLike(user_id=current_user.user_id, post_id=post_id)
        db.session.add(new_like)
        liked = True

    db.session.commit()

    # Считаем текущее количество лайков
    likes_count = PostLike.query.filter_by(post_id=post_id).count()

    return jsonify({
        'success': True,
        'liked': liked,
        'likes_count': likes_count
    })


def is_valid_url(url):
    pattern = r'^https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+'
    match = re.match(pattern, url)
    return bool(match)
