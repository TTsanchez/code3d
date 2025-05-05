// Инициализация простого редактора
const editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
    mode: 'javascript',
    lineNumbers: true,
    indentUnit: 4
});