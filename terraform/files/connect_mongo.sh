#!/bin/bash
set -e
APP_DIR=${1:-$HOME}
echo 'export DATABASE_URL=$1:27017' >> $APP_DIR/.bash_profile