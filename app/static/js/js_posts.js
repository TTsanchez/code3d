document.addEventListener("DOMContentLoaded", function () {
    const container = document.getElementById("canvas-container");
    const canvas = document.getElementById("three-canvas");
    const code = `{{ post.code3d|safe }}`;

    try {
        const userScript = new Function('canvas', `
            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(75, ${container.offsetWidth} / ${container.offsetHeight}, 0.1, 1000);
            const renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
            renderer.setSize(${container.offsetWidth}, ${container.offsetHeight});

            ${code}
        `);

        userScript(canvas);
    } catch (e) {
        console.error('Ошибка выполнения Three.js кода:', e);
    }
});
