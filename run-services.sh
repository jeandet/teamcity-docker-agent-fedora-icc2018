#!/bin/bash

Xvfb :99 &
export DISPLAY=:99
source /opt/intel/bin/ifortvars.sh -arch intel64 -platform linux
source /opt/intel/bin/iccvars.sh -arch intel64 -platform linux

echo '/run-services.sh'

for entry in /services/*.sh
do
  echo "$entry"
  if [[ -f "$entry" ]]; then
      [[ ! -x "$entry" ]] && (chmod +x "$entry"; sync)
      "$entry"
  fi
done

echo '/run-agent.sh'
exec '/run-agent.sh'
