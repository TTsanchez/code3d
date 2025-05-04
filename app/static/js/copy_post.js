<!--Копирование ссылки на пост-->
// Получаем все элементы с классом "copyButton"
var copyButtons = document.querySelectorAll('.copyButton');

// Добавляем слушатель события клика для каждой кнопки
copyButtons.forEach(function(button) {
    button.addEventListener('click', function() {
        // Получаем текущий URL страницы
        var currentUrl = window.location.href;

        // Находим позицию первого символа "/"
        var firstSlashIndex = currentUrl.indexOf('/');
        // Находим позицию второго символа "/" начиная с позиции после первого "/"
        var secondSlashIndex = currentUrl.indexOf('/', firstSlashIndex + 1);
        // Находим позицию третьего символа "/" начиная с позиции после второго "/"
        var thirdSlashIndex = currentUrl.indexOf('/', secondSlashIndex + 1);

        // Получаем базовый URL до третьего "/"
        var baseUrl = currentUrl.substring(0, thirdSlashIndex);

        var postId = button.getAttribute('data-postid');
        var postLink = baseUrl + '/post/' + postId;

        navigator.clipboard.writeText(postLink).then(function() {
            // Используем вашу функцию show_flash_message вместо notification
            show_flash_message('Ссылка на пост скопирована: ' + postLink, 'success');
        }, function(err) {
            show_flash_message('Не удалось скопировать ссылку', 'danger');
            console.error('Не удалось скопировать ссылку:', err);
        });
    });
});