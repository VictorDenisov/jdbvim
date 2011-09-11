#!/bin/bash

java -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=y Test
