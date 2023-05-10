Preparation {#ChaPreparation}
===========
\tableofcontents

This chapter describes several methods to get \Proj working on your
system:

-# \ref SecDebPac installing, or
-# \ref SecSourceTree compilation and installing

The first one is for easy consuming the software service "as is". The
last one provides the benfits of the latest version, the chance to
partizipate in development and/or optimize the software to your custom
needs, by the costs of less convenience.

And, before compiling or running any executable against \Proj, you've to
prepare your system:

* switch to the `bone` kernel flavor in order to
* enable `uio_pruss` driver (and dissable `rproc` driver),
* free the header pin claims (dissable `cape_universal.dtbo`).


# System Preparation # {#SecSysPrep}

By default the Beaglebone images are equiped with software componemts
that do not make sense in combination with \Proj, consuming lots of
memory and slowing down the boot process. But the main problem is that
they block important features. You've to get them out of the way.

Unfortunatelly that sounds more easy than it may be, since a lot of
changes have been made to that components between the kernel versions,
so that there isn't one description how to proceed. The following
instructions may not work for your particular kernel; test it out.
Otherwise sorry, it's out of the scope of this documentation to cover
all kernel version. Perhaps you'll find a solution [at the
forum](https://forum.beagleboard.org).

The first step is switching to the right kernel flavor. There's the
`ti` flavor developed by Texas Instruments (the CPU producer). But the
better choise is the `bone` flavor, that provides the mandatory
`uio_pruss` driver and is booting faster. So execute

    uname -r

in order to test your current flavor. When the output contains the
characters `-bone-` you're fine. Otherwise (output contains `-ti-`)
you'll have to switch to the bone flavor by

    sudo /opt/scripts/tools/update_kernel.sh --bone-kernel --lts-4_19

\note Replace in `--lts-4_19` your prefered kernel version. Replace
      `--bone-kernel` by `--bone-rt-kernel` for the real-time version.
      Find details at the
      [eLinux Debian Page](https://elinux.org/Beagleboard:BeagleBoneBlack_Debian#Debian_Releases).

Next activate the `uio_pruss` driver. Therefor it's sufficient in most
images to edit the boot configuration file like

    sudo nano /boot/uEnv.txt

where to enable the driver `uio_pruss` and also dissable `rproc` (only
one of them can be active at a time). The related lines should finally
look like

    ???

Afterwards comment out the line loading the device tree blob
`cape_universal.dtbo`, in order to free the headers pins for \Proj

    ???

\note This also makes the tool `config-pin` not working any more. You
      don't need it, \Proj can replace all its features.

Finally save the file and reboot the system.


## uio_pruss Driver ## {#sSecPruDriver}

In order to test if the `uio_pruss` driver is working properly, execute
the commands

    lsmod | grep uio
    ls -l /dev/uio*

which should generate text output similar to

    $ lsmod | grep uio
    uio_pruss              16384  0
    uio_pdrv_genirq        16384  0
    uio                    20480  2 uio_pruss,uio_pdrv_genirq
    $ ls -l /dev/uio*
    crw-rw---- 1 root users 243, 0 Mai 17 07:25 /dev/uio0
    crw-rw---- 1 root users 243, 1 Mai 17 07:25 /dev/uio1
    crw-rw---- 1 root users 243, 2 Mai 17 07:25 /dev/uio2
    crw-rw---- 1 root users 243, 3 Mai 17 07:25 /dev/uio3
    crw-rw---- 1 root users 243, 4 Mai 17 07:25 /dev/uio4
    crw-rw---- 1 root users 243, 5 Mai 17 07:25 /dev/uio5
    crw-rw---- 1 root users 243, 6 Mai 17 07:25 /dev/uio6
    crw-rw---- 1 root users 243, 7 Mai 17 07:25 /dev/uio7


## Pin Claims ## {#sSecPinClaims}

In order to test if the `cape_universal.dtbo` doesn't load any more,
execute

    ???

The output shoul not have more the two lines like

    ???


# Debian Packages # {#SecDebPac}

The easy way to benefit from \Proj is to install the Debian packages.
They're not in mainline, yet, but provided in a PPA (Personal Package
Archive). In order to use it, you have to adopt your package management
sources. On the default Debian operating system, edit the file `sudo
nano /etc/apt/sources.list` and add the lines:

    deb http://beagle.tuks.nl/debian jessie/
    deb-src http://beagle.tuks.nl/debian jessie/

Then grep the keyring by (mind the '-' character at the end)

    wget -qO - http://beagle.tuks.nl/debian/pubring.gpg | sudo apt-key add -

Once prepared, you can update your package manager database

    sudo apt-get update

and finally download and install the packages for your prefered
programming language:

| Name         | Description                 |   Size | Current File Name            |
| :----------- | :-------------------------- | -----: | :--------------------------- |
| libpruio     | shared library binary       |  45 kB | libpruio_0.6.0_armhf.deb     |
| libpruio-dev | examples/bindings C         |  18 kB | libpruio-dev_0.6.0_armhf.deb |
| libpruio-bas | examples/bindings FreeBASIC |  27 kB | libpruio-bas_0.6.0_armhf.deb |
| python-pruio | examples/bindings Python    |  18 kB | python-pruio_0.6.0_armhf.deb |
| libpruio-bin | executable examples         |  80 kB | libpruio-bin_0.6.0_armhf.deb |
| libpruio-lkm | loadable kernel module      |   8 kB | libpruio-lkm_0.6.0_armhf.deb |
| libpruio-doc | documentation (html-tree)   | 4.1 MB | libpruio-doc_0.6.0_all.deb   |
| libpruio-src | source code                 | 1.2 MB | libpruio_0.6.0.tar.xz        |

\note The size and the current full name may vary after updates.
      They're mentioned to give you a roughly assessment of the
      download volume.

The first package contains the binary executable of the shared library,
which gets linked at runtime to related programs. This one is mandatory
for all \Proj projects.

The package tripple -dev, -bas and python-pruio contain language
bindings for C, FreeBASIC and Python programming language, as well as
example source code. The -bas package contains additional examples with
grafical output. In order to use the library for your projects, you'll
need at least one of these bindings for your prefered programming
language, which depend all on the mandatory shared library package.

The remaining packages are optional. All examples in the -bas package
are also available as pre-compiled executable binaries in package -bin.
When you install that package you can run the examples without
compiling the source. In order to reduce naming pollution on your box,
the binary names are prepended by "pruio_", so ie. in order to
execute example \ref sSecExaSos type `pruio_sos`.

\note Some of the examples need custom wiring on the headers. Ie.
      `pruio_performance` does nothing but hangs endless (waiting for a
      certain input) without the related wiring, so mind the wiring
      descriptions in chapter \ref ChaExamples.

The -lkm package provides enhanced pinmuxing and PWM features. It's
mandatory to get all PWM outputs working on kernel 4.x, and recommended
for kernel 3.x as well. It contains the source code of the kernel
module, which gets compiled against your kernel version at install time
using dkms (dynamic kernel module service). Dkms will re-compile the
module on each kernel change/update, to keep the binary up-to-date.
Find further information on the LKM in section \ref sSecLKM.

The -doc package contains the documentation in html format. That is the
text you're currently reading. Installing that package copies a HTML
tree on to your box starting at
http://usr/share/doc/libpruio-doc/html/index.html for off-line reading.
Load and bookmark that file in your prefered browser. But it's also
[available
on-line.](http://users.freebasic-portal.de/tjf/Projekte/libpruio/doc/html/index.html)
It's recommended to use the off-line version, because it's garantied to
match the binaries. The on-line version may be behind or even before
the current binaries. When you're short of memory at the Beaglebone,
you can install the documentation on the PC as well.

And finally the .tar.xz package contains the source code, which was
used to build the above described packages. Unlike the code on \Webs
this code is garantied to match the contens of the other packages.

\note In order to use libpruio pinmuxing disable the device tree
      overlay for config-pin (see section \ref sSecLKM).


## C programming language ## {#sSecDev}

For development in C programming language execute

    sudo apt-get install libpruio-dev libpruio-lkm libpruio-doc

to install the shared library, the header files, the example source
code, the loadable kernel module and the html documentation
(documentation and LKM are optional). Then copy the example code to
your working directory

    cp -r /usr/share/doc/libpruio-dev/examples .

and you're ready to start.


## FreeBASIC programming language ## {#sSecBas}

For development in FreeBASIC programming language execute

    sudo apt-get install libpruio-dev libpruio-bas libpruio-lkm libpruio-doc

to install the shared library, the header files, the example source
code, the loadable kernel module and the html documentation
(documentation and LKM are optional). Then copy the example code to
your working directory

    cp -r /usr/share/doc/libpruio-bas/examples .

and you're ready to start.


## Python programming language ## {#sSecPy}

For development in Python programming language execute

    sudo apt-get install python-pruio libpruio-lkm libpruio-doc

to install the shared library, the header files, the example source
code, the loadable kernel module and the html documentation
(documentation and LKM are optional). Then copy the example code to
your working directory

    cp -r /usr/share/doc/python-pruio/examples .

and you're ready to start.


# GitHub Source Tree # {#SecSourceTree}

The following section describes the source tree and its build
management system. People who want to contribute to the project,
experiment with the source code or build Debian packages will find
detailed information on internals here. If you don't belong to that
group you can skip this section, and continue at chapter \ref ChaPins.

You can find in this section information on

- how to prepare your system by installing necessary tools,
- how to download the package using GIT and
- how to build the binaries, examples, documentation or Debian packages.

Since the project is strongly related to the Beaglebone hardware, the
source tree is prepared for Debian linux systems only.


## Preparation ## {#sSecPreparation}

Before you can work on the \Proj source tree, you have to make sure
that your system is prepared. This means

- \ref sSecPrepBuild : prepare the source tree for your system.
- \ref sSecPruDriver : block `rproc`, make the system load `uio_pruss`.
- \ref sSecDtboFile : load a pinmux file for custom or universal pinmuxing.


### Build Dependencies ### {#sSecBuildDeps}

The following table lists the main dependencies for the \Proj package
and their types. A dependency is either mandatory (M) or recommended
(R), the matching package is available in the standard distrubution
management system (D), a personal private archive (P), on GitHub (G),
or pre-installed (I -> implies D).

|                                                                Name  | Type |  Function                                                      |
| -------------------------------------------------------------------: | :--: | :------------------------------------------------------------- |
| [fbc](http://www.freebasic.net)                                      | M  P | FreeBASIC compiler to compile the source code                  |
| [CMake](http://www.cmake.org)                                        | R  D | Build management system to build executables and documentation |
| [cmakefbc](http://github.com/DTJF/cmakefbc)                          | R  P | FreeBASIC extension for CMake                                  |
| [fbdoc](http://github.com/DTJF/fbdoc)                                | R  P | FreeBASIC extension tool for Doxygen                           |
| [am335x-pru-package](https://github.com/DTJF/fb_prussdrv)            | M  P | PRU assembler to compile PRU code and libprussdrv              |
| [device-tree-compiler](https://git.kernel.org/cgit/utils/dtc/dtc.git)| M  I | Device tree compiler to create overlays                        |
| [GIT](http://git-scm.com/)                                           | R  D | Version control system to organize the files                   |
| [Doxygen](http://www.doxygen.org/)                                   | R  D | Documentation generator (for html output)                      |
| [Graphviz](http://www.graphviz.org/)                                 | R  D | Graph Visualization Software (caller/callee graphs)            |
| [LaTeX](https://latex-project.org/ftp.html)                          | R  D | A document preparation system (for PDF output)                 |
| linux-headers-X.X.X                                                  | R  D | The kernel headers to compile the LKM                          |
| debhelper & further tools                                            | R  D | The tools to build Debian Packages                             |

It's beyond the scope of this guide to describe the installation for
those tools. Find detailed installation instructions on the related
websides, linked by the name in the first column.

Here's a brief overview on dependenvies vs. major targets (described
below, two tables due to latex longtabu restrictions)

|                                                                Name  | pasm | pruio | lkm | deb | config |
| -------------------------------------------------------------------: | :--: | :---: | :-- | :-: | :----: |
| [fbc](http://www.freebasic.net)                                      |      |   X   |     |  X  |   X    |
| [CMake](http://www.cmake.org)                                        |   X  |   X   |  X  |  X  |   X    |
| [cmakefbc](http://github.com/DTJF/cmakefbc)                          |      |   X   |     |  X  |        |
| [fbdoc](http://github.com/DTJF/fbdoc)                                |      |       |     |  X  |        |
| [am335x-pru-package](https://github.com/DTJF/fb_prussdrv)            |   X  |   X   |     |  X  |        |
| [device-tree-compiler](https://git.kernel.org/cgit/utils/dtc/dtc.git)|      |       |     |     |   X    |
| [GIT](http://git-scm.com/)                                           |      |       |     |     |        |
| [Doxygen](http://www.doxygen.org/)                                   |      |       |     |  X  |        |
| [Graphviz](http://www.graphviz.org/)                                 |      |       |     |  X  |        |
| [LaTeX](https://latex-project.org/ftp.html)                          |      |       |     |  X  |        |
| linux-headers-X.X.X                                                  |      |       |     |  X  |        |
| debhelper & further tools                                            |      |       |     |  X  |        |

|                                                                Name  | fb_examples | c_examples | doc_htm | doc_pdf | python |
| -------------------------------------------------------------------: | :---------: | :--------: | :-----: | :-----: | :----: |
| [fbc](http://www.freebasic.net)                                      |     X       |            |         |         |   X    |
| [CMake](http://www.cmake.org)                                        |     X       |      X     |    X    |    X    |   X    |
| [cmakefbc](http://github.com/DTJF/cmakefbc)                          |     X       |            |    X    |    X    |   X    |
| [fbdoc](http://github.com/DTJF/fbdoc)                                |             |            |    X    |    X    |  !X!   |
| [am335x-pru-package](https://github.com/DTJF/fb_prussdrv)            |     X       |      X     |         |         |        |
| [device-tree-compiler](https://git.kernel.org/cgit/utils/dtc/dtc.git)|             |            |         |         |        |
| [GIT](http://git-scm.com/)                                           |             |            |         |         |        |
| [Doxygen](http://www.doxygen.org/)                                   |             |            |    X    |    X    |        |
| [Graphviz](http://www.graphviz.org/)                                 |             |            |    X    |    X    |        |
| [LaTeX](https://latex-project.org/ftp.html)                          |             |            |         |    X    |        |
| linux-headers-X.X.X                                                  |             |            |         |         |        |
| debhelper & further tools                                            |             |            |         |         |        |

As you can see not all dependencies are necessary to build only a
special target. Ie. when you want to build the documentation you won't
need the compilers nor assemblers. Use the package manager to install
the desired dependencies (omit the packages you don't need)

    sudo apt-get install fbc cmake fbdoc am335x-pru-package device-tree-compiler python
    sudo apt-get install doxygen graphviz linux-headers-`uname -r ` debhelper dkms dh-systemd autotools-dev dh-python

\note In order to fetch the P type packages you have to add the PPA to
      your `/etc/apt/sources.list` file as described in section \ref
      SecDebPac.

A special case is the target `python`, described in section \ref
sSecBuildPython. In order to build the language binding, the
`py_ctypes` plugin is mandatory. It's an example plugin code in package
[fbdoc](http://github.com/DTJF/fbdoc). You have to install that package
source tree at the same level as the \Proj package and perform at least
the `make` command to create the `py_ctypes` binary.

Execute the commands (in your projects folder)

    git clone https://github.com/DTJF/fbdoc
    cd fbdoc
    mkdir build
    cd build
    cmake ..
    make

Then install the \Proj package at the same level as the `fbdoc`
package, like

    /proc/self/
    |-- ...
    |-- fbdoc
    |-- libpruio
    |-- ...


### Get Package ### {#sSecGet}

Depending on whether you installed the optional GIT package, there're
two ways to get the \Proj source tree.

#### ZIP #### {#sSecGet_Zip}

As an alternative you can download a Zip archive by clicking the
[Download ZIP](https://github.com/DTJF/girtobac/archive/master.zip)
button on the \Proj website, and use your local Zip software to unpack
the archive. Then change to the newly created folder.

\note Zip files always contain the latest development version. You
      cannot switch to a certain point in the history.


#### GIT #### {#sSecGet_Git}

Using GIT is the prefered way to download the \Proj source tree (since
it helps users to get involved in to the development process). Get your
copy and change to the source tree by executing

    git clone https://github.com/DTJF/libpruio
    cd libpruio


### Configure the Source Tree ### {#sSecPrepBuild}

Before you can build any target, you have to configure the source tree.
CMake will check the tools on your system and create matching
`Makefiles` in the build directories.

The project either supports in-source or out-of-source building. The
later is strongly recommended, because it's more easy to understand and
to handle, since the source code doesn't change (much). Mostly all
generated files go into a separate `build` folder. Configure the build
tree by

    mkdir build
    cd build
    cmakefbc ..

The last command will output a bunch of lines informing about the
currently executed tests. When the script fails, the output ends by

    -- Configuring incomplete, errors occurred!

You'll have to solve the problems first, before you continue. Check the
output for messages containing `failed`, and use the above mentioned
hints to fix the problem.

On success the output ends by

    -- Build files have been written to: ...

Lines starting with `>> target ...` indicate that the prerequisites for
a target or target group are fullfilled. The target is ready to build.

In contrast lines starting with `!! no target...` indicate that some
prerequisites are not fullfilled. If you don't need to build that
target, never mind and just continue. But when you intend to build it,
you've to fix the problem first, using the above mentioned hints.


##Building targets ## {#sSecTarBuilding}

Once your system and source tree is prepared, you can start your work.
All commands mentioned below get executed in the `libpruio/build`
directory. To list all available targets execute `make help`.


### Shared Library ### {#sSecBuildBin}

Compile the source code and install the shared library binary by
executing:

    make
    sudo make install
    sudo ldconfig

This will also install the language bindings (header files) for
FreeBASIC and C programming language.

\note The last command `sudo ldconfig` is only necessary after first
      install. It makes the newly installed library visible for the
      linker. You can omit it for further updates.

\note The `make install` script creates files in the system subfolders
      under `/usr/local/`, and a write-pretected file named
      `install_manifest.txt`. In order to uninstall execute `xargs rm <
      install_manifest.txt`.


### Examples ### {#sSecBuildExamples}

Compile the examples by:

    make examples

That will build both, the FreeBASIC and the C examples. To run them execute ie.

    src/examples/sos

to run the `sos.bas` example, or

    src/c_examples/sos

to run the `sos.c` example.

The build scripts also support separate compilation

    make fb_examples
    make c_examples

as well as single compilation like

    make sos
    make sos_c

\note In order to build the examples you have to build and install the
      library binary first, see section \ref sSecBuildBin.

\note The `make examples` script only creates files inside the source
      tree -> to uninstall just remove them.


### LKM ### {#sSecLkmBuild}

Build the LKM by executing

    make lkm

Installation is a bit more difficult. The module gets installed in
folder `/lib/modules/$(uname -r)/extra`, where `$(uname -r)` is the
version of the current kernel running. This has the advantage that the
module exactly matches the kernel specifications and the tool
`modprobe` can handle loading intelligently. But the downside is that
you have to re-build and re-install the module each time when the
kernel changes (ie. when `apt upgrade` installs a kernel update).
Anyway, that's the Debian policy, we've to follow. So execute

    sudo make lkm-install

to install the module binary and additionally a systemd service
(`/etc/systemd/???`) auto-loading that module at boot time.
Additionally a new system group named `pruio` gets created. See section
\ref sSecLKM for further information.

Afterwards the LKM will be tainted to the kernel and the pinmuxing
features are ready to use. The module also ba available in further
bootings. Find in section \ref sSecLKM details on dissable/re-enable
auto-loading and/or activating the LKM during the current session.

To uninstall the LKM and the systemd service execute

    sudo make lkm-uninstall

\note The user group `pruio` doesn't get removed, it's still existent
      after uninstall. To remove it execute `sudo nano /etc/group` and
      remove the related line `pruio:x:...` from that file (change is
      effective after next logout or boot). That way you can also
      remove a user from that group by deleting only his name in the
      line.


### Documentation ### {#sSecBuildDoc}

Build the documentation by:

    make doc

This will build the html tree (in `doxy/html`) and a pdf version (in
the current folder) of the documentation content. The build scripts
also support separate builds

    make doc_htm
    make doc_pdf

\note The targets get prepared by the `UseFbDoc.cmake` script. Find
      further information in the `cmakefbc` [package
      documentation](http://users.freebasic-portal.de/tjf/Projekte/cmakefbc/doc/html/index.html).

\note The `make cod` script only creates files inside the source
      tree -> to uninstall just remove the folder `doxy/html` and the
      file `libpruio.pdf`.


### Python Binding ### {#sSecBuildPython}

In order to execute the Python examples, you have to generate a
ctypes-based python binding for the library fist. To build a fresh file
from the current FB source code execute

    make python

Find the resulting file `pruio.py` in folder `src/python/libpruio`.

\note `fbdoc` and its plugin `py_ctype` are mandatory for that target.
      See section \ref sSecBuildDeps for details.


### DTBO File ### {#sSecDtboFile}

The device tree blob (DTBO) is used for "old-style" pinmuxing (before
LKM in version 0.6). It has two purposes

-# enable the PRUSS
-# set predefined pinmuxing configurations

While the first is mandatory, the second may get done in diffent ways:

- Either a custom configuration with the necessary setting for your project (header connections).
- Or a universal setting that allows you to change pinmuxing at runtime.

The later is very flexible in development phase while you design and
test your PCB (hardware board), by the cost of high memory consumption
and slow booting. At the beginning and while your hardware may change
during development, this is the prefered solution.

\Proj is prepared to generate and install an universal overlay for the
BeagleBoneBlack hardware by executing

    sudo make dtconf

This compiles and runs the `dts_universal.bas` code in folder
´src/config´, which generates a `libpruio-00A0.dts` file. That file
gets compiled to the final destination `/lib/firmware`. Afterward you
can load that overlay blob:

- kernel 3.8: use capemgr to load the overlay.

- kernel 4.x: bootload the overlay. Depending on the subversion
  different action has to be done. It's beyond the scope of this
  documentation to describe all the diffent approaches.


### Debian Packages ### {#SecBuildDeb}

In the that same build folder, build the Debian packages by:

    make deb

This will create the Debian packages

- libpruio.deb containing the runtime binary
- libpruio-doc.deb containing HTML documentation tree
- libpruio-bin.deb containing precompiled binaries to execute
- libpruio-dev.deb containing the C header files and C examples
- libpruio-bas.deb containing the FreeBASIC header files and examples
- libpruio-lkm.deb containing the FreeBASIC header files and examples
- python-pruio.deb containing the Python binding and example source

and further auxiliary files containing the source code and information
for uploading the packages to a repository. Find the output in folder
`debian/packages`.


## In-Source Files ## {#SecInSourceFiles}

Even in case of an out-of-source build, some files get created in-source:

- ReadMe.md
- src/pruio/pasm_init.bi
- src/pruio/pasm_run.bi
- src/examples/BBB
- debian/libpruio-lkm.service
- src/python/libpruio/pruio.py
