# My Arch Hyprland Rice
***- Written by Dobby for Dobby***

Here’s how I should setup my Hyprland on Arch Linux—a page for my future self so you won’t have to ask ChatGPT on how to turn the audio on. Lol.
This is not meant to be for everyone. I am well aware that everything in this repo might be the most disgusting thing you'll find on GitHub, but idc much. This works for my use case.

---

## Chapter 01: Installing Base Arch

Let's embrace minimalism from here on out.

---

### Step 01: Preparing storage/disk
Before doing anything, let's begin by actually working on a clean drive. Since it's you, future me, I believe all your important files are already on cloud so let's proceed on wiping out the drive.
1. Find the disk where your Arch should live. If unsure, you can check it by writing
   ```bash
   lsblk
   ```
   Upon hitting enter, it should show the connected devices on the screen, and pick the one that you want to use. My current self has 128 GB of SDD and it is called `/dev/sda`.
2. We're now nuking any content inside your preferred disk, for the rest of this documentation, I will use `/dev/sda` but you should use whatever it is on your end. In the ***tty*** type in:
   ```bash
   cfdisk /dev/sda
   ```
3. Using the ***arrow keys*** and ***Enter key***, delete all the partitions that you will see and create 3 new partitions with these values:
	- 1st partition: `1G`
	- 2nd partition: `4G`
	- 3rd partition: *the rest of the remaining disk space*

	Partition 1 with will be used by the bootloader, partition 2 is for swap, and the 3rd is where `/mnt` lives.
	You may want to clear up the screen with `CTRL + L`.
5. Formatting the partitions
   - Start with where /mnt will be sitting, in my case, it is at `/dev/sda3` and we'll do EXT4 format.
		- ```bash
		   mkfs.ext4 /dev/sda3
		   ```
   - Then, for efi boot, we'll format it with FAT32
	   - ```bash
		 mkfs.fat -F32 /dev/sda1
		 ```
	- And lastly, make the swap partition with
		- ```bash
		  mkswap /dev/sda2
		  ```
6. Let's mount these 3 partitions now with this:
   ```bash
   # The mount partition first
   mount /dev/sda3 /mnt

   # Then the bootloader part
   mount --mkdir /dev/sda1 /mnt/boot/efi

   # Swap does not need to be mounted, let's just activate it
   swapon /dev/sda2
   ```
   Then verify if everything is mounted correctly.
   To check, run
   ```bash
   lsblk
   ```
   And you should see that the `sda1` is mounted to `/mnt/boot/efi`, the `sda2` is to `[SWAP]`, and finally, the `sda3` is to `/mnt`.

---

### Step 02: Installing base packages

Now comes the fun part—actually installing the Linux everyone's talking about.

On ***tty***, type in:
```bash
pacstrap -K /mnt base linux linux-firmware sof-firmware base-devel nvim grub efibootmgr networkmanager intel-ucode
```
To quickly break this down
- `base`, `linux`, and `linux-firmware` is what makes linux, linux (duh) 
- `sof-firmware` for your audio
- `base-devel` is essential for building softwares from source—like from AUR.
- `nvim` instead of nano. nvim is arguably better.
- `grub` will be the ***bootloader***
- `efibootmgr` will handle the bootloader
- `networkmanager` so we're not offline
- `intel-ucode` for my cpu's microcode.

---

### Step 03: Generate fstab
I don't want to mansplain this just do 
```bash
genfstab -U /mnt
```
Then confirm if your disk partition is showing up. If it's all good, do
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

---

### Step 04: Enter the Arch root environment
Just do
```bash
arch-chroot /mnt
```
You may wanna clear up the screen at this point with `CTRL + L`.

---

### Step 05: Language, Localization, and Setting up the root and user profiles

Now's probably the most confusing part so follow along.

1. Setup the local timezone
   ```bash
   # Create a symlink of your zoneinfo to /etc/localtime
   ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime

   # Synchonize the clock
   hwclock --systohc
   ```
