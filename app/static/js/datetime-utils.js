function formatUTCDateTime(utcIsoString, element) {
    try {
        // 1. Явно указываем, что время в UTC (добавляем 'Z' в конце)
        const utcTime = new Date(utcIsoString + 'Z');

        // 2. Проверяем, что дата валидна
        if (isNaN(utcTime.getTime())) {
            throw new Error("Invalid date");
        }

        // 3. Конвертируем в локальное время с явным указанием UTC
        const localTime = utcTime.toLocaleString('ru-RU', {
            timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone, // Автоопределение
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        }).replace(',', '');

        // 4. Выводим результат
        element.textContent = localTime;

    } catch (e) {
        console.error('DateTime conversion error:', e);
        element.textContent = utcIsoString + ' (UTC)';
    }
}

// Автоматическая обработка при загрузке
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[data-utc-time]').forEach(el => {
        formatUTCDateTime(el.dataset.utcTime, el);
    });
});