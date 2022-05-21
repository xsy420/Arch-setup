# https://www.jianshu.com/p/619274de1935
function is_change_password() {
  if [ $( grep "send" ./after-disk-partitioned.sh | grep -c "*" ) == 3 ] ; then
    echo "You have not change your password"
    echo "Please execuate ./change-password.sh"
    exit 1
  fi
}
is_change_password
timedatectl set-ntp true
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
cat china-mirrorlist > /etc/pacman.d/mirrorlist
sed -i "41c SigLevel = Never" /etc/pacman.conf
pacman -Syy expect
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed -i "41c SigLevel = Never" /mnt/etc/pacman.conf
cat china-mirrorlist > /mnt/etc/pacman.d/mirrorlist
echo "localhost" >> /mnt/etc/hostname
echo "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
echo "::1\t\tlocalhost" >> /mnt/etc/hosts
echo "127.0.0.1\tlocalhost.localdomain" >> /mnt/etc/hosts
/usr/bin/expect << EOF
spawn arch-chroot /mnt
expect "root"
send "pacman -Syy grub dhcpcd inetutils openssh efibootmgr\r"
expect "Y"
send "y\r"
expect "root"
send "grub-install --recheck /dev/sda --efi-directory=/boot\r"
expect "root"
send "grub-mkconfig -o /boot/grub/grub.cfg\r"
expect "root"
send "passwd\r"
expect "password"
send "******\r"
expect "password"
send "******\r"
expect "root"
send "systemctl enable sshd\r"
expect "root"
send "systemctl enable dhcpcd\r"
expect "root"
send "exit\r"
expect eof
EOF
umount /mnt/boot
umount /mnt
reboot
