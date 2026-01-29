// Menu data
const menuData = [
    {
        id: 1,
        name: "Margherita Pizza",
        description: "Fresh tomatoes, mozzarella, basil, olive oil",
        price: 14.99,
        category: "mains",
        emoji: "🍕"
    },
    {
        id: 2,
        name: "Caesar Salad",
        description: "Romaine lettuce, parmesan, croutons, caesar dressing",
        price: 12.99,
        category: "appetizers",
        emoji: "🥗"
    },
    {
        id: 3,
        name: "Grilled Salmon",
        description: "Atlantic salmon with roasted vegetables",
        price: 22.99,
        category: "mains",
        emoji: "🐟"
    },
    {
        id: 4,
        name: "Chocolate Cake",
        description: "Rich chocolate cake with vanilla ice cream",
        price: 8.99,
        category: "desserts",
        emoji: "🍰"
    },
    {
        id: 5,
        name: "Craft Beer",
        description: "Local brewery selection",
        price: 5.99,
        category: "beverages",
        emoji: "🍺"
    },
    {
        id: 6,
        name: "Beef Burger",
        description: "Angus beef patty with lettuce, tomato, onion",
        price: 16.99,
        category: "mains",
        emoji: "🍔"
    },
    {
        id: 7,
        name: "Chicken Wings",
        description: "Buffalo wings with blue cheese dip",
        price: 11.99,
        category: "appetizers",
        emoji: "🍗"
    },
    {
        id: 8,
        name: "Tiramisu",
        description: "Traditional Italian dessert with coffee",
        price: 7.99,
        category: "desserts",
        emoji: "🍮"
    },
    {
        id: 9,
        name: "Fresh Lemonade",
        description: "House-made with fresh lemons",
        price: 3.99,
        category: "beverages",
        emoji: "🍋"
    },
    {
        id: 10,
        name: "Pasta Carbonara",
        description: "Creamy pasta with bacon and parmesan",
        price: 18.99,
        category: "mains",
        emoji: "🍝"
    },
    {
        id: 11,
        name: "Bruschetta",
        description: "Toasted bread with tomatoes and basil",
        price: 9.99,
        category: "appetizers",
        emoji: "🍞"
    },
    {
        id: 12,
        name: "Iced Coffee",
        description: "Cold brew coffee with milk",
        price: 4.99,
        category: "beverages",
        emoji: "☕"
    }
];

// Cart functionality
let cart = [];
let currentCategory = 'all';

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
    renderMenu();
    updateCartCount();
    setupEventListeners();
    // Set initial plain styling for menu items
    setTimeout(() => {
        toggleMenuItemStyles(false);
    }, 100);
});

// Setup event listeners
function setupEventListeners() {
    // Header scroll effect
    const header = document.querySelector('.header');
    let lastScrollY = window.scrollY;
    
    window.addEventListener('scroll', () => {
        const scrollY = window.scrollY;
        
        // Show menu with chocolate background when scrolling down
        if (scrollY > 100) {
            header.classList.add('scrolled', 'visible');
            // Add styling to menu items when scrolled
            toggleMenuItemStyles(true);
        } else {
            header.classList.remove('scrolled');
            // Remove styling from menu items when not scrolled
            toggleMenuItemStyles(false);
            if (scrollY === 0) {
                header.classList.remove('visible');
            }
        }
        
        // Show header when scrolling down, hide when at top
        if (scrollY > 50) {
            header.classList.add('visible');
            header.style.transform = 'translateY(0)';
            header.style.opacity = '1';
        } else {
            if (scrollY === 0) {
                header.classList.remove('visible');
                header.style.transform = 'translateY(-100%)';
                header.style.opacity = '0';
            }
        }
        
        lastScrollY = scrollY;
    });

    // Mobile menu toggle
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    
    hamburger.addEventListener('click', function() {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });

    // Category buttons
    const categoryBtns = document.querySelectorAll('.category-btn');
    categoryBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons
            categoryBtns.forEach(b => b.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');
            
            currentCategory = this.dataset.category;
            renderMenu();
        });
    });

    // Form submission
    const checkoutForm = document.getElementById('checkout-form');
    checkoutForm.addEventListener('submit', function(e) {
        e.preventDefault();
        handleOrderSubmission();
    });

    // Smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
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
}

// Render menu items
function renderMenu() {
    const menuGrid = document.getElementById('menu-grid');
    const filteredItems = currentCategory === 'all' 
        ? menuData 
        : menuData.filter(item => item.category === currentCategory);

    menuGrid.innerHTML = filteredItems.map(item => `
        <div class="menu-item" data-category="${item.category}">
            <div class="menu-item-image">${item.emoji}</div>
            <h3>${item.name}</h3>
            <p>${item.description}</p>
            <div class="menu-item-footer">
                <span class="price">$${item.price.toFixed(2)}</span>
                <button class="add-to-cart-btn" onclick="addToCart(${item.id})">
                    Add to Cart
                </button>
            </div>
        </div>
    `).join('');
    
    // Apply correct styling based on current scroll position
    setTimeout(() => {
        const isScrolled = window.scrollY > 100;
        toggleMenuItemStyles(isScrolled);
    }, 50);
}

// Add item to cart
function addToCart(itemId) {
    const item = menuData.find(item => item.id === itemId);
    const existingItem = cart.find(cartItem => cartItem.id === itemId);

    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            ...item,
            quantity: 1
        });
    }

    updateCartCount();
    showNotification(`${item.name} added to cart!`);
}

// Remove item from cart
function removeFromCart(itemId) {
    cart = cart.filter(item => item.id !== itemId);
    updateCartCount();
    renderCart();
}

// Update item quantity
function updateQuantity(itemId, change) {
    const item = cart.find(item => item.id === itemId);
    if (item) {
        item.quantity += change;
        if (item.quantity <= 0) {
            removeFromCart(itemId);
        } else {
            updateCartCount();
            renderCart();
        }
    }
}

// Update cart count in header
function updateCartCount() {
    const cartCount = document.getElementById('cart-count');
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    cartCount.textContent = totalItems;
}

// Render cart items
function renderCart() {
    const cartItems = document.getElementById('cart-items');
    const cartTotal = document.getElementById('cart-total');

    if (cart.length === 0) {
        cartItems.innerHTML = '<p class="empty-cart">Your cart is empty</p>';
        cartTotal.textContent = '0.00';
        return;
    }

    cartItems.innerHTML = cart.map(item => `
        <div class="cart-item">
            <div class="item-info">
                <span class="item-emoji">${item.emoji}</span>
                <div>
                    <h4>${item.name}</h4>
                    <p>$${item.price.toFixed(2)} each</p>
                </div>
            </div>
            <div class="item-controls">
                <button class="quantity-btn" onclick="updateQuantity(${item.id}, -1)">-</button>
                <span class="quantity">${item.quantity}</span>
                <button class="quantity-btn" onclick="updateQuantity(${item.id}, 1)">+</button>
                <button class="remove-btn" onclick="removeFromCart(${item.id})" style="margin-left: 1rem; background: #dc3545; color: white; border: none; padding: 0.5rem; border-radius: 5px; cursor: pointer;">Remove</button>
            </div>
        </div>
    `).join('');

    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    cartTotal.textContent = total.toFixed(2);
}

// Navigation functions
function scrollToMenu() {
    document.getElementById('menu').scrollIntoView({
        behavior: 'smooth'
    });
}

function showCart() {
    // Hide all sections
    hideAllSections();
    
    // Show cart section
    document.getElementById('cart').style.display = 'block';
    renderCart();
    
    // Scroll to cart
    document.getElementById('cart').scrollIntoView({
        behavior: 'smooth'
    });
}

function showPayment() {
    if (cart.length === 0) {
        showNotification('Your cart is empty!');
        return;
    }
    
    // Hide all sections
    hideAllSections();
    
    // Show payment section
    document.getElementById('payment').style.display = 'block';
    
    // Scroll to payment
    document.getElementById('payment').scrollIntoView({
        behavior: 'smooth'
    });
}

function hideAllSections() {
    document.getElementById('cart').style.display = 'none';
    document.getElementById('payment').style.display = 'none';
}

// Handle order submission
function handleOrderSubmission() {
    // Get form data
    const form = document.getElementById('checkout-form');
    const formData = new FormData(form);
    
    // Simulate order processing
    showNotification('Order placed successfully! Thank you for your order.');
    
    // Clear cart
    cart = [];
    updateCartCount();
    
    // Reset form
    form.reset();
    
    // Hide payment section and show menu
    hideAllSections();
    document.getElementById('menu').scrollIntoView({
        behavior: 'smooth'
    });
}

// Show notification
function showNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        background: #ff6b35;
        color: white;
        padding: 1rem;
        border-radius: 5px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        z-index: 1001;
        opacity: 0;
        transform: translateX(100%);
        transition: all 0.3s ease;
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Show notification
    setTimeout(() => {
        notification.style.opacity = '1';
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Hide notification after 3 seconds
    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Toggle menu item styles based on scroll position
function toggleMenuItemStyles(styled) {
    const menuItems = document.querySelectorAll('.menu-item');
    menuItems.forEach(item => {
        if (styled) {
            item.classList.remove('plain');
        } else {
            item.classList.add('plain');
        }
    });
}

// Mobile menu functionality
function toggleMobileMenu() {
    const navMenu = document.querySelector('.nav-menu');
    const hamburger = document.querySelector('.hamburger');
    
    navMenu.classList.toggle('active');
    hamburger.classList.toggle('active');
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    // Add click listener to cart button in navigation
    document.querySelector('.cart-btn').addEventListener('click', function(e) {
        e.preventDefault();
        showCart();
    });
    
    // Set initial focus
    document.body.focus();
});