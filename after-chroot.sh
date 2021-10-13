# Set the time zone
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

# Run hwclock to generate /etc/adjtime
hwclock --systohc

# Set locale to US
sed -i '/en_US.UTF-8/s/^#//g' /etc/locale.gen
locale-gen

# Create locale.conf
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Set hostname
echo 'archie' > /etc/hostname

# Add entries to /etc/hosts
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.1.1 archie' >> /etc/hosts

# Modify mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)/g' /etc/mkinitcpio.conf

# Setup vconsole.conf and
echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=ter-216n" >> /etc/vconsole.conf

# Create new initramfs (for system encryption)
mkinitcpio -P

# Set root passwd
passwd

# Bootloader setup
mkdir -p /boot/loader/entries
cat <<EOF > /boot/loader/entries/arch.conf
title Archlinux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options rw rd.luks.name=$(lsblk -no TYPE,UUID /dev/nvme0n1p2 | awk '$1=="crypt"{print $2}')=cryptroot rd.luks.options=discard root=UUID=$(lsblk -no TYPE,UUID /dev/nvme0n1p2 | awk '$1=="part"{print $2}')
EOF

cat <<EOF > /boot/loader/loader.conf
default arch.conf
editor no
EOF

#bootctl install
bootctl install
