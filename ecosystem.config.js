/**
 * PM2 Ecosystem Configuration - EcoBike
 * Desenvolvido por: Luis Mesquitela com Windsurf AI
 */

module.exports = {
  apps: [{
    name: 'ecobike',
    script: 'npm',
    args: 'start',
    cwd: './',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3002
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
