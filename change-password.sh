echo "Please input Your Password"
read -s password
sed -i "s/\*\*\*\*\*\*/${password}/g" ./after-disk-partitioned.sh
echo "Password changed successfully"
