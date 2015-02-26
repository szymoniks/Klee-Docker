# Klee-Docker

## Intro
Docker is a relatively recent technology that developers and sysadmins use to build, ship, and run distributed applications. Compared to virtual machines, docker is more lightweight and efficient, since it provides an additional layer of abstraction of operating-system-level virtualization. You can read more about it at https://www.docker.com/.

## Building
To install docker, please follow the guide at https://docs.docker.com/installation/#installation. After the installation and cloning our project, you can simply execute the following command from the project root directory to build Klee:

```
$sudo docker build -t [image_name] .
```

Where image_name can be any name for the final image one fancies! :) By default, the number of jobs for make commands is 5, which one can change it in Dockerfile to adjust for their machine’s specification. We address the security concerns of sudo-ing this script below.

This command builds Klee, following the instruction in the guide on http://klee.github.io/getting-started/ as of 26/02/2015. The image is based on an official Ubuntu 14.04 docker image and will be supplied with LLVM-GCC 2.9, LLVM 2.9, STP r940 and uclibc (provided by Klee community at https://github.com/klee/klee-uclibc.git).

## Usage

To work in the virtualized environment where Klee is installed, type the command:

```
$sudo docker run -t -i [image_name] /bin/bash
```

Again, we address the security concerns of sudo-ing this script below.
We used the following options:
  * -i : keep STDIN open even if not attached
  * -t : allocate a pseudo-TTY

For more information, please read Docker README or check https://docs.docker.com/reference/commandline/cli/.

Please feel free to contact us with any questions.

## Security

Docker has been used and trusted by different companies, such as Gilt Groupe Inc., Yelp, and Baidu Inc, so we believe it does not contain any trojans or malware.

We have used Docker version 1.2.0 and Klee is built on Ubuntu 14.04.

The docker daemon always runs as the root user, and since Docker version 0.5.2, the docker daemon binds to a Unix socket instead of a TCP port. By default that Unix socket is owned by the user root, and so, by default, you need to access it with sudo.

Starting in version 0.5.3, if you (or your Docker installer) create a Unix group called docker and add users to it, then the docker daemon will make the ownership of the Unix socket read/writable by the docker group when the daemon starts. The docker daemon must always run as the root user, but if you run the docker client as a user in the docker group then you don't need to add sudo to all the client commands. As of 0.9.0, you can specify that a group other than docker should own the Unix socket with the -G option. However, the docker group (or the group specified with -G) is root-equivalent.

You can verify that the script does nothing more by inspection. The secure hash of the Dockerfile and two patches can be found in the checksum file.
