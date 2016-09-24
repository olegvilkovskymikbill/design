#!/bin/bash

download="https://github.com/mikbill/distr/raw/master/radius/Dockerfile"

rm -f Dockerfile
wget "$download"
