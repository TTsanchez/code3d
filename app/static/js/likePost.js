function likePost(postId) {
    if (!isAuthenticated) {
        showLoginModal();  // Показать модалку
        return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch(`/like/${postId}`, {
        method: 'POST',
        headers: {
            'X-CSRFToken': csrfToken,
            'X-Requested-With': 'XMLHttpRequest',
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const btn = document.querySelector(`.like-btn[data-post-id="${postId}"]`);
            if (btn) {
                // Обновляем число лайков
                btn.innerHTML = `❤️ ${data.likes_count}`;
                // Переключаем цвет (серое/красное)
                btn.classList.toggle('liked', data.liked);  // <-- ВОТ ЗДЕСЬ
            }
        }
    });
}


function showLoginModal() {
    const modal = new bootstrap.Modal(document.getElementById('loginModal'));
    modal.show();
}
