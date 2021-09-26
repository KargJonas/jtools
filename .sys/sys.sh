#!/bin/bash

#                        __ 
#    ___ __ _____   ___ / / 
#   (_-</ // (_-<_ (_-</ _ \
#  /___/\_, /___(_)___/_//_/
#      /___/                
#

# Jonn 2021

function sys_info () {
  echo -e '\n\033[33;1m  Sys Info\033[00m  ' $1 '\n'
}

function sys_volume_info() {
  sys_info 'Volume set to '$1'%'
}

function sys_brightness_info () {
  sys_info 'Brightness set to '$1'%'
}

# Power controls
function sys_power() {
  case $1 in
  'poweroff' | 'p')
    sys_info 'Powering off'
    poweroff
    # shutdown
    ;;

  'reboot' | 'r')
    sys_info 'Rebooting'
    reboot
    ;;

  'suspend' | 'sleep' | 's')
    sys_info 'Going to sleep'
    systemctl suspend
    ;;

  'exit' | 'ex' | 'e')
    sys_info 'Exiting i3'
    i3-msg exit
    ;;

  'lock' | 'glitchlock' | 'gl' | 'l')
    sys_info 'Locking i3'
    exec /home/jonas/Programs/glitchlock/glitchlock.sh
    ;;
  esac
}

# Brightness controls
function sys_brightness () {
  local screen='eDP-1'

  if [ $1 -eq $1 ] 2>/dev/null; then
    # Brightness is a number
    if [[ $(($1)) -gt 19 && $(($1)) -lt 150 ]]; then
      xrandr --output $screen --brightness $(bc -l <<< $1'/100')
      # xbacklight -set $1
      sys_brightness_info $1
    else
      echo "You won't be able to see anything if then monitor brightness is lower than 20% or higher than 150%"
    fi

  else
    # Brightness is NaN
    case $1 in
    'max' | 'h')
      xrandr --output $screen --brightness 1
      sys_brightness_info 100
      ;;

    'min' | 'l')
      xrandr --output $screen --brightness 0.2
      sys_brightness_info 20
      ;;
    esac
  fi
}

# Volume controls
function sys_volume() {
  if [ $1 -eq $1 ] 2>/dev/null; then
    # Volume is a number
    $(pactl set-sink-volume 0 $1%)
    sys_volume_info $1
  else
    # Volume is NaN
    case $1 in
    'up')
      pactl set-sink-volume 0 +10%
      sys_volume_info '+10'
      ;;

    'down' | 'dw')
      pactl set-sink-volume 0 -10%
      sys_volume_info '-10'
      ;;

    'mute' | 'min' | 'm')
      pactl set-sink-volume 0 0%
      sys_volume_info '0'
      ;;
    esac
  fi
}

# Main controls
case $1 in
'p' | 'power')
  sys_power $2
  ;;

'b' | 'brightness')
  sys_brightness $2
  ;;

'v' | 'volume')
  sys_volume $2
  ;;
esac
