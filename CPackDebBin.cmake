# This file will be configured to contain variables for CPack. These variables
# should be set in the CMake list file of the project before CPack module is
# included. The list of available CPACK_xxx variables and their associated
# documentation may be obtained using
#  cpack --help-variable-list
#
# Some variables are common to all generators (e.g. CPACK_PACKAGE_NAME)
# and some are specific to a generator
# (e.g. CPACK_NSIS_EXTRA_INSTALL_COMMANDS). The generator specific variables
# usually begin with CPACK_<GENNAME>_xxxx.


SET(CPACK_BINARY_BUNDLE "")
SET(CPACK_BINARY_CYGWIN "")
SET(CPACK_BINARY_DEB "")
SET(CPACK_BINARY_DRAGNDROP "")
SET(CPACK_BINARY_NSIS "")
SET(CPACK_BINARY_OSXX11 "")
SET(CPACK_BINARY_PACKAGEMAKER "")
SET(CPACK_BINARY_RPM "")
SET(CPACK_BINARY_STGZ "")
SET(CPACK_BINARY_TBZ2 "")
SET(CPACK_BINARY_TGZ "")
SET(CPACK_BINARY_TZ "")
SET(CPACK_BINARY_ZIP "")
SET(CPACK_CMAKE_GENERATOR "Unix Makefiles")
SET(CPACK_COMPONENTS_ALL "bin")
SET(CPACK_COMPONENTS_ALL_SET_BY_USER "TRUE")
SET(CPACK_COMPONENTS_GROUPING "IGNORE")
SET(CPACK_COMPONENT_UNSPECIFIED_HIDDEN "TRUE")
SET(CPACK_COMPONENT_UNSPECIFIED_REQUIRED "TRUE")
SET(CPACK_DEBIAN_ARCHITECTURE "armv7l")
SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "/home/debian/Projekte/pruio/debian/postinst;/home/debian/Projekte/pruio/debian/postrm")
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "am335x-pru-package")
SET(CPACK_DEBIAN_PACKAGE_SECTION "libdevel")
SET(CPACK_DEB_COMPONENT_INSTALL "ON")
SET(CPACK_GENERATOR "DEB")
SET(CPACK_INSTALL_CMAKE_PROJECTS "/home/debian/Projekte/pruio_build;libpruio;ALL;/")
SET(CPACK_INSTALL_PREFIX "/usr/local")
SET(CPACK_MODULE_PATH "/home/debian/Projekte/pruio/cmake/Modules/")
SET(CPACK_NSIS_DISPLAY_NAME "libpruio")
SET(CPACK_NSIS_INSTALLER_ICON_CODE "")
SET(CPACK_NSIS_INSTALLER_MUI_ICON_CODE "")
SET(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
SET(CPACK_NSIS_PACKAGE_NAME "libpruio")
SET(CPACK_OUTPUT_CONFIG_FILE "/home/debian/Projekte/pruio_build/CPackConfig.cmake")
SET(CPACK_PACKAGE_CONTACT "Thomas Freiherr <Thomas.Freiherr@gmx.net>")
SET(CPACK_PACKAGE_DEFAULT_LOCATION "/")
SET(CPACK_PACKAGE_DESCRIPTION "libpruio offers functions to operate fast and easy digital input and output and analog input on the BeagleboneBlack")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "/usr/share/cmake-2.8/Templates/CPack.GenericDescription.txt")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "libpruio - fast and easy digital I/O and analog I for BeagleboneBlack")
SET(CPACK_PACKAGE_FILE_NAME "libpruio-0.2.2")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "libpruio")
SET(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "libpruio")
SET(CPACK_PACKAGE_NAME "libpruio")
SET(CPACK_PACKAGE_RELOCATABLE "true")
SET(CPACK_PACKAGE_VENDOR "TJF")
SET(CPACK_PACKAGE_VERSION "0.2.2")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "2")
SET(CPACK_PACKAGE_VERSION_PATCH "2")
SET(CPACK_RESOURCE_FILE_LICENSE "/usr/share/cmake-2.8/Templates/CPack.GenericLicense.txt")
SET(CPACK_RESOURCE_FILE_README "/usr/share/cmake-2.8/Templates/CPack.GenericDescription.txt")
SET(CPACK_RESOURCE_FILE_WELCOME "/usr/share/cmake-2.8/Templates/CPack.GenericWelcome.txt")
SET(CPACK_SET_DESTDIR "OFF")
SET(CPACK_SOURCE_CYGWIN "")
SET(CPACK_SOURCE_GENERATOR "TGZ;TBZ2;TZ")
SET(CPACK_SOURCE_OUTPUT_CONFIG_FILE "/home/debian/Projekte/pruio_build/CPackSourceConfig.cmake")
SET(CPACK_SOURCE_TBZ2 "ON")
SET(CPACK_SOURCE_TGZ "ON")
SET(CPACK_SOURCE_TZ "ON")
SET(CPACK_SOURCE_ZIP "OFF")
SET(CPACK_SYSTEM_NAME "Linux")
SET(CPACK_TOPLEVEL_TAG "Linux")

#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS "ON")
#SET(CPACK_INSTALL_COMMANDS "ON")

# Configuration for component "bin"
SET(CPACK_COMPONENT_BIN_DISPLAY_NAME "library binary and device tree overlay")
SET(CPACK_COMPONENT_BIN_DESCRIPTION "The library binary and the device tree overlay to be used at run-time.")
SET(CPACK_COMPONENT_BIN_REQUIRED TRUE)