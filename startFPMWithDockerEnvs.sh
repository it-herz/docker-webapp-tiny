#!/bin/bash

cd /etc/container-run.d/
for SCRIPT in `ls -1`
do
  if [ -f $SCRIPT -a -x $SCRIPT ]
  then
    ./$SCRIPT
  fi
done

supervisorctl start php7.0-fpm
