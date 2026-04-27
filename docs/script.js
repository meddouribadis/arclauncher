document.addEventListener('DOMContentLoaded', () => {
    // Navbar scroll effect
    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    const handleScroll = () => {
        const currentScroll = window.scrollY;

        // Add/remove scrolled class for background effect
        if (currentScroll > 50) {
            navbar.style.background = 'rgba(15, 23, 42, 0.95)';
        } else {
            navbar.style.background = 'rgba(15, 23, 42, 0.8)';
        }

        lastScroll = currentScroll;
    };

    // Throttled scroll handler
    let ticking = false;
    window.addEventListener('scroll', () => {
        if (!ticking) {
            window.requestAnimationFrame(() => {
                handleScroll();
                ticking = false;
            });
            ticking = true;
        }
    });

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;

            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                const navbarHeight = navbar.offsetHeight;
                const targetPosition = target.getBoundingClientRect().top + window.scrollY - navbarHeight;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    // Intersection Observer for fade-in animations on scroll
    const observerOptions = {
        root: null,
        rootMargin: '0px 0px -50px 0px',
        threshold: 0.1
    };

    const fadeInObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                fadeInObserver.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Apply fade-in to feature cards and steps
    const animateElements = document.querySelectorAll('.feature-card, .step');
    animateElements.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = `opacity 0.5s ease ${index * 0.1}s, transform 0.5s ease ${index * 0.1}s`;
        fadeInObserver.observe(el);
    });

    // Code typing effect for contribute section
    const codeContainer = document.querySelector('.code-content');
    if (codeContainer) {
        const codeLines = codeContainer.querySelectorAll('.code-line');
        codeLines.forEach((line, index) => {
            line.style.opacity = '0';
            setTimeout(() => {
                line.style.opacity = '1';
                line.style.transition = 'opacity 0.3s ease';
            }, 500 + (index * 150));
        });
    }

    // Button hover feedback enhancement
    const buttons = document.querySelectorAll('.btn-primary, .btn-secondary');
    buttons.forEach(btn => {
        btn.addEventListener('mouseenter', () => {
            btn.style.willChange = 'transform, box-shadow';
        });

        btn.addEventListener('mouseleave', () => {
            btn.style.willChange = 'auto';
        });
    });

    // Feature card focus enhancement for keyboard navigation
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach(card => {
        card.setAttribute('tabindex', '0');
        card.addEventListener('focus', () => {
            card.style.outline = '2px solid var(--color-accent)';
            card.style.outlineOffset = '4px';
        });
        card.addEventListener('blur', () => {
            card.style.outline = 'none';
        });
    });

    // Prevent default on badge clicks
    document.querySelectorAll('.hero-badge, .section-badge').forEach(badge => {
        badge.style.cursor = 'default';
        badge.addEventListener('click', (e) => {
            e.preventDefault();
        });
    });

    // Console welcome message
    console.log('%c Arc Launcher ', 'background: #6366F1; color: #fff; padding: 4px 8px; border-radius: 4px; font-weight: bold;');
    console.log('%c Built with Flutter, 100% Open Source ', 'color: #22D3EE;');
    console.log('%c Contribute: https://github.com/LeanbitCode/LtvLauncher ', 'color: #94A3B8;');
});
