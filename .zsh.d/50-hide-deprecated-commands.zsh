# alias nslookup='echo "nslookup is deprecated - you should use dig or host instead.\n  see also: http://blog.smalleycreative.com/linux/nslookup-is-dead-long-live-dig-and-host/"'

nslookup() {
  local arg name server
  for arg; do
    [[ "$arg" == -* ]] && continue
    [[ "$name" == "" ]] && name="$arg" || server="$arg"
  done
  local dig_cmd host_cmd

  [[ "$server" ]] && dig_cmd="dig @$server $name" || dig_cmd="dig $name"
  host_cmd="host $name $server"

  echo 'Hey! nslookup is deprecated. :) Try dig or host instead:'
  echo "  $dig_cmd"
  echo "  $host_cmd"
  echo 'see also: http://blog.smalleycreative.com/linux/nslookup-is-dead-long-live-dig-and-host/'
}

ifconfig() {
  echo 'Hey! ifconfig is deprecated. Try using ip instead: https://www.redhat.com/sysadmin/ifconfig-vs-ip'
}