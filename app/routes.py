import datetime
import os
import traceback
from datetime import datetime
from flask import render_template, jsonify, redirect, url_for, flash, request, make_response, send_from_directory
from flask_login import current_user, login_manager, login_user, login_required, logout_user, LoginManager
from flask_wtf.csrf import CSRFError
from sqlalchemy import desc, func
from sqlalchemy.exc import SQLAlchemyError
from werkzeug.security import generate_password_hash, check_password_hash
import re
from app import app, db
from app.classes_bd import Posts, Users, PostLike, Comments, CommentLike, PrivateMessage
from app.forms import CreatePostForm, RegistrationForm, AuthorizationForm, CommentForm, MessageForm
# from routes_forum import *

login_manager = LoginManager()
login_manager.init_app(app)

# Перенаправление неавторизованных пользователей
login_manager.login_view = 'unauthorized'


@app.route('/unauthorized')
def unauthorized():
    return render_template('unauthorized.html')


@app.errorhandler(500)
def internal_server_error(error):
    return render_template('500.html'), 500


@app.errorhandler(404)
def internal_server_error(error):
    return render_template('404.html'), 404


@app.errorhandler(400)
def internal_server_error(error):
    return render_template('400.html'), 400


@login_manager.user_loader
def load_user(user_id):
    return Users.query.get(user_id)


@app.route('/')
@app.route('/home')
def index():
    posts = (
        db.session.query(Posts, Users.username, func.count(PostLike.post_id).label('like_count'))
        .join(Users, Users.user_id == Posts.user_id)
        .outerjoin(PostLike, Posts.post_id == PostLike.post_id)
        .group_by(Posts.post_id, Users.username)
        .order_by(func.count(PostLike.post_id).desc())
        .limit(3)
        .all()
    )

    processed_posts = []
    for post, username, like_count in posts:
        post.username = username
        post.like_count = like_count
        processed_posts.append(post)

    # Получим id постов, которые лайкнул текущий пользователь
    liked_post_ids = []
    if current_user.is_authenticated:
        liked = db.session.query(PostLike.post_id).filter_by(user_id=current_user.user_id).all()
        liked_post_ids = [post_id for (post_id,) in liked]

    return render_template("index.html", posts=processed_posts, liked_post_ids=liked_post_ids)


@app.route('/posts')
def posts():
    # Получаем параметр сортировки
    sort_order = request.args.get('sort', 'desc')  # По умолчанию 'desc'
    if sort_order not in ['asc', 'desc']:
        sort_order = 'desc'

    # Запрос с join между
    posts_query = db.session.query(
        Posts.post_id.label('post_id'),
        Posts.created_at,
        Posts.title,
        Posts.content,
        Posts.code3d,
        Posts.technology3d,
        Posts.user_id,
        Users.username,
        func.count(PostLike.post_id).label('like_count')  # <-- заменили .id на .post_id
    ).join(Users, Posts.user_id == Users.user_id
           ).outerjoin(PostLike, Posts.post_id == PostLike.post_id
                       ).group_by(Posts.post_id, Users.username)

    # Сортировка
    if sort_order == 'asc':
        posts_query = posts_query.order_by(Posts.created_at.asc())
    else:
        posts_query = posts_query.order_by(Posts.created_at.desc())

    # Получаем все посты
    posts_with_users = posts_query.all()

    if current_user.is_authenticated:
        liked = PostLike.query.with_entities(PostLike.post_id).filter_by(user_id=current_user.user_id).all()
        liked_post_ids = {row.post_id for row in liked}
    else:
        liked_post_ids = set()

    return render_template("posts.html",
                           posts=posts_with_users,
                           sort=sort_order,
                           liked_post_ids=liked_post_ids)


@app.route('/sort_posts')
def sort_posts():
    sorted_posts = Posts.query.order_by(desc(Posts.created_at)).all()
    return jsonify([post.__dict__ for post in sorted_posts])


@app.route('/forum')
@login_required
def forum():
    return render_template("forum.html")


@app.route('/post/<int:post_id>')
def post(post_id):
    try:
        post = Posts.query.filter_by(post_id=post_id).first()
        if not post:
            return render_template('404.html', error="Пост не найден"), 404

        user = Users.query.get(post.user_id)
        if not user:
            return render_template('404.html', error="Автор не найден"), 404

        liked_post_ids = set()
        if current_user.is_authenticated:
            liked = PostLike.query.with_entities(PostLike.post_id).filter_by(user_id=current_user.user_id).all()
            liked_post_ids = {row.post_id for row in liked}

        all_comments = Comments.query.filter_by(post_id=post_id).order_by(Comments.created_at).all()
        comments_tree = prepare_comments_tree(all_comments, max_level=2)

        return render_template("post.html", post=post, user=user,
                               liked_post_ids=liked_post_ids,
                               comments=comments_tree,
                               form=CommentForm())

    except Exception as e:
        app.logger.error(f"Ошибка при загрузке поста: {e}")
        return render_template('500.html', error="Ошибка сервера"), 500


