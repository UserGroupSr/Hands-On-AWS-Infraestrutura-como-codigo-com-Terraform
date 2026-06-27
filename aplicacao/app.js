/**
 * app.js — Terraform + EC2 + ALB Demo
 *
 * Lê os metadados injetados nas <meta> tags pelo user_data do Terraform.
 * O script userdata.sh é referenciado no Launch Template via Terraform
 * e executa automaticamente na primeira inicialização de cada instância.
 *
 * Se os placeholders não foram substituídos (ex: ambiente local ou
 * sem terraform apply), exibe o estado "Nenhuma instância conectada".
 */

const PLACEHOLDER = /^\{\{.*\}\}$/; // detecta {{VALOR}} não substituído

function getMeta(name) {
  const el = document.querySelector(`meta[name="${name}"]`);
  if (!el) return null;
  const val = el.getAttribute('content') || '';
  return PLACEHOLDER.test(val.trim()) ? null : val.trim();
}

function set(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value || '—';
}

function showBadge(state) {
  const badge = document.getElementById('status-badge');
  const label = badge.querySelector('.badge-label');

  badge.classList.remove('badge--loading', 'badge--online', 'badge--offline');

  if (state === 'online') {
    badge.classList.add('badge--online');
    label.textContent = 'Online';
  } else {
    badge.classList.add('badge--offline');
    label.textContent = 'Sem instância';
  }
}

function init() {
  // Timestamp de carregamento
  set('timestamp', new Date().toLocaleString('pt-BR'));

  const instanceId = getMeta('ec2-instance-id');

  if (!instanceId) {
    // ── Estado: sem instância ────────────────────────────────
    showBadge('offline');
    document.getElementById('no-instance').classList.remove('hidden');
    return;
  }

  // ── Estado: com instância ──────────────────────────────────
  showBadge('online');
  document.getElementById('with-instance').classList.remove('hidden');

  set('display-instance-id', instanceId);
  set('display-az', getMeta('ec2-availability-zone') || 'AZ desconhecida');
  set('display-type', getMeta('ec2-instance-type'));
  set('display-public-ip', getMeta('ec2-public-ip'));
  set('display-private-ip', getMeta('ec2-private-ip'));
  set('display-region', getMeta('ec2-region'));
}

document.addEventListener('DOMContentLoaded', init);
