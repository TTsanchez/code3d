document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll('.post-card').forEach(function (card) {
        card.addEventListener('click', function (e) {
            // если клик по ссылке, кнопке или сцене — ничего не делаем
            if (
                e.target.closest('a') ||
                e.target.closest('button') ||
                e.target.tagName === 'X3D' ||
                e.target.tagName === 'IFRAME' ||
                e.target.tagName === 'CANVAS'
            ) {
                return;
            }

            const href = card.getAttribute('data-href');
            if (href) {
                window.location.href = href;
            }
        });
    });
});