def prepare_comments_tree(comments, max_level=3):
    # Словарь comment_id -> comment объект
    comments_dict = {c.comment_id: c for c in comments}

    # Словарь parent_comment_id -> list[comment]
    children_map = {}
    for c in comments:
        parent_id = c.parent_comment_id
        children_map.setdefault(parent_id, []).append(c)

    def build_tree(comment, level=1):
        if level > max_level:
            return []  # сюда не идут, собираем отдельно

        comment.replies = children_map.get(comment.comment_id, [])

        # Для level == max_level надо собрать потомков всех уровней глубже в flat_replies
        if level == max_level:
            def gather_flat_replies(parent):
                result = []
                stack = children_map.get(parent.comment_id, []).copy()
                while stack:
                    node = stack.pop()
                    result.append(node)
                    stack.extend(children_map.get(node.comment_id, []))
                return result

            comment.flat_replies = gather_flat_replies(comment)
            # Чтобы flat_replies не были в replies (иначе дублирование)
            comment.replies = []

        else:
            for reply in comment.replies:
                build_tree(reply, level + 1)

        return comment

    # Получаем только топ-уровневые комментарии (parent_comment_id == None)
    roots = children_map.get(None, [])
    tree = [build_tree(c) for c in roots]

    return tree


@app.route('/about')
def about():
    return render_template("about.html")


@app.errorhandler(CSRFError)
def handle_csrf_error(e):
    return render_template('400.html', reason=e.description), 400


