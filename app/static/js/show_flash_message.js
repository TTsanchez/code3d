// Функция показа сообщений
function show_flash_message(text, type) {
    // Сначала удаляем предыдущие сообщения
    $('.alert-dismissible').alert('close');

    const alertHtml = `
    <div class="alert alert-${type} alert-dismissible fade show" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 1000;">
        ${text}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    `;

    $('body').append(alertHtml);

    // Автоматическое закрытие через 5 секунд
    setTimeout(() => {
        $('.alert-dismissible').alert('close');
    }, 5000);
}