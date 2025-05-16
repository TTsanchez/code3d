let x3dEditor;

    window.onload = function () {
        const textarea = document.getElementById('x3d-editor');
        if (textarea) {
            x3dEditor = CodeMirror.fromTextArea(textarea, {
                lineNumbers: true,
                mode: "xml",
                theme: "material",
                lineWrapping: true
            });
        }

        const runButton = document.getElementById('x3d-run-button');
        if (runButton) {
            runButton.addEventListener('click', updateX3D);
        }
    };

    function updateX3D() {
        const output = document.getElementById('x3d-output');
        const container = document.getElementById('x3d-container');

        if (!x3dEditor || !output || !container) {
            console.error('Не найдены необходимые элементы или редактор');
            return;
        }

        const newCode = x3dEditor.getValue().trim();
        if (!newCode) {
            output.textContent = '✗ Ошибка: Пустой код';
            output.style.color = 'red';
            return;
        }

        try {
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = newCode;

            const newScene = tempDiv.querySelector('scene');
            if (!newScene) {
                output.textContent = '✗ Ошибка: Не найден <scene>';
                output.style.color = 'red';
                return;
            }

            const oldScene = container.querySelector('scene');
            if (!oldScene) {
                output.textContent = '✗ Ошибка: Внутри x3d не найден <scene>';
                output.style.color = 'red';
                return;
            }

            oldScene.innerHTML = newScene.innerHTML;

            if (typeof x3dom !== 'undefined') {
                x3dom.runtime.ready = false;
                x3dom.reload();
            }

            output.textContent = '✓ Сцена обновлена';
            output.style.color = 'green';
        } catch (e) {
            output.textContent = '✗ Ошибка: ' + e.message;
            output.style.color = 'red';
            console.error("X3D Update Error:", e);
        }
    }