2. Set locale-gen
   ```bash
   # This adds a new line to an existing /etc/locale.gen file where the encodings are found
   echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

   # Sync locale
   locale-gen

   # Generate locale.conf
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```
3. Set hostname
   ```bash
   echo "Dobby-On-Arch" > /etc/hostname
   ```
4. Setup root password
   ```bash
   passwd
   ```
   Then just type in your preferred password twice to confirm.
5. Add user, and set a password for it
   ```bash
   # Add user to 'wheel' group
   useradd -mG wheel -s /bin/bash dobby

   # Setup user password
   passwd dobby
   ```
   Setup the user's password like so. the '*dobby*' here is my preferred user so you can change it to suit your taste.
6. Add the user to ***sudoers***
   ```bash
   EDITOR=nvim visudo
   ```
   Find the line that says `%wheel ALL=(ALL:ALL) ALL`. Usually it's around the very bottom so what you can do is to hit `SHIFT + G` on your keyboard, and just look a bit further up. You don't have to enter vim's ***insert mode***, just use the `delete` key on the keyboard to remove the '`#`' (to uncomment it). After uncommenting, do `:wq` to write and quit nvim. 
   Congrats! You're now a sudoer and abuse `sudo` on online scripts that you don't understand 🫵.

---

### Chapter 06: Setting up grub
Now, let's give some love to grub.
```bash
# Install grub to the linux drive
grub-install /dev/sda

# Generate the grub config
grub-mkconfig -o /boot/grub/grub.cfg
```

---

### Chapter 07: Enable network
You're still in Arch's live ISO environment. Time to enable the network for Arch itself.
```bash
systemctl enable NetworkManager
```

---

At this point, we're all set. What you want to do now is to exit arch root with
```bash
exit
```
Then unmount all the drive to prepare for reboot.
```bash
# Umount drives
umount -a

# Reboot
reboot
```

Now, unplug the drive where the Arch ISO is in to boot to arch's ***tty***.

This sums up the first chapter.


Page 2

## Chapter 02: Installing needed softwares

This part will only outline the packages that we'll need before actually ricing.

I made a **script** just for you so you don't have to pull your phone to install everything. Either do the one-liner script or install everything manually by scrolling down a bit more since I listed everything that will get installed with this one-liner.
```bash
bash <(curl -fsSL https://tinyurl.com/Installer-Sh)
```

---

### Essential softwares
- `hyprland` = The Wayland tiling WM
- `wofi` - The launcher
- `swaync` - Notification daemon
- `swww` - Wallpaper daemon
- `waybar` - Status bar
- `thunar` - GUI File explorer
- `brave-bin` - Browser
- `hyprpolkitagent` - I don't know but needed
- `hyprshot` - Screenshot utility
- `matugen-bin` - Auto color-picket
- `kitty` - Terminal emulator
- `sddm` - Display manager
- `gvfs` - Something with disk mounting, idk
- `xdg-desktop-portal` `xdg-desktop-portal-wlr` - Dialogs
- `libinput` - Input devices
- `wayland-protocols` - "Hey, speak Wayland"
- `pavucontrol` = GUI audio control
- `pipewire` `pipewire-pulse` `alsa-utils` `wireplumber` - Audio services
- `ufw` - Firewall
- `mpv` - Media player
- `xdg-user-dirs` - Auto handle main user dirs
- `fontconfig` - Font management
- `lxappearance` - GTK apps theming
- `qt5ct` - QT5 apps theming
- `qt6ct` - QT6 apps theming

---

### Fonts!!!
- `ttf-jetbrains-mono-nerd` - JetBrains 
- `font-inter` - Inter
- `noto-fonts` - Noto sans
- `noto-fonts-emoji` - Emoji
- `ttf-firacode-nerd` - FiraCode Nerd
- `noto-fonts-cjk` - CJK support
