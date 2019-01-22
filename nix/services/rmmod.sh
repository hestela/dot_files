#!/usr/bin/env bash
mod=$1

if [ ! -z "$(lsmod | grep $mod)" ]; then
  echo "$0: modprobe -r $mod"
  modprobe -r $mod
else
  echo "$0: $1 not loaded"
fi
