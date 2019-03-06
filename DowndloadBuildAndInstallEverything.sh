#!/bin/bash

# Author: Megaf Cassini (mmegaf <at> gmail <dot> com)
# License: MGF License https://gist.github.com/Megaf/a4a131027db7deb612c71556886a300a

## ABOUT
# Greetings, this script will download and compile PLib, OpenSceneGraph, SimGear and FlightGear from their SVN/Git repos.
# They will be located at your home/Downloads folder.

# This is a rather stupid script, no checks are done yet, it is just a sequence of commands.
# Read the commends on the script to lear more about it.


## TODO
# Make it KISS
# Make it do checks

# alias to make sure Release will be default build type for everything, more flags can me added here as well.
alias cmake="cmake -DCMAKE_BUILD_TYPE=Release"

# Variable to set where FlighGear will be "installed.
export FG_INSTALL_DIR=$HOME/Downloads/FlightGear
# Variable to set where the source code will be downloaded to.
export FG_SRC_DIR=$HOME/Downloads/FlightGear_Sources
# Variable to use ccache in case you have it installed, it will greatly speed rebuilds.
export PATH=/usr/lib/ccache:$PATH

# Creating Install and Download directories.
mkdir $FG_INSTALL_DIR
mkdir $FG_SRC_DIR

# Setting branch/versions for stuff.
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
