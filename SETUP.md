# Setting up Arch Linux

This guide will get Arch Linux installed on your system with as secure a system as possible;

- Encryted primary partition
- Disabled `root` user
- Firewall

## Prerequisites

1. [Arch Linux bootable USB](https://wiki.archlinux.org/title/USB_flash_installation_medium)

## Initial Set-up

### Connect to WiFi

```bash
iwctl
> device list
> station DEVICE connect SSID
> exit
timedatectl set-ntp true
```

### Partition Disk

```bash
fdisk -l
cfdisk /dev/nvme0nX
# Partition 1: 2GB, EFI Filesystem
# Partition 2: Remainder of space, Linux root (x86-64)
> write
```

### Encrypt Linux Root

```bash
cryptsetup luksFormat /dev/nvme0nXp2
cryptsetup open /dev/nvme0nXp2 root
```

### Create Filesystems

```bash
mkfs.fat -F32 /dev/nvme0nXp1
mkfs.ext4 /dev/mapper/root
```

### Mount Filesystems

```bash
mount /dev/mapper/root /mnt
mount --mkdir /dev/nvme0nXp1 /mnt/boot
```

### Create swapfile

```bash
free --mebi # Number under `total * 1.5` is `X`
dd if=/dev/zero of=/mnt/swapfile bs=1M count=X status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
```

### Install Arch Linux

```bash
pacstrap -K /mnt base base-devel linux linux-firmware nano sudo networkmanager efibootmgr git curl wget reflector nftables pipewire pipewire-alsa pipewire-pulse wireplumber
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

### Set Locales

```bash
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
nano /etc/locale.gen # Uncomment `en_US.UTF-8`
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

### Set the Hostname

```bash
echo 'HOSTNAME' > /etc/hostname
nano /etc/hosts
```

Hosts file:

```
127.0.0.1  localhost
::1        localhost
127.0.1.1  HOSTNAME.localdomain  HOSTNAME
```

### Set the root password

```bash
passwd
```

### Configure Initramfs

```bash
pacman -S amd-ucode # Or intel-ucode, based on CPU
nano /etc/mkinitcpio.conf
# add `encrypt` between `block` and `filesystems` and add `resume` between `filesystems` and `fsck`
mkinitcpio -P
```

### Install Bootloader

```bash
filefrag -v /swapfile | less # First number on line `0:` under `physical_offset` is `X`
blkid -s UUID -o value /dev/nvme0nXp2 # UUID for the partition is `Y`
efibootmgr --disk /dev/nvme0nX --part 1 --create --label "HOSTNAME" --loader /vmlinuz-linux --unicode 'cryptdevice=UUID=Y:root root=/dev/mapper/root resume=/dev/mapper/root resume_offset=X rw quiet splash initrd=\amd-ucode.img initrd=\initramfs-linux.img' --verbose # Change `amd-ucode` for `intel-ucode` if on an Intel system.
```

Depending on your system, you'll need to adjust for kernel parameters here - i.e. if using NVIDIA (god bless your soul), append `nvidia_drm.modeset=1`.

#### Framework 13 AMD

```bash
efibootmgr --disk /dev/nvme0nX --part 1 --create --label "HOSTNAME" --loader /vmlinuz-linux --unicode 'cryptdevice=UUID=Y:root root=/dev/mapper/root resume=/dev/mapper/root resume_offset=X rw quiet splash rtc_cmos.use_acpi_alarm=1 amdgpu.sg_display=0 amd_iommu=off acpi_osi="!Windows 2020" initrd=\amd-ucode.img initrd=\initramfs-linux.img' --verbose
```

Utilizes some kernel params for various fixes listed [in the Arch Wiki for Framework](https://wiki.archlinux.org/title/Framework_Laptop_13).

### Ensure NetworkManager is always running

```bash
systemctl enable NetworkManager
```

### Done!

```bash
exit
shutdown now
# Remove the Arch Linux USB - it's no longer needed!
```

## Post-install Set-up

### Connect to WiFi (again)

```bash
nmtui
```

### Add your User

```bash
EDITOR=nano visudo # Uncomment `%wheel ALL=(ALL) NOPASSWD: ALL`
useradd --create-home --groups wheel MY_USERNAME # Replace MY_USERNAME with your desired username
passwd MY_USERNAME
exit
# Log-in with your new user!
sudo passwd --lock root # Lock the root user from being logged in with
```

### Enable multilib repo

```bash
sudo nano /etc/pacman.conf # Uncomment all entries under `[multilib]`
sudo pacman -Suy
```

### Install `trizen`

The _best_ AUR helper!

```bash
git clone https://aur.archlinux.org/trizen.git
cd trizen
makepkg -si
```

### Set-up Firewall

TODO:

### Enable some maintainance services

```bash
sudo systemctl enable systemd-timesyncd.service --now
sudo systemctl enable fstrim.timer --now
sudo nano /etc/xdg/reflector/reflector.conf # Set your country!
sudo systemctl enable reflector.timer --now
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```

### Set-up `xdg-user-dirs`

```bash
sudo pacman -S xdg-user-dirs
```

`~/.config/user-dirs.dirs`:

```
TODO:
```

### Set-up `oh-my-zsh`

```bash
trizen -Sy zsh
chsh -s $(which zsh)
logout
# Log back in
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Using an ASUS Laptop?

Check out [ASUS Linux](https://asus-linux.org) for instructions on setting up the custom asus kernel and utilities.
