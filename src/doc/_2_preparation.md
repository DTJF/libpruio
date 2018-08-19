Preparation {#ChaPreparation}
===========
\tableofcontents

This chapter describes how to get libpruio working on your system. The
easy way is to install the Debian packages. They're not in mainline,
yet. So you have to add a PPA (Personal Package Archive) to your
package management sources:

~~~{.txt}
sudo add-apt-repository "deb http://beagle.tuks.nl/debian unstable main"
sudo add-apt-repository "deb-src http://beagle.tuks.nl/debian unstable main"
wget -qO - http://beagle.tuks.nl/debian/public.key | sudo apt-key add -
~~~

Once prepared, you can download the library, the header files and the
documentation by executing

~~~{.txt}
sudo apt-get install libpruio libpruio-dev libpruio-doc
~~~

The further stuff in this chapter is for advanced users who want to
adapt the source code and recompile the binary.


# Tools  {#SecTools}

The further files in this package are related to the version control
system GIT and to automatical builds of the examples and the
documentation by the cross-platform CMake build management system. If
you want to use all package features, you can find in this chapter
information on

- how to prepare your system by installing necessary tools,
- how to get the package using GIT and
- how to automatical build the examples and the documentation.

The following table lists all dependencies for the \Proj package and
their types. At least, you have to install the FreeBASIC compiler on
your system to build any executable using the \Proj features. Beside
this mandatory (M) tools, the others are optional. Some are recommended
(R) in order to make use of all package features. LINUX users find some
packages in their distrubution management system (D), or pre-installed
(I).

|                                               Name  | Type |  Function                                                      |
| --------------------------------------------------: | :--: | :------------------------------------------------------------- |
| [fbc](http://www.freebasic.net)                     | M    | FreeBASIC compiler to compile the source code                  |
| [fb_prussdrv](https://github.com/DTJF/fb_prussdrv)  | M    | PRU assembler to compile PRU code and libprussdrv              |
| [dtc](https://git.kernel.org/cgit/utils/dtc/dtc.git)| M  I | Device tree compiler to create overlays                        |
| [GIT](http://git-scm.com/)                          | R  D | Version control system to organize the files                   |
| [CMake](http://www.cmake.org)                       | R  D | Build management system to build executables and documentation |
| [cmakefbc](http://github.com/DTJF/cmakefbc)         | R    | FreeBASIC extension for CMake                                  |
| [fb-doc](http://github.com/DTJF/fb-doc)             | R    | FreeBASIC extension tool for Doxygen                           |
| [Doxygen](http://www.doxygen.org/)                  | R  D | Documentation generator (for html output)                      |
| [Graphviz](http://www.graphviz.org/)                | R  D | Graph Visualization Software (caller/callee graphs)            |
| [LaTeX](https://latex-project.org/ftp.html)         | R  D | A document preparation system (for PDF output)                 |

It's beyond the scope of this guide to describe the installation for
those tools. Find detailed installation instructions on the related
websides, linked by the name in the first column.

-# First, install the distributed (D) packages of your choise, either mandatory
   ~~~{.txt}
   sudo apt-get install git cmake
   ~~~
   or full install (recommended)
   ~~~{.txt}
   sudo apt-get install dtc git cmake doxygen graphviz doxygen-latex texlive
   ~~~

-# Then make the FB compiler working:
   ~~~{.txt}
   wget https://www.freebasic-portal.de/dlfiles/625/freebasic_1.06.0debian7_armhf.deb
   sudo dpkg --install freebasic_1.06.0debian7_armhf.deb
   sudo apt-get -f install
   ~~~

-# Then make the FB version of prussdrv working:
   ~~~{.txt}
   git clone https://github.com/DTJF/fb_prussdrv
   cd fb_prussdrv
   sudo su
   cp bin/libprussdrv.* /usr/local/lib
   ldconfig
   mkdir /usr/local/include/freebasic/BBB
   cp include/* /usr/local/include/freebasic/BBB
   cp bin/pasm /usr/local/bin
   exit
   cd ..
   ~~~

-# Continue by installing cmakefbc (if wanted). That's easy, when you
   have GIT and CMake. Execute the commands
   ~~~{.txt}
   git clone https://github.com/DTJF/cmakefbc
   cd cmakefbc
   mkdir build
   cd build
   cmake ..
   make
   sudo make install
   cd ../..
   ~~~
   \note Omit `sudo` in case of non-LINUX systems.

-# And finaly, install fb-doc (if wanted) by using GIT and CMake.
   Execute the commands
   ~~~{.txt}
   git clone https://github.com/DTJF/fb-doc
   cd fb-doc
   mkdir build
   cd build
   cmake ..
   make
   sudo make install
   ~~~
   \note Omit `sudo` in case of non-LINUX systems.


# Get Package  {#SecGet}

Depending on whether you installed the optional GIT package, there're
two ways to get the \Proj package.

## ZIP  {#SecGet_Zip}

As an alternative you can download a Zip archive by clicking the
[Download ZIP](https://github.com/DTJF/girtobac/archive/master.zip)
button on the \Proj website, and use your local Zip software to unpack
the archive. Then change to the newly created folder.

\note Zip files always contain the latest development version. You
      cannot switch to a certain point in the history.


## GIT  {#SecGet_Git}

Using GIT is the prefered way to download the \Proj package (since it
helps users to get involved in to the development process). Get your
copy and change to the source tree by executing

~~~{.txt}
git clone https://github.com/DTJF/libpruio
cd libpruio
~~~


# Configuration  {#SecConfig}

Before you can use \Proj you have to make sure that your system is
prepared. This means

- \ref sSecPrepBuild : prepare the source tree for your system.
- \ref sSecPruDriver : block `rproc`, make the system load `uio_pruss`.
- \ref sSecDtboFile : load a pinmux file for custom or universal pinmuxing.

Use cmake/cmakefbc for your work. Building and installing the software
manually is a complex process. It isn't described here, since it's
beyond the scope of this documentation.


## Prepare build  {#sSecPrepBuild}

The project either supports in-source or out-of-source building. The
later is more easy to understand and to handle, since the source code
doesn't change (much). Mostly all generated files go into a separate
`build` folder:

~~~{.txt}
mkdir build
cd build
cmakefbc ..
~~~

When the script fails, solve the problems first before you continue.


## PRU driver  {#sSecPruDriver}

Unfortunatelly this step may get complicated. \Proj needs the uio_pruss
driver. In kernel 3.8 this is default, no further action is necessary.
But in kernel 4.x the new rproc driver gets default, and it took years
until easy reconfiguration was supported. Depending on the kernels
subversion, different action has to be done to get it out of the way.
It's beyond the scope of this documentation to describe all the diffent
quirks and pitfalls. Search the internet for further documentation.

The only help I can provide is a command to test success. Executing

    lsmod | grep uio

should output

~~~{txt}
uio_pruss              16384  0
uio_pdrv_genirq        16384  0
uio                    20480  2 uio_pruss,uio_pdrv_genirq
~~~


## LKM  {#sSecLkm}

The loadable kernel module (LKM) for libpruio has three purposes

-# enable the PRUSS, if not running
-# fix a kernel 4.x problem (PWMSS-Pwm output disabled)
-# support for \Proj pinmuxing

Build the LKM by executing

    make lkm

Installation is a bit more difficult. The official way is to install
the module in folder `/lib/modules/$(uname -r)/extra`, where `$(uname
-r)` is the version of the current kernel running. This has the
advantage that the module exactly matches the kernel specifications and
the tool `modprobe` can handle intelligently loading. But the downside
is that you have to re-build and re-install the module each time when
the kernel changes (ie. when `apt upgrade` installs an kernel update).
For this type of installation execute

    make lkm-vers-install

Alternatively \Proj provides a further install method where the binary
is located in folder `/lib/modules` and doesn't get affected by kernel
updates, but cannot get reached by the tool `modprobe` there. A
`systemctl` service gets installed and enabled to load the module at
boot time. For this type of installation execute

    make lkm-glob-install

After the next boot the LKM will be auto-loaded, and you can use
`systemctl` features for further handling. At runtime for the current
session, execute

    sudo systemctl stop libpruio.service

to unload the module, and

    sudo systemctl start libpruio.service

to re-load it again. Or in generally for the next boots, execute

    sudo systemctl disable libpruio.service

to disable auto-loading at boot-time, and

    sudo systemctl enable libpruio.service

to enable auto-loading at boot-time.


# Build Binary  {#SecBuildBin}

Compile the source code and install by executing (in `build` folder):

~~~{.txt}
make
sudo make install
sudo ldconfig
~~~

\note The last command `sudo ldconfig` is only necessary after first
      install. It makes the newly installed library visible for the
      linker. You can omit it for further updates.


# Build Examples  {#SecBuildExamples}

In the that same build folder, build the examples by:

~~~{.txt}
make examples
~~~

That will build both, the FreeBASIC and the C examples. To run them execute ie.

~~~{.txt}
src/examples/1
~~~

to run the `1.bas` example, or

~~~{.txt}
src/c_examples/1_c
~~~

to run the `1.c` example.

The build scripts also support separate builds

~~~{.txt}
make fb_examples
make c_examples
~~~

\note In order to build the examples you have to build and install the
      library binary first, see section \ref SecBuildBin.


# Build Documentation  {#SecBuildDoc}

In the that same build folder, build the documentation by:

~~~{.txt}
make doc
~~~

This will build the html tree (in `doxy/html`) and a pdf version (in
the current folder) of the documentation content. The build scripts
also support separate builds

~~~{.txt}
make doc_htm
make doc_pdf
~~~


# Build Python Binding  {#SecBuildPython}

In order to execute the Python examples, you have to generate a
ctypes-based python binding for the library fist. To build a fresh file
from the current FB source code execute

~~~{.txt}
make python
~~~

Find the resulting file `pruio.py` in folder `src/python/libpruio`.

\note `fb-doc` and its plugin `py_ctype` are mandatory for that target.


## DTBO File  {#sSecDtboFile}

The device tree blob (DTBO) for libpruio has two purposes

-# enable the PRUSS
-# set pinmuxing

While the first is mandatory, the second may get done in diffent ways:

- Either a custom configuration with the necessary setting for your project (header connections).
- Or a universal setting that allows you to change pinmuxing at runtime.

The later is very flexible in development phase while you design and
test your PCB (hardware board), by the cost of high memory consumption
and slow booting. At the beginning this is the prefered solution.

\Proj is prepared to generate and install an universal overlay for the
BeagleBoneBlack hardware by executing

    sudo make dtconf

This compiles and runs the `dts_universal.bas` code in folder
src/config, which generates a `libpruio-00A0.dts` file. That file gets
compiled to the final destination `/lib/firmware`. Afterward you have
to make sure that the overlay gets loaded:

- kernel 3.8: use capemgr to load the overlay.

- kernel 4.x: bootload the overlay. Depending on the subversion
  different action has to be done. It's beyond the scope of this
  documentation to describe all the diffent approaches.


# Build Debian Package  {#SecBuildDeb}

In the that same build folder, build the Debian packages by:

~~~{.txt}
make package
~~~

This will create the packages

- libpruio-bin.deb contains the runtime binary and the overlay
- libpruio-dev.deb contains the C header files
- libpruio-fbdev.deb contains the FreeBASIC header files
