#!/bin/bash

chmod -R a+rwx /profile
rm -f /profile/Singleton*
/startup.sh "$@"