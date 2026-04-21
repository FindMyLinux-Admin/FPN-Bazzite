#!/bin/bash
set -ouex pipefail

# 1. System-Programme (nur NordVPN, da es tiefe Rechte braucht)
curl -s https://repo.nordvpn.com/gpg/nordvpn_public.asc | rpm --import -
curl -s -o /etc/yum.repos.d/nordvpn.repo https://repo.nordvpn.com/yum/nordvpn/centos/x86_64/nordvpn.repo
rpm-ostree install nordvpn

# 2. Der "Distro-Magic" Trick für DEINE Apps (jetzt inkl. Brave Browser)
cat << 'EOF' > /usr/bin/install-my-apps
#!/bin/bash
if [ ! -f /var/opt/my-apps-installed ]; then
    flatpak install -y flathub com.brave.Browser com.discordapp.Discord com.spotify.Client org.freecad.FreeCAD com.nordpass.NordPass io.github.enginkirmaci.lumux org.prismlauncher.PrismLauncher
    touch /var/opt/my-apps-installed
fi
EOF
chmod +x /usr/bin/install-my-apps

# Sagt dem System, dass es das Skript beim Booten starten soll
cat << 'EOF' > /usr/lib/systemd/system/install-my-apps.service
[Unit]
Description=Installiere meine Custom Apps beim ersten Start
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/install-my-apps
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable install-my-apps.service
