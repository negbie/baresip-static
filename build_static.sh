#!/bin/sh

# # # # # sudo docker run --rm=true -itv $PWD:/mnt debian:stretch-slim /mnt/build_static.sh
# # # # # sudo docker run --rm=true -itv $PWD:/mnt debian:buster-slim /mnt/build_static.sh

set -ex

apt update
apt install -y make gcc openssl git wget

cd /mnt
mkdir baresip-build
cd baresip-build

my_extra_lflags=""

git clone https://github.com/baresip/re.git
cd re; make libre.a; cd ..

git clone https://github.com/baresip/rem.git
cd rem; make librem.a; cd ..

wget -nc "http://downloads.xiph.org/releases/opus/opus-1.3.1.tar.gz"
tar -xzf opus-1.3.1.tar.gz
cd opus-1.3.1; ./configure; make; cd ..
mkdir opus; cp opus-1.3.1/.libs/libopus.a opus/
mkdir -p my_include/opus
cp opus-1.3.1/include/*.h my_include/opus/ 

git clone https://github.com/baresip/baresip.git
cd baresip;

make LIBRE_SO=../re LIBREM_PATH=../rem STATIC=1 \
    MODULES="opus stdio ice menu g711 turn stun uuid account auloop contact" \
    EXTRA_CFLAGS="-I ../my_include" EXTRA_LFLAGS="$my_extra_lflags -L ../opus"
    
cp baresip /mnt/baresip
rm -rf /mnt/baresip-build

