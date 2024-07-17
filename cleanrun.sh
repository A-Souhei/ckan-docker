#!/bin/bash

docker compose down -v && docker compose build ckan && docker compose up -d
sudo chmod -R 777 $(pwd)/sources
