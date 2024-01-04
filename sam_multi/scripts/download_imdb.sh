#!/bin/bash
set -ex

mkdir -p datasets/job && pushd datasets/job

# 直接使用wget -c http://homepages.cwi.nl/~boncz/job/imdb.tgz下载会失败，会显示不安全的链接。需要手通过网址手动下载到本地，然后上传至服务器目录。
wget -c http://homepages.cwi.nl/~boncz/job/imdb.tgz && tar -xvzf imdb.tgz && popd

python3 scripts/prepend_imdb_headers.py
