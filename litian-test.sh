#!/bin/bash

str=$(cat message.txt | tr -d '\n')
echo $str
