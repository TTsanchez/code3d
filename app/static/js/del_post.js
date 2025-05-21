// Функция удаления поста
function del_post(postId) {
    if (!postId || isNaN(postId)) {
        show_flash_message('Неверный ID поста', 'danger');
        return;
    }

    if (!confirm('Вы уверены, что хотите удалить этот пост?')) {
        return;
    }

    $.ajax({
        url: '/delete_post',
        method: 'POST',
        headers: {
            'X-CSRFToken': getCSRFToken() // Используем функцию для получения токена
        },
        data: {
            post_id: postId
        },
        beforeSend: function() {
            // Показываем индикатор загрузки
            $('#delete-btn-' + postId).html(
                '<span class="spinner-border spinner-border-sm" role="status"></span> Удаление...'
            ).prop('disabled', true);
        },
        success: function(response) {
    // Показываем сообщение об успехе
    show_flash_message(response.message || 'Пост успешно удален', 'success');

    // Находим элемент поста
    const $post = $('#post-' + postId);

    // Анимация схлопывания
    $post.css('overflow', 'hidden')  // Чтобы контент не выходил за границы
         .animate({
             opacity: 0,
             height: 0,
             paddingTop: 0,
             paddingBottom: 0,
             marginTop: 0,
             marginBottom: 0
         }, 400, function() {
             // После завершения анимации
             $(this).remove();

             // Обновляем счетчик
             updatePostsCounter(-1);

             // Проверяем, не пуста ли страница
             if ($('.post-item').length === 0) {
                 $('.posts-container').append(
                     '<div class="alert alert-info mt-4">Постов не найдено</div>'
                 );
             }
         });
},
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Ошибка сервера';
            show_flash_message(error, 'danger');
            $('#delete-btn-' + postId).html('Удалить').prop('disabled', false);
        }
    });
}

// Функция получения CSRF токена
function getCSRFToken() {
    return $('meta[name=csrf-token]').attr('content') ||
           $('input[name=csrf_token]').val() ||
           '';
}

// Функция обновления счетчика постов
function updatePostsCounter(change) {
    const counter = $('.posts-counter');
    if (counter.length) {
        const current = parseInt(counter.text()) || 0;
        counter.text(current + change);
    }
}