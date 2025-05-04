// Открытие доп информации о пользователе
const infoUserButton = document.getElementById('info_user_button');
infoUserButton.addEventListener('click', more_user_info);

function more_user_info() {
  const infoUser = document.getElementById('info_user');
  if (infoUser.style.display === '' || infoUser.style.display === 'none') {
    infoUser.style.display = 'block';
    infoUserButton.innerHTML = 'Скрыть';
  } else {
    infoUser.style.display = 'none';
    infoUserButton.innerHTML = 'Подробнее';
  }
};