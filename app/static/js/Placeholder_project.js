// Подсказки в поле с кодом
document.addEventListener('DOMContentLoaded', function() {
  var technology3dField = document.getElementById('technology3d');

  technology3dField.addEventListener('change', function() {
    var technology3dValue = this.value;
    var code3dField = document.getElementById('code3d');
    if (technology3dValue === 'x3dom') {
      // Placeholder, если значение равно 'x3dom'
      code3dField.placeholder = 'Вставте код x3dom (только блок <scene>)';
    }
    else if (technology3dValue === 'verge3d'){
      // Placeholder, если значение равно 'verge3d'
      code3dField.placeholder = 'Вставте ссылку на проект';
    }
    else if (technology3dValue === 'three.js'){
      code3dField.placeholder = 'Код three.js';
    }
    else {
      code3dField.placeholder = '';
    }
  });
});