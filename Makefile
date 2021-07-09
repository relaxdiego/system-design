.DEFAULT_GOAL := help

##
## Available Goals:
##

##   api      : Rebuilds and deploys the API component
##
.PHONY : api
api: tmp/last-build-api tmp/last-deployment-api

tmp/last-build-api: apps/api/Dockerfile apps/api/quipper/* apps/api/requirements-dev.txt apps/api/setup.py
	@scripts/build api
	@touch tmp/last-build-api

tmp/last-deployment-api: apps/api/api.yaml tmp/last-build-api
	@scripts/api-deployment apply
	@touch tmp/last-deployment-api

##   frontend : Rebuilds and deploys the UI component
##
.PHONY : frontend
frontend: tmp/last-build-frontend tmp/last-deployment-frontend

tmp/last-build-frontend: apps/frontend/Dockerfile apps/frontend/*.jpg apps/frontend/index.html
	@scripts/build frontend
	@touch tmp/last-build-frontend

tmp/last-deployment-frontend: apps/frontend/frontend.yaml tmp/last-build-frontend
	@scripts/frontend-deployment apply
	@touch tmp/last-deployment-frontend

# From: https://swcarpentry.github.io/make-novice/08-self-doc/index.html
##   help     : Print this help message
##
.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<
