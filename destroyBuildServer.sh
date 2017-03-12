#!/bin/bash

cnt=0

until vagrant destroy &> /dev/null; do
  if [[ $cnt > 30 ]]; then
    echo "Failed to destroy build server! This may get expensive."
    exit 1
  fi

  echo "Trying to destroy build server."
  ((cnt++))
  sleep 15
done

echo "Build server successfully destroyed."
