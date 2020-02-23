#! /usr/bin/env bash
PWD=$(pwd)
FPATH='/libs/UNIX/iup_installed/'
export LD_LIBRARY_PATH=$PWD$FPATH:$LD_LIBRARY_PATH
lua5.3 ItemGen.lua