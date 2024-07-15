#!/bin/bash

docker compose build && docker compose up -d

docker logs -f ckan-docker-ckan-1

