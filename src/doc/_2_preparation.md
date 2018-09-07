Preparation {#ChaPreparation}
===========
\tableofcontents

This chapter describes several methods to get \Proj working on your
system:

-# \ref SevDebPac installing, or
-# \ref SecSourceTree compilation and installing

The first one is for easy consuming the software service "as is", the
last offers the chance to partizipate in development and optimize the
software to your custom needs, but is less convenient.


# Debian Packages # {#SevDebPac}

The easy way to benefit from \Proj is to install the Debian packages.
They're not in mainline, yet. So you have to add a PPA (Personal
Package Archive) to your package management sources. On the default
Debian operating system, edit the file `sudo nano
/etc/apt/sources.list` and add the lines:

    deb http://beagle.tuks.nl/debian jessie/
    deb-src http://beagle.tuks.nl/debian jessie/

Then grep the keyring by (mind the '-' character at the ende)

    wget -qO - http://beagle.tuks.nl/debian/public.key | sudo apt-key add -

Once prepared, you can update your package manager database

    sudo apt-get update

and finaly download and install the packages for your prefered
programming language:

 Size | Name                         | Description
----: | :--------------------------- | :--------------------------
1.2MB | libpruio_0.6.0.tar.xz        | source code
 45kB | libpruio_0.6.0_armhf.deb     | shared lib binary and LKM
 18kB | libpruio-dev_0.6.0_armhf.deb | examples/bindings C
 27kB | libpruio-bas_0.6.0_armhf.deb | examples/bindings FreeBASIC
 18kB | python-pruio_0.6.0_armhf.deb | examples/bindings Python
 80kB | libpruio-bin_0.6.0_armhf.deb | executable examples
  8kB | libpruio-lkm_0.6.0_armhf.deb | loadable kernel module
4.1MB | libpruio-doc_0.6.0_all.deb   | documentation (html-tree)

The first package contains all source code, and the second contains the
binary executable of the shared library, which gets linked at runtime
to related programs. The tripple -dev, -bas and python-pruio contain
language bindings for C, FreeBASIC and Python programming languages,
and example source code. The -bas package contains additional examples
with graphical output. In order to use the
library for your projrect, you'll need at least a language binding for
your prefered programming language and the shared library package.

