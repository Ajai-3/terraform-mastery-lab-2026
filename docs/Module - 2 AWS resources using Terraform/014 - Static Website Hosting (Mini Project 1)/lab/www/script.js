// Counter functionality
let counter = 0;
const counterButton = document.getElementById('counterButton');
const counterSpan = document.getElementById('counter');

counterButton.addEventListener('click', function () {
  counter++;
  counterSpan.textContent = counter;

  // Add visual feedback
  counterButton.style.transform = 'scale(0.95)';
  setTimeout(() => {
    counterButton.style.transform = 'scale(1)';
  }, 100);

  // Show milestone notification at every 10 clicks
  if (counter % 10 === 0) {
    showCelebration();
  }
});

// Theme toggle functionality
const themeButton = document.getElementById('themeButton');
let isDarkTheme = true; // Default is dark theme

themeButton.addEventListener('click', function () {
  isDarkTheme = !isDarkTheme;
  document.body.classList.toggle('light-theme');
  localStorage.setItem('darkTheme', isDarkTheme);
  
  // Update button text
  themeButton.textContent = isDarkTheme ? 'Switch to Light Theme' : 'Switch to Dark Theme';
});

// Deployment Simulator
const deployButton = document.getElementById('deployButton');
const terminalBody = document.getElementById('terminalBody');

const logs = [
  { text: "$ terraform init", delay: 500, color: "#38bdf8" },
  { text: "Initializing the backend...", delay: 1000 },
  { text: "Initializing provider plugins...", delay: 1500 },
  { text: "Terraform has been successfully initialized!", delay: 2000, color: "#10b981" },
  { text: "$ terraform apply -auto-approve", delay: 2800, color: "#38bdf8" },
  { text: "aws_s3_bucket.www: Creating...", delay: 3500 },
  { text: "aws_s3_bucket.www: Creation complete [id=aws-static-website-bucket]", delay: 4200 },
  { text: "aws_cloudfront_distribution.cdn: Creating...", delay: 4800 },
  { text: "aws_cloudfront_distribution.cdn: Creation complete [id=E23VOBXEXAMPLE]", delay: 6000 },
  { text: "Apply complete! Resources: 3 added, 0 changed, 0 destroyed.", delay: 6800, color: "#10b981" },
  { text: "Website URL: https://d111111abcdef8.cloudfront.net", delay: 7500, color: "#a855f7" }
];

deployButton.addEventListener('click', function() {
  deployButton.disabled = true;
  deployButton.textContent = "Deploying...";
  terminalBody.innerHTML = "";
  
  logs.forEach((log) => {
    setTimeout(() => {
      const line = document.createElement('p');
      line.className = 'term-line';
      if (log.color) {
        line.style.color = log.color;
      }
      line.textContent = log.text;
      terminalBody.appendChild(line);
      terminalBody.scrollTop = terminalBody.scrollHeight; // Auto scroll down
      
      // Update button when finished
      if (log.text.includes("Website URL")) {
        deployButton.disabled = false;
        deployButton.textContent = "Re-Deploy Site";
      }
    }, log.delay);
  });
});

// Load saved theme preference
document.addEventListener('DOMContentLoaded', function () {
  const savedTheme = localStorage.getItem('darkTheme');
  if (savedTheme === 'false') {
    isDarkTheme = false;
    document.body.classList.add('light-theme');
    themeButton.textContent = 'Switch to Dark Theme';
  } else {
    isDarkTheme = true;
    document.body.classList.remove('light-theme');
    themeButton.textContent = 'Switch to Light Theme';
  }

  // Animate elements on page load
  animateOnLoad();

  // Update status periodically
  updateStatus();
  setInterval(updateStatus, 5000);
});

// Animation on page load
function animateOnLoad() {
  const cards = document.querySelectorAll('.feature-card');
  cards.forEach((card, index) => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';

    setTimeout(() => {
      card.style.transition = 'all 0.6s ease';
      card.style.opacity = '1';
      card.style.transform = 'translateY(0)';
    }, index * 100);
  });
}

// Celebration effect
function showCelebration() {
  const celebration = document.createElement('div');
  celebration.innerHTML = '<div class="milestone-toast">Milestone Reached!</div>';
  celebration.style.cssText = `
        position: fixed;
        top: 20%;
        left: 50%;
        transform: translate(-50%, -50%);
        pointer-events: none;
        z-index: 1000;
        animation: celebrate 1.2s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    `;

  // Add celebration animation
  const style = document.createElement('style');
  style.textContent = `
        @keyframes celebrate {
            0% { transform: translate(-50%, -50%) scale(0.8); opacity: 0; }
            20% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
            80% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
            100% { transform: translate(-50%, -50%) scale(0.9); opacity: 0; }
        }
        .milestone-toast {
            background: linear-gradient(135deg, #06b6d4, #a855f7);
            color: #ffffff;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 700;
            box-shadow: 0 10px 25px -5px rgba(6, 182, 212, 0.4);
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.9rem;
        }
    `;
  document.head.appendChild(style);
  document.body.appendChild(celebration);

  setTimeout(() => {
    document.body.removeChild(celebration);
    document.head.removeChild(style);
  }, 1200);
}

// Status updates
function updateStatus() {
  const statuses = ['Active', 'Optimized', 'Secure', 'Fast'];
  const statusElement = document.getElementById('status');
  const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];

  statusElement.style.opacity = '0.5';
  setTimeout(() => {
    statusElement.textContent = randomStatus;
    statusElement.style.opacity = '1';
  }, 300);
}

// Add some interactive hover effects
document.addEventListener('DOMContentLoaded', function () {
  const featureCards = document.querySelectorAll('.feature-card');

  featureCards.forEach((card) => {
    card.addEventListener('mouseenter', function () {
      this.style.transform = 'translateY(-5px)';
    });

    card.addEventListener('mouseleave', function () {
      this.style.transform = 'translateY(0)';
    });
  });
});

// Add keyboard navigation
document.addEventListener('keydown', function (e) {
  if (e.key === 'Space' || e.keyCode === 32) {
    e.preventDefault();
    counterButton.click();
  }
});

// Performance monitoring
window.addEventListener('load', function () {
  const loadTime =
    window.performance.timing.loadEventEnd -
    window.performance.timing.navigationStart;
  console.log(`Page loaded in ${loadTime}ms`);

  setTimeout(() => {
    console.log('AWS Static Website Demo loaded successfully!');
    console.log('Features: S3 + CloudFront + Terraform');
  }, 1000);
});
