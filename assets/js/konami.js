const konamiCode = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
let konamiPosition = 0;

window.addEventListener('keydown', function(e) {
  if (e.keyCode === konamiCode[konamiPosition]) {
    konamiPosition++;
    if (konamiPosition === konamiCode.length) {
      konamiPosition = 0;
      activateKonamiEffect();
    }
  } else {
    konamiPosition = 0;
  }
});

function activateKonamiEffect() {
  const body = document.body;
  
  if (body.classList.contains('konami-active')) {
    body.classList.remove('konami-active');
  } else {
    body.classList.add('konami-active');
  }
}

const style = document.createElement('style');
style.textContent = `
  body.konami-active {
    transform: rotate(180deg);
    transition: transform 1s ease-in-out;
  }
`;
document.head.appendChild(style);

