function updateX3D() {
    const editor = document.getElementById('x3d-editor');
    const output = document.getElementById('x3d-output');
    const container = document.getElementById('x3d-container');

    if (!editor || !output || !container) {
        console.error('Не найдены необходимые элементы DOM');
        return;
    }

    const newCode = editor.value.trim();
    if (!newCode) {
        output.textContent = '✗ Ошибка: Пустой код';
        output.style.color = 'red';
        return;
    }

    try {
        // Временный контейнер для парсинга
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = newCode;

        // Извлекаем <scene>
        const newScene = tempDiv.querySelector('scene');
        if (!newScene) {
            output.textContent = '✗ Ошибка: Не найден <scene>';
            output.style.color = 'red';
            return;
        }

        // Старый <scene>
        const oldScene = container.querySelector('scene');
        if (!oldScene) {
            output.textContent = '✗ Ошибка: Внутри x3d не найден <scene>';
            output.style.color = 'red';
            return;
        }

        // Заменяем содержимое сцены
        oldScene.innerHTML = newScene.innerHTML;

        // Обновляем рендер X3DOM
        if (typeof x3dom !== 'undefined') {
            x3dom.runtime.ready = false;
            x3dom.reload();  // безопасный вызов
        }

        output.textContent = '✓ Сцена обновлена';
        output.style.color = 'green';

    } catch (e) {
        output.textContent = '✗ Ошибка: ' + e.message;
        output.style.color = 'red';
        console.error("X3D Update Error:", e);
    }
}


function runCode_3js() {
    const code = document.getElementById('editor').value;
    const container = document.getElementById('canvas-container');
    container.innerHTML = '';
    const canvas = document.createElement('canvas');
    container.appendChild(canvas);

    try {
        const userScript = new Function('canvas', `
          const scene = new THREE.Scene();
          const camera = new THREE.PerspectiveCamera(75, ${container.offsetWidth} / ${container.offsetHeight}, 0.1, 1000);
          const renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
          renderer.setSize(${container.offsetWidth}, ${container.offsetHeight});
        
          ${code}
        `);

        userScript(canvas);
        document.getElementById('output').textContent = '✓ Code executed successfully';
        document.getElementById('output').style.color = 'green';
    } catch (e) {
        document.getElementById('output').textContent = '✗ Error: ' + e.message;
        document.getElementById('output').style.color = 'red';
    }
}

// Run initial code on load
window.onload = runCode_3js;


function toggleComments() {
    const commentsSection = document.getElementById('comments-section');
    commentsSection.style.display = commentsSection.style.display === 'none' ? 'block' : 'none';
}


// // Автоматическое выравнивание высоты
// function adjustHeights() {
//     if (window.innerWidth > 768) {
//         const preview = document.querySelector('.preview-section');
//         const code = document.querySelector('.code-section');
//         code.style.height = preview.offsetHeight + 'px';
//     }
// }

// window.addEventListener('load', adjustHeights);
// window.addEventListener('resize', adjustHeights);