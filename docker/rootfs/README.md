# Install Docker
NOTE: If you see error during installation, then search on the internet how to install docker and qemu for your os. During time this steps can be different as you expect.

Lets install dependencies.

```bash
# Add Docker's official GPG key:
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$ sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Set up stable repository for docker
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
```
Install related packages for Docker

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Verify installation with hello-world image

```bash
$ sudo docker run hello-world
```

Lets manage user permission for Docker. Docker uses UDS so permission is needed.
```bash
$ sudo usermod -aG docker ${USER}
$ su - ${USER}
$ sudo systemctl enable docker
```

We also need to install QEMU, with it, it is possible to emulate/run raspbian os like it is on real raspberry pi 4 hardware

```bash
$ sudo apt install qemu-system-x86 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
```

Enable and Start Libvirt:
```bash
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```

Add Your User to the Libvirt and KVM Groups:

```bash
$ sudo usermod -aG libvirt $(whoami)
$ sudo usermod -aG kvm $(whoami)
```

Verify Installation:
```bash
$ virsh list --all
```

You should see an empty list.

Set up QEMU for multi-architecture support
```bash
$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Create and use a new Buildx builder instance
```bash
$ docker buildx create --use --name mybuilder
$ docker buildx inspect mybuilder --bootstrap
```

Verify Buildx installation
```bash
$ docker buildx ls
```

# Compile Qt 6.9.1 with Docker

When I experimented with this idea, I expected to create a single Dockerfile with different stages, allowing me to switch between them even if they involved different hardware architectures. However, it didn't work as expected, so I ended up creating two separate Dockerfiles.

First, we will create a Raspbian (Debian-based) environment and emulate it. Then, we need to copy the relevant headers and libraries for later compilation

Run the command to create rasbian(debian) image.
```bash
$ docker buildx build --platform linux/arm64 --load -t crossbuild-rootfs -v build:/build .
```
When it finishes, you will find a file named 'rasp.tar.gz' in the '/build' directory within the image.
Let's copy it to the same location where the Dockerfile exists. Just copy it to where you pulled the branch.
To copy the file, you need to create a temporary container using the 'create' command. You can delete this temporary container later if you wish
```bash
$ docker create --name temp-arm raspimage
$ docker cp temp-arm:/build/rasp.tar.gz ./rasp.tar.gz
```
This rasp.tar.gz file will be copied by the another image that is why location of the tar file is important. You do not need to extract it. Do not touch it.