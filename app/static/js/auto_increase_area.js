// Автоувеличение textarea
// Получаем все элементы <textarea>
var textareas = document.getElementsByTagName('textarea');
// Для каждого элемента <textarea> добавляем обработчик события input
for (var i = 0; i < textareas.length; i++) {
  textareas[i].addEventListener('input', function () {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight) + 'px';
  });
}