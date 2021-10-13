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

# Encrypt disk
cryptsetup -y -v luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot


# Create filesystems
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/mapper/cryptroot

# Mount file systems
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Update mirrorlist
reflector -c US --save /etc/pacman.d/mirrorlist

# Install essential packages
pacstrap /mnt base linux linux-firmware git vim man-db man-pages efibootmgr amd-ucode terminus-font

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into new system
arch-chroot /mnt
