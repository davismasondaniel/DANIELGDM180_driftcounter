const hud       = document.getElementById('hud');
const statusEl  = document.getElementById('status');
const scoreEl   = document.getElementById('score');
const comboEl   = document.getElementById('combo');
const angleVal  = document.getElementById('angleVal');
const angleBar  = document.getElementById('angleBar');
const angleFill = document.getElementById('angleFill');
const bestEl    = document.getElementById('best');

const MAX_ANGLE = 70;

function fmt(n){ return Math.round(n).toLocaleString('en-US'); }

window.addEventListener('message', (event) => {
  const data = event.data;

  switch (data.type) {
    case 'show':
      hud.classList.remove('hidden');
      statusEl.textContent = 'STANDBY';
      statusEl.classList.remove('active');
      break;

    case 'hide':
      hud.classList.add('hidden');
      break;

    case 'pause':
      hud.classList.toggle('paused', !!data.hidden);
      break;

    case 'status':
      if (data.drifting) {
        statusEl.textContent = 'DRIFTING';
        statusEl.classList.add('active');
      } else {
        statusEl.textContent = 'STANDBY';
        statusEl.classList.remove('active');
      }
      break;

    case 'update':
      scoreEl.textContent = fmt(data.score);
      comboEl.textContent = 'x' + Number(data.combo).toFixed(1);
      angleVal.textContent = fmt(data.angle);
      angleBar.textContent = fmt((data.angle / MAX_ANGLE) * 100) + '%';
      angleFill.style.width = Math.min(100, (data.angle / MAX_ANGLE) * 100) + '%';
      bestEl.textContent = fmt(data.best);
      break;
  }
});
