document.addEventListener('DOMContentLoaded', () => {
    // Инициализация CodeMirror
    const editor = CodeMirror.fromTextArea(document.getElementById('3js-editor'), {
        lineNumbers: true,
        mode: 'javascript',
        theme: 'material',
        lineWrapping: true
    });

    const runBtn = document.getElementById('3js-run-button');
    const container = document.getElementById('canvas-container');
    const output = document.getElementById('3js-output');

    runBtn.addEventListener('click', () => {
        const code = editor.getValue();

        // Очистить контейнер
        container.innerHTML = '';

        // Создать canvas
        const canvas = document.createElement('canvas');
        // Задать размеры canvas по размеру контейнера
        canvas.width = container.clientWidth;
        canvas.height = container.clientHeight || 400;
        container.appendChild(canvas);

        try {
            // Выполнить код пользователя, передав canvas
            const userFunc = new Function('canvas', `
                const scene = new THREE.Scene();
                const camera = new THREE.PerspectiveCamera(75, canvas.width / canvas.height, 0.1, 1000);
                const renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
                renderer.setSize(canvas.width, canvas.height);

                ${code}
            `);
            userFunc(canvas);
            output.textContent = '✓ Код выполнен успешно';
            output.style.color = 'green';
        } catch (err) {
            output.textContent = '✗ Ошибка: ' + err.message;
            output.style.color = 'red';
        }
    });

    runBtn.click();
});