### Set up remote ssh access ###

notice "Setting up sshd_config"
sshd_config_file="/etc/ssh/sshd_config.d/99-my-sshd-config.conf"
cp "$PROGDIR/resources/99-my-sshd-config.conf" "$sshd_config_file"
chown root:root "$sshd_config_file"
chmod u=rw,go-wx "$sshd_config_file"

systemctl restart ssh