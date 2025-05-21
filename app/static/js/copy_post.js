document.addEventListener('DOMContentLoaded', function() {
    const copyButtons = document.querySelectorAll('.share-btn');

    copyButtons.forEach(function(button) {
        button.addEventListener('click', function() {
            const postId = button.getAttribute('data-postid');
            let linkToCopy;

            if (postId) {
                // Генерируем ссылку вида /post/123
                const currentUrl = window.location.href;
                const firstSlash = currentUrl.indexOf('/');
                const secondSlash = currentUrl.indexOf('/', firstSlash + 1);
                const thirdSlash = currentUrl.indexOf('/', secondSlash + 1);
                const baseUrl = currentUrl.substring(0, thirdSlash);
                linkToCopy = `${baseUrl}/post/${postId}`;
            } else {
                // Просто текущий URL
                linkToCopy = window.location.href;
            }

            navigator.clipboard.writeText(linkToCopy).then(function() {
                show_flash_message('Ссылка скопирована: ' + linkToCopy, 'success');
            }).catch(function(err) {
                show_flash_message('Не удалось скопировать ссылку', 'danger');
                console.error('Ошибка копирования:', err);
            });
        });
    });
});
