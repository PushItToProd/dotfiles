#!/usr/bin/env bash

# usage: padversion [version]
# padversion pads a period-delimited version number to support lexicographical
# comparison between versions like 1.17.2 and 1.5.5 by transforming them to
# 001.017.002 and 001.005.005
padversion() {
  local versionstr="${1:?padversion requires an argument}"
  local -a version
  IFS=. read -r -a version <<<"$versionstr"

  printf '%03d.' "${version[0]}"
  local v
  for v in "${version[@]:1}"; do
    printf '.%03d' "${v}"
  done
}

apt_repo_exists() {
  grep -q "$1" /etc/apt/sources.list /etc/apt/sources.list.d/*.list
}