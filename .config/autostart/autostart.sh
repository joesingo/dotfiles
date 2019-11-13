#!/bin/bash
redshift -c ~/.config/redshift.conf &
cwp -t 5 &
setxkbmap gb
setxkbmap -option caps:super

pnmixer &
# Note: tint2 is started by XFCE session