The remaining packages are optional. All -bas examples are alsp
available as pre-compiled executable binaries in package -bin. The -lkm
package helps a lot for pinmuxing and to get PWM signals working on
kernel 4.x. And the -doc package contains the documaentation in html
format for off-line reading, which is also [available
on-line.](http://users.freebasic-portal.de/tjf/Projekte/@PROJ_NAME@/doc/html/index.html)
It's recommended to use the off-line version, because it's garantied to
match the binaries. The on-line version may be behind or even beofre
the current binaries. When you're short of memory at the Beaglebone,
you can install the documentation on the PC as well.


## C programming language ## {sSecDev}

For C programming language execute

    sudo apt-get install libpruio-dev libpruio-lkm libpruio-doc

to install the shared library, the header files, the example source
code, the loadable kernel module and the html documentation.
Documentation and LKM are optional. Then copy the example code to your
working directory

    cp -r /usr/shared/doc/libpruio-dev/examples .

and you're ready to start.


## FreeBASIC programming language ## {sSecBas}

Ie. for FreeBASIC programming language execute

    sudo apt-get install libpruio-bas libpruio-doc

to install the shared library, the header files, the example source
code and the html documentation. The documentation is optional. When
you're short of memory, you can install the package on the PC as well.
Or use [this online
version.](http://users.freebasic-portal.de/tjf/Projekte/@PROJ_NAME@/doc/html/index.html)
Then copy the example code to your working directory

    cp -r /usr/shared/doc/libpruio-bas/examples .

and you're ready to start.


## Python programming language ## {sSecPy}

Ie. for Python programming language execute

    sudo apt-get install python-pruio libpruio-doc

to install the shared library, the bindings folder, the example source
code and the html documentation. The documentation is optional. When
you're short of memory, you can install the package on the PC as well.
Or use [this online
version.](http://users.freebasic-portal.de/tjf/Projekte/@PROJ_NAME@/doc/html/index.html)
Then copy the example code to your working directory

    cp -r /usr/shared/doc/python-pruio/examples .

and you're ready to start.


## Example Binaries ## {sSecBin}

There's also an examples package containing precompiled binaries. No
compiler nor interpreter is necessary, just install by

    sudo apt-get install libpruio-bin

and start the executables. The programm names are prepended by
`pruio_`. Ie. in order to start example `sos` type

    pruio_sos

\note Some of the examples need custom wiring on the headers. Ie.
      `pruio_performance` does nothing without the related wiring, so
      mind the wiring descriptions in chapter \ref ChaExamples.


# Source Tree # {#SecSourceTree}

The following section describes the source tree and its build
management system. People who want to contribute to the project,
experiment with the source code or build Debian packages will find
detailed information on internals. If you don't belong to that group
you can skip this section, and continue at chapter \ref ChaPins.


## Build Dependencies ## {#sSecBuildDeps}

FIXME

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

|                                                                Name  | Type |  Function                                                      |
| -------------------------------------------------------------------: | :--: | :------------------------------------------------------------- |
| [fbc](http://www.freebasic.net)                                      | M    | FreeBASIC compiler to compile the source code                  |
| [am335x-pru-package](https://github.com/DTJF/fb_prussdrv)            | M    | PRU assembler to compile PRU code and libprussdrv              |
| [device-tree-compiler](https://git.kernel.org/cgit/utils/dtc/dtc.git)| M  I | Device tree compiler to create overlays                        |
| [GIT](http://git-scm.com/)                                           | R  D | Version control system to organize the files                   |
| [CMake](http://www.cmake.org)                                        | R  D | Build management system to build executables and documentation |
| [cmakefbc](http://github.com/DTJF/cmakefbc)                          | R    | FreeBASIC extension for CMake                                  |
| [fbdoc](http://github.com/DTJF/fbdoc)                                | R    | FreeBASIC extension tool for Doxygen                           |
| [Doxygen](http://www.doxygen.org/)                                   | R  D | Documentation generator (for html output)                      |
| [Graphviz](http://www.graphviz.org/)                                 | R  D | Graph Visualization Software (caller/callee graphs)            |
| [LaTeX](https://latex-project.org/ftp.html)                          | R  D | A document preparation system (for PDF output)                 |

It's beyond the scope of this guide to describe the installation for
those tools. Find detailed installation instructions on the related
websides, linked by the name in the first column.

-# First, install the distributed (D) packages of your choise, either mandatory
   ~~~{.txt}
   sudo apt-get install git cmake
   ~~~
   or full install (recommended)
   ~~~{.txt}
   sudo apt-get install device-tree-compiler git cmake doxygen graphviz linux-headers-`uname -r `
   ~~~

-# Then make the FB compiler working:
   ~~~{.txt}
   wget https://www.freebasic-portal.de/dlfiles/625/freebasic_1.06.0debian7_armhf.deb
   sudo dpkg --install freebasic_1.06.0debian7_armhf.deb
   sudo apt-get -f install
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

-# And finaly, install fbdoc (if wanted) by using GIT and CMake.
   Execute the commands
   ~~~{.txt}
   git clone https://github.com/DTJF/fbdoc
   cd fbdoc
   mkdir build
   cd build
   cmake ..
   make
   sudo make install
   ~~~
   \note Omit `sudo` in case of non-LINUX systems.


# Get Package # {#SecGet}

Depending on whether you installed the optional GIT package, there're
two ways to get the \Proj package.

## ZIP ## {#SecGet_Zip}

As an alternative you can download a Zip archive by clicking the
[Download ZIP](https://github.com/DTJF/girtobac/archive/master.zip)
button on the \Proj website, and use your local Zip software to unpack
the archive. Then change to the newly created folder.

\note Zip files always contain the latest development version. You
      cannot switch to a certain point in the history.


## GIT ## {#SecGet_Git}

Using GIT is the prefered way to download the \Proj package (since it
helps users to get involved in to the development process). Get your
copy and change to the source tree by executing

    git clone https://github.com/DTJF/libpruio
    cd libpruio


# Configuration # {#SecConfig}

Before you can use \Proj you have to make sure that your system is
prepared. This means

- \ref sSecPrepBuild : prepare the source tree for your system.
- \ref sSecPruDriver : block `rproc`, make the system load `uio_pruss`.
- \ref sSecDtboFile : load a pinmux file for custom or universal pinmuxing.

Use cmake/cmakefbc for your work. Building and installing the software
manually is a complex process. It isn't described here, since it's
beyond the scope of this documentation.


## Prepare build ## {#sSecPrepBuild}

The project either supports in-source or out-of-source building. The
later is more easy to understand and to handle, since the source code
doesn't change (much). Mostly all generated files go into a separate
`build` folder:

    mkdir build
    cd build
    cmakefbc ..

When the script fails, solve the problems first before you continue.


## PRU driver ## {#sSecPruDriver}

Unfortunatelly this step may get complicated. \Proj needs the
`uio_pruss` driver. In kernel 3.8 this is default, no further action is
necessary. But in kernel 4.x the new rproc driver gets default, and it
took years until easy reconfiguration was supported. Depending on the
kernels subversion, different action has to be done to get it out of
the way. It's beyond the scope of this documentation to describe all
the diffent quirks and pitfalls. Search the internet for further
documentation.

The only help I can provide is a command to test success. Executing

    lsmod | grep uio

should output

~~~{.txt}
uio_pruss              16384  0
uio_pdrv_genirq        16384  0
uio                    20480  2 uio_pruss,uio_pdrv_genirq
~~~


## LKM ## {#sSecLkmBuild}

The loadable kernel module (LKM) for \Proj has three purposes

-# enable the PRUSS, if not running
-# fix a kernel 4.x problem (PWMSS-Pwm output disabled)
-# support for \Proj pinmuxing

Build the LKM by executing

    make lkm

Installation is a bit more difficult. The official way is to install
the module in folder `/lib/modules/$(uname -r)/extra`, where `$(uname
-r)` is the version of the current kernel running. This has the
advantage that the module exactly matches the kernel specifications and
the tool `modprobe` can handle loading intelligently. But the downside
is that you have to re-build and re-install the module each time when
the kernel changes (ie. when `apt upgrade` installs a kernel update).
For this type of installation execute

    make lkm-vers-install

Afterwards the LKM can get loaded by `sudo modprobe libpruio` and
unloaded by `sudo modprobe -r libpruio`. To uninstall that the LKM
execute

    make lkm-vers-uninstall

Alternatively \Proj provides a further install method where the binary
is located in folder `/lib/modules` and doesn't get affected by kernel
updates, but cannot get reached by the tool `modprobe` at this
location. Consequently a `systemctl` service gets installed and enabled
to load the module for you at boot time. The service also adds a
system user group named `pruio`. All members of this group have
pinmuxing privileges. For this type of installation execute

    make lkm-glob-install

From the next boot on the LKM will be auto-loaded, and you can use
`systemctl` features for further handling. See section \ref sSecLKM for
further details.

To uninstall that service and the LKM, execute

    make lkm-glob-uninstall

\note The user group `pruio` doesn't get removed, it's still existent
      after uninstall. To remove it execute `sudo nano /etc/group` and
      remove the related line `pruio:x:...` from that file (change is
      effective after next logout or boot). That way you can also
      remove a user from that group by deleting only his name in the
      line.


# Build Binary # {#SecBuildBin}

Compile the source code and install by executing (in `build` folder):

    make
    sudo make install
    sudo ldconfig

\note The last command `sudo ldconfig` is only necessary after first
      install. It makes the newly installed library visible for the
      linker. You can omit it for further updates.


# Build Examples # {#SecBuildExamples}

In the that same build folder, build the examples by:

    make examples

That will build both, the FreeBASIC and the C examples. To run them execute ie.

    src/examples/1

to run the `1.bas` example, or

    rc/c_examples/1_c

to run the `1.c` example.

The build scripts also support separate builds

    make fb_examples
    make c_examples

\note In order to build the examples you have to build and install the
      library binary first, see section \ref SecBuildBin.


# Build Documentation # {#SecBuildDoc}

In the that same build folder, build the documentation by:

    make doc

This will build the html tree (in `doxy/html`) and a pdf version (in
the current folder) of the documentation content. The build scripts
also support separate builds

    make doc_htm
    make doc_pdf


# Build Python Binding # {#SecBuildPython}

In order to execute the Python examples, you have to generate a
ctypes-based python binding for the library fist. To build a fresh file
from the current FB source code execute

    make python

Find the resulting file `pruio.py` in folder `src/python/libpruio`.

\note `fbdoc` and its plugin `py_ctype` are mandatory for that target.


# DTBO File # {#sSecDtboFile}

The device tree blob (DTBO) for \Proj has two purposes

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
´src/config´, which generates a `libpruio-00A0.dts` file. That file
gets compiled to the final destination `/lib/firmware`. Afterward you
have to make sure that the overlay gets loaded:

- kernel 3.8: use capemgr to load the overlay.

- kernel 4.x: bootload the overlay. Depending on the subversion
  different action has to be done. It's beyond the scope of this
  documentation to describe all the diffent approaches.


# Build Debian Package # {#SecBuildDeb}

In the that same build folder, build the Debian packages by:

    make deb

This will create the Debian packages

- libpruio.deb containing the runtime binary and the LKM
- libpruio-doc.deb containing HTML documentation tree
- libpruio-examples.deb containing precompiled binaries to execute
- libpruio-dev.deb containing the C header files and C examples
- libpruio-bas.deb containing the FreeBASIC header files and examples
- libpruio-lkm.deb containing the FreeBASIC header files and examples
- python-pruio.deb containing the Python binding and example source

and the auxiliary file to upload them to a PPA. Find the output in
folder `debian/packages`.
