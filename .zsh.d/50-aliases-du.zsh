# duhd wraps du for the common pattern of getting the biggest files in a
# directory with human-readable sizes.
duhd() {
  du -hd1 "$@" | sort -h
}

# tdu is an alias for tree --du with some useful defaults applied
tdu() {
  # --du reports the size of each directory
  # -s prints all file sizes
  # -h prints human-readable file sizes (e.g. 4.0K instead of 4000)
  # -a prints all files
  # -C forces colorization
  tree --du -shaC "$@" | less -R

  # XXX tree's --du flag only sums up the sizes of files that are visible in its
  # output, so if you combine it with -L or -d then some or all directories will
  # show up as 4.0K instead of reporting their child directory sizes. This is
  # fucking annoying.
}
