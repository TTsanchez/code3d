// Переход окон при регистрации
document.getElementById('nextButton').addEventListener('click', function() {
  document.getElementById('block1').style.display = 'none';
  document.getElementById('block2').style.display = 'block';
  document.getElementById('backButton').style.pointerEvents = 'auto';
  document.getElementById('nextButton').style.pointerEvents = 'none';
});
document.getElementById('backButton').addEventListener('click', function() {
  document.getElementById('block2').style.display = 'none';
  document.getElementById('block1').style.display = 'block';
  document.getElementById('backButton').style.pointerEvents = 'none';
  document.getElementById('nextButton').style.pointerEvents = 'auto';
});