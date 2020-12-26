apt_repos+=(ppa:regolith-linux/release)
apt_packages+=(
  # regolith
  regolith-desktop
  i3xrocks-net-traffic
  i3xrocks-cpu-usage
  i3xrocks-time
  i3xrocks-memory
  i3xrocks-battery
  i3xrocks-volume
  i3xrocks-temp
  i3xrocks-media-player
  i3-gaps-wm
  regolith-gnome-flashback
  regolith-i3-gaps-config

  # i3 support functionality
  blueman       # provides blueman-applet for bluetooth control from taskbar
  gnome-settings-daemon
  numlockx
  fcitx-bin     # japanese support
  rofi
  jq

  # rofimoji dependencies
  fonts-emojione
  python3
  xdotool
  xsel
)