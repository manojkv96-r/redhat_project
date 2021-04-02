date=$(date)
val=$(echo $date | awk '{print $2,$3,$4,$6'})
str="${val// /_}"
node=$(hostname)
echo $node
w -i -f > connected_users_$node_$str.log
