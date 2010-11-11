#!/bin/bash

nukestar_run "scp -rv nukestar01:/root/SerpentInstall/ /root/tmpSerpent/"
echo

nukestar_run "cd /root/tmpSerpent/ \&\& ./serpent_install.sh"
echo

nukestar_run rm -rv /root/tmpSerpent/

