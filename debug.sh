#!/bin/bash

docker compose down ckan_docker-ckan && docker rm ckan_docker-ckan && docker volume rm ckan_app_dir
docker compose build ckan && docker compose up -d ckan


