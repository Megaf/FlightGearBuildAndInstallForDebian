#!/bin/bash

alias cmake="cmake -DCMAKE_BUILD_TYPE=Release"

export FG_INSTALL_DIR=$HOME/Downloads/FlightGear
export FG_SRC_DIR=$HOME/Downloads/FlightGear_Sources
export PATH=/usr/lib/ccache:$PATH

mkdir $FG_INSTALL_DIR
mkdir $FG_SRC_DIR

OSGVER="OpenSceneGraph-3.6.3"
SGVER="next"
FGVER="next"
DATAVER="next"

# Building PLib
cd $FG_SRC_DIR
git clone --depth=1 git://git.code.sf.net/p/libplib/code libplib.git
cd libplib.git
echo "1.8.6" > version
sed s/PLIB_TINY_VERSION\ \ 5/PLIB_TINY_VERSION\ \ 6/ -i src/util/ul.h
git commit --all --message "Increase tiny version to 6."
mkdir $FG_SRC_DIR/build-plib && cd $FG_SRC_DIR/build-plib
cmake -DCMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/libplib.git
make -j$(nproc) && make install

# Building OpenSceneGraph
cd $FG_SRC_DIR
git clone --depth=1 --branch $OSGVER git://github.com/openscenegraph/OpenSceneGraph.git OpenSceneGraph.git
mkdir $FG_SRC_DIR/build-osg && cd $FG_SRC_DIR/build-osg
cmake -DLIB_POSTFIX="" -DCMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/OpenSceneGraph.git
make -j$(nproc) && make install

# Building SimGear
cd $FG_SRC_DIR
git clone --depth=1 --branch=$SGVER git://git.code.sf.net/p/flightgear/simgear simgear.git
mkdir $FG_SRC_DIR/build-sg && cd $FG_SRC_DIR/build-sg
cmake -DCMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/simgear.git
make -j$(nproc) && make install

# Building FlightGear
cd $FG_SRC_DIR
git clone --depth=1 --branch=$FGVER git://git.code.sf.net/p/flightgear/flightgear flightgear.git
mkdir $FG_SRC_DIR/build-fg && cd $FG_SRC_DIR/build-fg
cmake -DFG_DATA_DIR:PATH="$FG_INSTALL_DIR/share/fgdata" -DCMAKE_INSTALL_PREFIX:PATH="$FG_INSTALL_DIR" $FG_SRC_DIR/flightgear.git
make -j$(nproc) && make install

# Downloading FGDATA
mkdir -p $FG_INSTALL_DIR/share && cd $FG_INSTALL_DIR/share
git clone --depth=1 --branch=$DATAVER git://git.code.sf.net/p/flightgear/fgdata fgdata

# Setting Environment Variables and aliases.
echo "export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH" >> $HOME/.bashrc
echo "alias fgfs=$FG_INSTALL_DIR/bin/fgfs" >> $HOME/.bashrc
