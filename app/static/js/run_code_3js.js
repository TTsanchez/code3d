function runCode() {
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
            window.onload = runCode;

function toggleComments() {
        const commentsSection = document.getElementById('comments-section');
        commentsSection.style.display = commentsSection.style.display === 'none' ? 'block' : 'none';
    }


// Автоматическое выравнивание высоты
function adjustHeights() {
    if (window.innerWidth > 768) {
        const preview = document.querySelector('.preview-section');
        const code = document.querySelector('.code-section');
        code.style.height = preview.offsetHeight + 'px';
    }
}

window.addEventListener('load', adjustHeights);
window.addEventListener('resize', adjustHeights);