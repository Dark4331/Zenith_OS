<img width="1376" height="768" alt="zenith_OS" src="https://github.com/user-attachments/assets/3fda76db-dd83-4a03-90b7-718a6321c7be" />

# 🌌 Zenith OS [![Build container image](https://github.com/Dark4331/Zenith_OS/actions/workflows/build.yml/badge.svg)](https://github.com/Dark4331/Zenith_OS/actions/workflows/build.yml)

Zenith OS is an immutable, containerized operating system based on **Fedora Bootc** and derived from **Origami Linux**. It is engineered to deliver maximum stability, atomic system updates, and native out-of-the-box support for **NVIDIA** GPUs.

Thanks to the underlying `bootc` architecture, the entire operating system is managed, built, and distributed just like a standard OCI container image, making customization and deployment incredibly straightforward.

---

## 🚀 Key Features

* **Immutable Core:** A transactional system powered by `fedora-bootc`. System updates are strictly atomic: they either succeed completely or automatically roll back on failure.
* **NVIDIA Ready:** Pre-integrated and configured NVIDIA graphics drivers baked directly into the base image (via Origami-Nvidia).
* **Optimized File System:** Native `ext4` root file system configuration featuring automatic partition resizing.
* **Automated CI/CD:** Fully automated installation media and disk image generation powered by GitHub Actions.

---

## 🛠️ Repository Structure

* `Containerfile`: The blueprint of the operating system. Defines the base image, metadata overrides, core drivers, and custom tweaks.
* `.github/workflows/`: Contains the CI/CD automation workflows:
    * `build.yml`: Compiles and publishes the OS container image to GitHub Packages (GHCR).
    * `build-disk.yml`: Converts the container image into deployable bare-metal and virtual disk formats using `bootc-image-builder`.
* `disk_config/`: Partitioning and filesystem layout configurations:
    * `disk.toml`: Configuration profile used for the QCOW2 virtual disk image.
    * `iso.toml`: Configuration profile used for the Anaconda installer ISO.

---

## 📦 Generated Artifacts

The build workflow automatically produces two distinct types of artifacts, which can be downloaded as a `.zip` file from the **Actions** tab of your GitHub repository:

### 1. QCOW2 Image (`qcow2-image`)
A pre-installed, bootable virtual disk image.
* **Best for:** High-performance Type-1 and Type-2 virtualization environments like QEMU/KVM (`virt-manager`), Proxmox, or GNOME Boxes.
* **How to use:** Create a new virtual machine, select "Import existing disk image", and point it directly to this file.

### 2. Anaconda ISO (`anaconda-iso-image`)
A traditional bootable installer featuring the graphical Fedora Anaconda wizard.
* **Best for:** Bare-metal installations on physical hardware or traditional hypervisors (VirtualBox, VMware).
* **How to use:** Flash the ISO onto a USB drive using **Ventoy** (highly recommended for bootc deployments) or **Rufus** (written in DD Image mode), then boot your target machine from the USB drive.

---

## 🏗️ How to Trigger Disk Generation

The workflows are automated to trigger on specific file modifications, but they can also be launched on-demand.

To manually trigger a new image build:
1. Navigate to the **Actions** tab of your GitHub repository.
2. Select the **Build disk images** workflow from the left sidebar.
3. Click the **Run workflow** dropdown menu on the right.
4. Select your target platform architecture (`amd64` for standard desktop/server hardware with NVIDIA) and click the green **Run workflow** button.

---

## 👤 Credits and Technologies
* Powered by [Fedora Bootc](https://github.com/containers/bootc)
* Base configuration templates inspired by [Origami Linux](https://gitlab.com/origami-linux)
