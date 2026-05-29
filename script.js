document.addEventListener('DOMContentLoaded', () => {
    const toggleButton = document.getElementById('theme-toggle');
    const rootItem = document.documentElement;

    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('theme') || 'dark';
    rootItem.setAttribute('data-theme', savedTheme);

    toggleButton.addEventListener('click', () => {
        let currentTheme = rootItem.getAttribute('data-theme');
        let newTheme = currentTheme === 'dark' ? 'light' : 'dark';

        rootItem.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
    });

    // Smooth Scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });

    // Formulaire de contact — envoi AJAX (sans quitter la page)
    const contactForm = document.getElementById('contact-form');
    if (contactForm) {
        contactForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const btn = document.getElementById('submit-btn');
            const feedback = document.getElementById('form-feedback');

            // État chargement
            btn.disabled = true;
            btn.textContent = 'Envoi en cours…';
            feedback.style.display = 'none';

            const formData = {
                Nom: document.getElementById('name').value,
                Email: document.getElementById('email').value,
                Message: document.getElementById('message').value,
                _subject: 'Nouveau message depuis le Portfolio !',
                _captcha: 'false'
            };

            try {
                const res = await fetch('https://formsubmit.co/ajax/willem.dulormne@gmail.com', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });

                const data = await res.json();

                if (data.success === 'true' || data.success === true) {
                    // Succès
                    feedback.style.cssText = 'display:flex;align-items:center;gap:10px;margin-top:1rem;padding:14px 20px;border-radius:12px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.2);font-size:0.95rem;';
                    feedback.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px;flex-shrink:0;"><polyline points="20 6 9 17 4 12"></polyline></svg> Message envoyé ! Je vous répondrai très vite.`;
                    contactForm.reset();
                    btn.textContent = 'Envoyer';
                    btn.disabled = false;
                } else {
                    throw new Error('Echec');
                }
            } catch (err) {
                // Erreur
                feedback.style.cssText = 'display:flex;align-items:center;gap:10px;margin-top:1rem;padding:14px 20px;border-radius:12px;background:rgba(255,80,80,0.12);border:1px solid rgba(255,80,80,0.3);font-size:0.95rem;color:#ff9090;';
                feedback.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px;flex-shrink:0;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg> Erreur lors de l'envoi. Réessayez ou écrivez directement à willem.dulormne@gmail.com`;
                btn.textContent = 'Envoyer';
                btn.disabled = false;
            }
        });
    }

    // Lecteur Audio Personnalisé
    const audio = document.getElementById('piano-audio');
    const playPauseBtn = document.getElementById('play-pause-btn');
    const progressBar = document.getElementById('progress-bar');
    const playerTime = document.getElementById('player-time');
    const playIcon = playPauseBtn ? playPauseBtn.querySelector('.play-icon') : null;
    const pauseIcon = playPauseBtn ? playPauseBtn.querySelector('.pause-icon') : null;

    if (audio && playPauseBtn) {
        playPauseBtn.addEventListener('click', () => {
            if (audio.paused) {
                audio.play();
                if (playIcon) playIcon.style.display = 'none';
                if (pauseIcon) pauseIcon.style.display = 'block';
            } else {
                audio.pause();
                if (playIcon) playIcon.style.display = 'block';
                if (pauseIcon) pauseIcon.style.display = 'none';
            }
        });

        audio.addEventListener('timeupdate', () => {
            const progress = (audio.currentTime / audio.duration) * 100;
            if (progressBar) progressBar.style.width = `${progress}%`;
            
            // Formatage du temps
            const minutes = Math.floor(audio.currentTime / 60);
            const seconds = Math.floor(audio.currentTime % 60).toString().padStart(2, '0');
            if (playerTime) playerTime.textContent = `${minutes}:${seconds}`;
        });

        audio.addEventListener('ended', () => {
            if (playIcon) playIcon.style.display = 'block';
            if (pauseIcon) pauseIcon.style.display = 'none';
            if (progressBar) progressBar.style.width = '0%';
            if (playerTime) playerTime.textContent = '0:00';
        });
    }
});

