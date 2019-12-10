#!/bin/bash
redshift -c ~/.config/redshift.conf &
cwp -t 5 &
setxkbmap gb
setxkbmap -option caps:super
pnmixer &