@app.route('/profile')
def profile():
    if current_user.is_authenticated:
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
        # Проверка уникальности никнейма
        if Users.query.filter_by(username=form.username.data).first():
            form.username.errors.append('Этот никнейм уже занят')
            return render_template('register.html', form=form)

        # Проверка уникальности email
        if Users.query.filter_by(email=form.email.data).first():
            form.email.errors.append('Этот email уже зарегистрирован')
            return render_template('register.html', form=form)

        # Создание пользователя
        hashed_password = generate_password_hash(form.password.data)
        user = Users(
            username=form.username.data,
            first_name=form.first_name.data,
            last_name=form.last_name.data,
            father_name=form.father_name.data,
            email=form.email.data,
            gender=form.gender.data,
            password_hash=hashed_password,
            created_at=datetime.utcnow()
        )

        try:
            db.session.add(user)
            db.session.commit()
            flash('Регистрация прошла успешно!', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            db.session.rollback()
            flash('Ошибка при регистрации', 'error')
            app.logger.error(f'Registration error: {str(e)}')

    return render_template('register.html', form=form)


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
                # Запрос на получение всех постов пользователя + username + лайки
                user_posts_query = db.session.query(
                    Posts.post_id,
                    Posts.title,
                    Posts.content,
                    Posts.code3d,
                    Posts.technology3d,
                    Posts.created_at,
                    Users.username,
                    func.count(PostLike.post_id).label('like_count')
                ).join(Users, Posts.user_id == Users.user_id
                       ).outerjoin(PostLike, Posts.post_id == PostLike.post_id
                                   ).filter(Posts.user_id == user.user_id
                                            ).group_by(Posts.post_id, Users.username
                                                       ).order_by(Posts.created_at.desc())

                user_posts = user_posts_query.all()

                # Обработка лайков
                if current_user.is_authenticated:
                    liked = PostLike.query.with_entities(PostLike.post_id).filter_by(user_id=current_user.user_id).all()
                    liked_post_ids = {row.post_id for row in liked}
                else:
                    liked_post_ids = set()

                return render_template('profile.html', user=user, posts=user_posts, liked_post_ids=liked_post_ids)
            else:
                return render_template('404.html')
        except Exception as e:
            return render_template('500.html', error=e)
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


@app.route('/comment/<int:post_id>', methods=['POST'])
@login_required
def add_comment(post_id):
    form = CommentForm()

    if form.validate_on_submit():
        content = form.content.data.strip()
        parent_id = form.parent_comment_id.data or None

        comment = Comments(
            user_id=current_user.user_id,
            post_id=post_id,
            content=content,
            parent_comment_id=parent_id
        )

        db.session.add(comment)
        db.session.commit()

        return redirect(url_for('post', post_id=post_id))

    flash('Ошибка в форме комментария.', 'danger')
    return redirect(url_for('post', post_id=post_id))


@app.route('/dialogs')
@login_required
def dialogs():
    try:
        # Собеседники — все пользователи, с кем были переписки (в обе стороны)
        subq1 = db.session.query(PrivateMessage.sender_id.label('user_id')).filter(
            PrivateMessage.receiver_id == current_user.user_id)
        subq2 = db.session.query(PrivateMessage.receiver_id.label('user_id')).filter(
            PrivateMessage.sender_id == current_user.user_id)
        union_subq = subq1.union(subq2).subquery()

        # Получаем пользователей из union-подзапроса + время последнего сообщения с ними
        interlocutors = (
            db.session.query(Users, func.max(PrivateMessage.created_at).label('last_message_time'))
            .join(union_subq, Users.user_id == union_subq.c.user_id)
            .join(PrivateMessage, ((PrivateMessage.sender_id == Users.user_id) &
                                   (PrivateMessage.receiver_id == current_user.user_id)) |
                  ((PrivateMessage.receiver_id == Users.user_id) & (PrivateMessage.sender_id == current_user.user_id)))
            .group_by(Users.user_id).order_by(desc('last_message_time')).all()
        )
        return render_template('dialogs.html', interlocutors=interlocutors)

    except Exception as e:
        print("Ошибка в /dialogs:", e)
        traceback.print_exc()
        return render_template('500.html', error=e)


@app.route('/dialog/<int:user_id>', methods=['GET', 'POST'])
@login_required
def dialog(user_id):
    partner = Users.query.get_or_404(user_id)
    form = MessageForm()

    if form.validate_on_submit():
        new_msg = PrivateMessage(
            sender_id=current_user.user_id,
            receiver_id=partner.user_id,
            content=form.message.data
        )
        db.session.add(new_msg)
        db.session.commit()
        return redirect(url_for('dialog', user_id=user_id))

    # Получаем все сообщения между текущим пользователем и партнером
    messages = PrivateMessage.query.filter(
        ((PrivateMessage.sender_id == current_user.user_id) & (PrivateMessage.receiver_id == partner.user_id)) |
        ((PrivateMessage.sender_id == partner.user_id) & (PrivateMessage.receiver_id == current_user.user_id))
    ).order_by(PrivateMessage.created_at.asc()).all()

    return render_template('dialog.html', partner=partner, messages=messages, form=form)


@app.route('/api/dialog/<int:user_id>/messages')
@login_required
def get_messages_api(user_id):
    partner = Users.query.get_or_404(user_id)
    messages = PrivateMessage.query.filter(
        ((PrivateMessage.sender_id == current_user.user_id) & (PrivateMessage.receiver_id == partner.user_id)) |
        ((PrivateMessage.sender_id == partner.user_id) & (PrivateMessage.receiver_id == current_user.user_id))
    ).order_by(PrivateMessage.created_at.asc()).all()

    messages_data = [{
        'sender_id': msg.sender_id,
        'content': msg.content,
        'created_at': msg.created_at.strftime('%Y-%m-%d %H:%M')
    } for msg in messages]

    return jsonify({'messages': messages_data})


SITEMAP_PATH = os.path.join(app.static_folder, 'sitemap.xml')
@app.route('/sitemap.xml')
def sitemap():
    pages = [
        {'url': url_for('index', _external=True, _scheme='https'), 'priority': 1.0, 'changefreq': 'weekly'},
        {'url': url_for('posts', _external=True, _scheme='https'), 'priority': 0.9, 'changefreq': 'hourly'},
        {'url': url_for('forum', _external=True, _scheme='https'), 'priority': 0.8, 'changefreq': 'hourly'},
        {'url': url_for('newpost', _external=True, _scheme='https'), 'priority': 0.4, 'changefreq': 'monthly'},
        {'url': url_for('about', _external=True, _scheme='https'), 'priority': 0.3, 'changefreq': 'monthly'},
    ]

    posts = Posts.query.all()
    for post in posts:
        pages.append({
            'url': url_for('post', post_id=post.post_id, _external=True, _scheme='https'),
            'priority': 0.6,
            'changefreq': 'weekly',
            'lastmod': post.updated_at if hasattr(post, 'updated_at') else datetime.utcnow()
        })

    # Добавляем отдельные профили пользователей
    users = Users.query.all()
    for user in users:
        pages.append({
            'url': url_for('user', user_identifier=user.username, _external=True, _scheme='https'),
            'priority': 0.4,
            'changefreq': 'monthly'
        })

    sitemap_xml = render_template('sitemap.xml', pages=pages)

    # Сохраняем в файл
    with open(SITEMAP_PATH, 'w', encoding='utf-8') as f:
        f.write(sitemap_xml)

    response = make_response(sitemap_xml)
    response.headers['Content-Type'] = 'application/xml'
    return response


@app.route('/robots.txt')
def robots_txt():
    return send_from_directory(app.static_folder, 'robots.txt', mimetype='text/plain')


@app.route('/yandex_4d81fceebbd66db2.html')
def yandex():
    return send_from_directory('static', 'yandex_4d81fceebbd66db2.html')


@app.route('/favicon.ico')
def favicon():
    return send_from_directory('static', 'favicon.ico', mimetype='image/vnd.microsoft.icon')