PG_DIR=/tmp # Set this for your environment
PLUGIN_DIR=${PG_DIR}/share/postgresql/extension
PLUGIN_LIB_DIR=${PG_DIR}/lib
NAME=heavy_hitters
VERSION := $(shell grep default_version heavy_hitters.control | perl -npe "s/.*?\'(.*)\'/\1/")

all:
	echo "Edit the Makefile to set PG_DIR, and then call 'make install'"

install:
	cp sql/${NAME}.sql ${PLUGIN_DIR}/${NAME}--${VERSION}.sql
	cp ${NAME}.control ${PLUGIN_DIR}/

