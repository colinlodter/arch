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
sed 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)/g' /etc/mkinitcpio.conf

# Setup vconsole.conf and
echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=ter216n" >> /etc/vconsole.conf

# Create new initramfs (for system encryption)
mkinitcpio -P

# Set root passwd
passwd

# GRUB install
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
