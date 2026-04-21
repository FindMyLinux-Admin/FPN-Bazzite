#!/bin/bash
set -ouex pipefail

# 1. System-Programme (NordVPN & Brave Browser) installieren
wget -qO - https://repo.nordvpn.com/gpg/nordvpn_public.asc | rpm --import -
curl -s -o /etc/yum.repos.d/nordvpn.repo https://repo.nordvpn.com/yum/nordvpn/centos/x86_64/nordvpn.repo
dnf5 install -y nordvpn

rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
curl -s -o /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-browser


# 2. Der "Distro-Magic" Trick für deine restlichen Apps
# Erstellt einen automatischen Installer, der beim ersten Hochfahren alles herunterlädt

cat << 'EOF' > /usr/bin/install-my-apps
#!/bin/bash
# Installiere die Apps, wenn es noch nicht passiert ist
if [ ! -f /var/opt/my-apps-installed ]; then
    flatpak install -y flathub com.discordapp.Discord com.spotify.Client org.freecad.FreeCAD com.nordpass.NordPass io.github.enginkirmaci.lumux org.prismlauncher.PrismLauncher
    touch /var/opt/my-apps-installed
fi
EOF
chmod +x /usr/bin/install-my-apps

# Sagt dem System, dass es das Skript heimlich beim Booten starten soll
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
