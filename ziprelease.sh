#!/bin/sh

version=1.0
zipfile=../releases/soaprouter-$version.zip
exclude="$zipfile SOAP.doc ziprelease.sh *.svn*"

zip -r $zipfile * -x $exclude
