/**
 * 🌪️ MITANDRINA - Main JavaScript
 * Interactions globales et utilitaires
 */

document.addEventListener('DOMContentLoaded', function() {
    
    // ============================================
    // Mobile Navigation Toggle
    // ============================================
    const navToggle = document.querySelector('.nav-toggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (navToggle && sidebar) {
        navToggle.addEventListener('click', function() {
            sidebar.classList.toggle('open');
        });
    }
    
    // ============================================
    // Smooth Scroll
    // ============================================
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // ============================================
    // Navbar Scroll Effect
    // ============================================
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        let lastScroll = 0;
        
        window.addEventListener('scroll', function() {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 100) {
                navbar.style.background = 'rgba(15, 23, 42, 0.95)';
                navbar.style.backdropFilter = 'blur(12px)';
            } else {
                navbar.style.background = 'rgba(30, 41, 59, 0.7)';
            }
            
            lastScroll = currentScroll;
        });
    }
    
    // ============================================
    // Form Validation Enhancement
    // ============================================
    const forms = document.querySelectorAll('form[data-validate]');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.classList.add('error');
                    
                    // Shake animation
                    field.style.animation = 'shake 0.5s';
                    setTimeout(() => {
                        field.style.animation = '';
                    }, 500);
                } else {
                    field.classList.remove('error');
                }
            });
            
            if (!isValid) {
                e.preventDefault();
            }
        });
    });
    
    // ============================================
    // Alert Dismiss
    // ============================================
    const dismissBtns = document.querySelectorAll('[data-dismiss]');
    
    dismissBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const target = document.querySelector(this.dataset.dismiss);
            if (target) {
                target.style.opacity = '0';
                target.style.transform = 'translateY(-20px)';
                setTimeout(() => target.remove(), 300);
            }
        });
    });
    
    // ============================================
    // Copy to Clipboard
    // ============================================
    const copyBtns = document.querySelectorAll('[data-copy]');
    
    copyBtns.forEach(btn => {
        btn.addEventListener('click', async function() {
            const text = this.dataset.copy;
            try {
                await navigator.clipboard.writeText(text);
                showToast('Copié !', 'success');
            } catch (err) {
                showToast('Erreur de copie', 'error');
            }
        });
    });
    
    // ============================================
    // Toast Notification System
    // ============================================
    window.showToast = function(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <span class="toast-icon">${getIconForType(type)}</span>
            <span class="toast-message">${message}</span>
        `;
        
        document.body.appendChild(toast);
        
        // Animate in
        requestAnimationFrame(() => {
            toast.style.opacity = '1';
            toast.style.transform = 'translateY(0)';
        });
        
        // Remove after 3 seconds
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(20px)';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    };
    
    function getIconForType(type) {
        const icons = {
            success: '✅',
            error: '❌',
            warning: '⚠️',
            info: 'ℹ️'
        };
        return icons[type] || icons.info;
    }
    
    // ============================================
    // Intersection Observer for Animations
    // ============================================
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    document.querySelectorAll('.feature-card, .flow-step, .stat-card').forEach(el => {
        observer.observe(el);
    });
    
    // ============================================
    // Online/Offline Detection
    // ============================================
    window.addEventListener('online', () => {
        showToast('Connexion rétablie', 'success');
    });
    
    window.addEventListener('offline', () => {
        showToast('Mode hors ligne', 'warning');
    });
    
});

// ============================================
// Utility Functions
// ============================================

/**
 * Debounce function
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Format date relative
 */
function timeAgo(date) {
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    
    let interval = seconds / 31536000;
    if (interval > 1) return Math.floor(interval) + ' ans';
    
    interval = seconds / 2592000;
    if (interval > 1) return Math.floor(interval) + ' mois';
    
    interval = seconds / 86400;
    if (interval > 1) return Math.floor(interval) + ' jours';
    
    interval = seconds / 3600;
    if (interval > 1) return Math.floor(interval) + ' heures';
    
    interval = seconds / 60;
    if (interval > 1) return Math.floor(interval) + ' minutes';
    
    return Math.floor(seconds) + ' secondes';
}

/**
 * Number formatting
 */
function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    }
    if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

// ============================================
// CSS Animations
// ============================================
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
        75% { transform: translateX(5px); }
    }
    
    .toast {
        position: fixed;
        bottom: 20px;
        right: 20px;
        padding: 12px 20px;
        background: rgba(30, 41, 59, 0.95);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 10000;
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.3s ease;
    }
    
    .toast-success { border-left: 3px solid #10B981; }
    .toast-error { border-left: 3px solid #DC2626; }
    .toast-warning { border-left: 3px solid #F59E0B; }
    
    .animate-in {
        animation: fadeInUp 0.6s ease forwards;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
