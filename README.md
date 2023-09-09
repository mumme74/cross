# This is a docker recipe (Dockerfile)
## It creates a docker image with prebuild compiler and libs

You should be able to compile your C, C++ application to
MacOsX with from a linux host computer using this docker file.

It uses [osxcross](https://github.com/tpoechtrager/osxcross), see link.
you have to personally download a SDK from apple and promise to not re-distribute.
make sure you understand all implications.

## Usage
Go to [packaging the SDK](https://github.com/tpoechtrager/osxcross#packaging-the-sdk) and make sure you retrived a SDK from apple.
You might have som success using the tools from [osxcross](https://github.com/tpoechtrager/osxcross/tree/master/tools)
Else you have to package it on a real macosx computer.

Once you have your SDK tarball, copy it to the SDKs folder in this repo.
It might be MacOSC11.1.sdk.tar.xz for example, name might differ, depending on your version.

You can have multiple SDKs in this folder and all will be copied to the docker file when building.

## Install docker engine
Make sure you have docker installed, follow [docker guide](https://docs.docker.com/engine/install/)
On ubuntu its:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Make sure it works:
```
sudo docker run hello-world
```

## buils lding
To build you have to be in this dir in a terminal. This is because docker copies the files form this dir
First it selects the packages needed to our host (our linux docker image)
Then it compiles a cross compiler for mac (osxcross)
Then it downloads some base libraries from internet and compiles them in order
Last it compiles Qt
```
docker build -f Dockerfile.osxcross.x86_64.qt6 .
```
Building takes a long while, several hours.
If all goes well you should get a image hash from docker

Create a new docker container from this image when you want to compile your application.
```

```


