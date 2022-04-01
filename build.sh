#!/usr/bin/env bash
docker compose down
sudo chown -R $USER:$USER .
rm -Rf ./Moodle/*
rm -Rf ./Moodle/.*
rm -Rf ./MoodleData/*
rm -Rf ./Database/*
docker-compose -f docker-compose-build-MYSQL.yml up --build -d
echo "done!"