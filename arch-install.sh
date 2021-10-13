# Turn off PC beeps
rmmod pcspkr

# Set US keyboard layout
loadkeys us

# Change to better font
setfont ter-216n

# Update system clock
timedatectl set-ntp true

# Partition the SSD (found at /dev/nvme0n1)
parted --script /dev/nvme0n1 mkpart ESP fat32 1MiB 512MiB mkpart gpt 513MiB 100%

# Create filesystems
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# Mount file systems
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Update mirrorlist
reflector -c US --save /etc/pacman.d/mirrorlist

# Install essential packages
pacstrap /mnt base linux linux-firmware git vim man-db man-pages grub efibootmgr amd-ucode

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into new system
arch-chroot /mnt

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

# Create new initramfs (for system encryption)
mkinitcpio -p

# Set root passwd
passwd

# GRUB install
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg