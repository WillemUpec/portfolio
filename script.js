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

    // ── Menu hamburger (mobile) ───────────────────────────────────
    const menuToggle = document.getElementById('menu-toggle');
    const mainNav    = document.getElementById('main-nav');

    if (menuToggle && mainNav) {
        menuToggle.addEventListener('click', () => {
            menuToggle.classList.toggle('open');
            mainNav.classList.toggle('open');
        });

        // Ferme le menu au clic sur un lien
        mainNav.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', () => {
                menuToggle.classList.remove('open');
                mainNav.classList.remove('open');
            });
        });
    }
    // ─────────────────────────────────────────────────────────────

    // ── Particules tombantes ──────────────────────────────────────────
    const canvas = document.getElementById('particles-canvas');
    const ctx = canvas.getContext('2d');

    let W = canvas.width  = window.innerWidth;
    let H = canvas.height = window.innerHeight;

    window.addEventListener('resize', () => {
        W = canvas.width  = window.innerWidth;
        H = canvas.height = window.innerHeight;
    });

    const PARTICLE_COUNT = 90;
    const particles = [];

    function rand(min, max) { return Math.random() * (max - min) + min; }

    function createParticle() {
        return {
            x:      rand(0, W),
            y:      rand(-H, 0),        // départ hors écran en haut
            r:      rand(0.8, 2.5),     // rayon
            speed:  rand(0.4, 1.2),     // vitesse de chute
            drift:  rand(-0.3, 0.3),    // dérive horizontale
            wave:   rand(0, Math.PI * 2), // phase d'oscillation
            waveAmp: rand(0.2, 0.6),    // amplitude ondulation
            alpha:  rand(0.15, 0.55),   // opacité
        };
    }

    for (let i = 0; i < PARTICLE_COUNT; i++) {
        const p = createParticle();
        p.y = rand(0, H); // positions initiales réparties
        particles.push(p);
    }

    function draw() {
        ctx.clearRect(0, 0, W, H);

        const isDark = rootItem.getAttribute('data-theme') !== 'light';
        const color  = isDark ? '255,255,255' : '0,0,0';

        particles.forEach(p => {
            // Mouvement
            p.y += p.speed;
            p.wave += 0.015;
            p.x += p.drift + Math.sin(p.wave) * p.waveAmp;

            // Réinitialiser quand sorti par le bas
            if (p.y > H + 10) {
                p.y = -10;
                p.x = rand(0, W);
            }
            // Réinitialiser si sorti sur les côtés
            if (p.x < -10) p.x = W + 10;
            if (p.x > W + 10) p.x = -10;

            // Dessin
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fillStyle = `rgba(${color}, ${isDark ? p.alpha : p.alpha * 0.4})`;
            ctx.fill();
        });

        requestAnimationFrame(draw);
    }

    draw();
    // ─────────────────────────────────────────────────────────────────

    // Smooth Scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
                return;
            }
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });

    // Formulaire de contact — Web3Forms (fiable, sans quitter la page)
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

            try {
                const formData = new FormData(contactForm);
                const object = Object.fromEntries(formData);
                const json = JSON.stringify(object);

                const res = await fetch('https://api.web3forms.com/submit', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: json
                });

                const data = await res.json();

                if (res.ok && data.success) {
                    // Succès
                    feedback.style.cssText = 'display:flex;align-items:center;gap:10px;margin-top:1.2rem;padding:14px 20px;border-radius:12px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.2);font-size:0.95rem;';
                    feedback.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px;flex-shrink:0;"><polyline points="20 6 9 17 4 12"></polyline></svg> Message envoyé ! Je vous répondrai très vite.`;
                    contactForm.reset();
                } else {
                    throw new Error(data.message || 'Erreur inconnue');
                }
            } catch (err) {
                // Erreur
                feedback.style.cssText = 'display:flex;align-items:center;gap:10px;margin-top:1.2rem;padding:14px 20px;border-radius:12px;background:rgba(255,80,80,0.12);border:1px solid rgba(255,80,80,0.3);font-size:0.95rem;color:#ff9090;';
                feedback.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px;flex-shrink:0;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg> Erreur lors de l'envoi. Écris-moi directement : willem.dulormne@gmail.com`;
            } finally {
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

