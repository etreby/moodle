#!bin/bash
docker compose down
rm -Rf ./Moodle/*
rm -Rf ./MoodleData/*
rm -Rf ./Database/*
docker-compose up --build