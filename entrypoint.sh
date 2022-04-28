#!/bin/bash
set -e

if [ ! -d "/dev/dri" ];then
  echo "WARNING: /dev/dri does not exists, the GPU is not available."
  export VGL_DISPLAY=":0.0"
fi

exec "$@"
