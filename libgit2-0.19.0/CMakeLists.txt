# CMake build script for the libgit2 project
#
# Building (out of source build):
# > mkdir build && cd build
# > cmake .. [-DSETTINGS=VALUE]
# > cmake --build .
#
# Testing:
# > ctest -V
#
# Install:
# > cmake --build . --target install

PROJECT(libgit2 C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

# Add find modules to the path
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Build options
#
OPTION( SONAME				"Set the (SO)VERSION of the target"		ON  )
OPTION( BUILD_SHARED_LIBS	"Build Shared Library (OFF for Static)"	ON )
OPTION( THREADSAFE			"Build libgit2 as threadsafe"			OFF )
OPTION( PROFILE				"Generate profiling information"		OFF )
OPTION( ENABLE_TRACE		"Enables tracing support"				OFF )
OPTION( LIBGIT2_FILENAME	"Name of the produced binary" OFF )

IF(MSVC)
	# This option is only availalbe when building with MSVC. By default,
	# libgit2 is build using the stdcall calling convention, as that's what
	# the CLR expects by default and how the Windows API is built.
	#
	# If you are writing a C or C++ program and want to link to libgit2, you
	# have to either:
	# - Add /Gz to the compiler options of _your_ program / library.
	# - Turn this off by invoking CMake with the "-DSTDCALL=Off" argument.
	#
	OPTION( STDCALL			"Build libgit2 with the __stdcall convention"	ON  )

	# This option must match the settings used in your program, in particular if you
	# are linking statically
	OPTION( STATIC_CRT		"Link the static CRT libraries"	ON  )
ENDIF()

# Installation paths
#
SET(BIN_INSTALL_DIR bin CACHE PATH "Where to install binaries to.")
SET(LIB_INSTALL_DIR lib${LIB_SUFFIX} CACHE PATH "Where to install libraries to.")
SET(INCLUDE_INSTALL_DIR include CACHE PATH "Where to install headers to.")

FUNCTION(TARGET_OS_LIBRARIES target)
	IF(WIN32)
		TARGET_LINK_LIBRARIES(${target} ws2_32)
	ELSEIF(CMAKE_SYSTEM_NAME MATCHES "(Solaris|SunOS)")
		TARGET_LINK_LIBRARIES(${target} socket nsl)
	ENDIF ()
	IF(THREADSAFE)
		TARGET_LINK_LIBRARIES(${target} ${CMAKE_THREAD_LIBS_INIT})
	ENDIF()
ENDFUNCTION()

# For the MSVC IDE, this function splits up the source files like windows
# explorer does. This is esp. useful with the libgit2_clar project, were
# usually 2 or more files share the same name.  Sadly, this file grouping
# is a per-directory option in cmake and not per-target, resulting in
# empty virtual folders "tests-clar" for the git2.dll
FUNCTION(MSVC_SPLIT_SOURCES target)
	IF(MSVC_IDE)
		GET_TARGET_PROPERTY(sources ${target} SOURCES)
		FOREACH(source ${sources})
			IF(source MATCHES ".*/")
				STRING(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/ "" rel ${source})
				IF(rel)
					STRING(REGEX REPLACE "/([^/]*)$" "" rel ${rel})
					IF(rel)
						STRING(REPLACE "/" "\\\\" rel ${rel})
						SOURCE_GROUP(${rel} FILES ${source})
					ENDIF()
				ENDIF()
			ENDIF()
		ENDFOREACH()
	ENDIF()
ENDFUNCTION()

FILE(STRINGS "include/git2/version.h" GIT2_HEADER REGEX "^#define LIBGIT2_VERSION \"[^\"]*\"$")

STRING(REGEX REPLACE "^.*LIBGIT2_VERSION \"([0-9]+).*$" "\\1" LIBGIT2_VERSION_MAJOR "${GIT2_HEADER}")
STRING(REGEX REPLACE "^.*LIBGIT2_VERSION \"[0-9]+\\.([0-9]+).*$" "\\1" LIBGIT2_VERSION_MINOR  "${GIT2_HEADER}")
STRING(REGEX REPLACE "^.*LIBGIT2_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" LIBGIT2_VERSION_REV "${GIT2_HEADER}")
SET(LIBGIT2_VERSION_STRING "${LIBGIT2_VERSION_MAJOR}.${LIBGIT2_VERSION_MINOR}.${LIBGIT2_VERSION_REV}")

# Find required dependencies
INCLUDE_DIRECTORIES(src include)

IF (WIN32 AND NOT MINGW)
	ADD_DEFINITIONS(-DGIT_WINHTTP)
ELSE ()
	IF (NOT AMIGA)
		FIND_PACKAGE(OpenSSL)
	ENDIF ()

	FIND_PACKAGE(HTTP_Parser QUIET)
	IF (HTTP_PARSER_FOUND AND HTTP_PARSER_VERSION_MAJOR EQUAL 2)
		INCLUDE_DIRECTORIES(${HTTP_PARSER_INCLUDE_DIRS})
		LINK_LIBRARIES(${HTTP_PARSER_LIBRARIES})
	ELSE()
		MESSAGE("http-parser was not found or is too old; using bundled 3rd-party sources.")
		INCLUDE_DIRECTORIES(deps/http-parser)
		FILE(GLOB SRC_HTTP deps/http-parser/*.c)
	ENDIF()
ENDIF()

# Specify sha1 implementation
IF (WIN32 AND NOT MINGW AND NOT SHA1_TYPE STREQUAL "builtin")
	ADD_DEFINITIONS(-DWIN32_SHA1)
	FILE(GLOB SRC_SHA1 src/hash/hash_win32.c)
ELSEIF (OPENSSL_FOUND AND NOT SHA1_TYPE STREQUAL "builtin")
	ADD_DEFINITIONS(-DOPENSSL_SHA1)
ELSE()
	FILE(GLOB SRC_SHA1 src/hash/hash_generic.c)
ENDIF()

# Enable tracing
IF (ENABLE_TRACE STREQUAL "ON")
	ADD_DEFINITIONS(-DGIT_TRACE)
ENDIF()

# Include POSIX regex when it is required
IF(WIN32 OR AMIGA)
	INCLUDE_DIRECTORIES(deps/regex)
	SET(SRC_REGEX deps/regex/regex.c)
ENDIF()

# Optional external dependency: zlib
# It's optional, but FIND_PACKAGE gives a warning that looks more like an
# error.
FIND_PACKAGE(ZLIB QUIET)
IF (ZLIB_FOUND)
	INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIRS})
	LINK_LIBRARIES(${ZLIB_LIBRARIES})
	# Fake the message CMake would have shown
	MESSAGE("-- Found zlib: ${ZLIB_LIBRARY}")
ELSE()
	MESSAGE( "zlib was not found; using bundled 3rd-party sources." )
	INCLUDE_DIRECTORIES(deps/zlib)
	ADD_DEFINITIONS(-DNO_VIZ -DSTDC -DNO_GZIP)
	FILE(GLOB SRC_ZLIB deps/zlib/*.c)
ENDIF()

IF(NOT LIBSSH2_LIBRARY)
	FIND_PACKAGE(LIBSSH2 QUIET)
ENDIF()
IF (LIBSSH2_FOUND)
	ADD_DEFINITIONS(-DGIT_SSH)
	INCLUDE_DIRECTORIES(${LIBSSH2_INCLUDE_DIR})
	SET(SSH_LIBRARIES ${LIBSSH2_LIBRARIES})
ENDIF()

# Platform specific compilation flags
IF (MSVC)

	STRING(REPLACE "/Zm1000" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

	# /GF - String pooling
	# /MP - Parallel build
	SET(CMAKE_C_FLAGS "/GF /MP /nologo ${CMAKE_C_FLAGS}")

	IF (STDCALL)
		# /Gz - stdcall calling convention
		SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /Gz")
	ENDIF ()

	IF (STATIC_CRT)
		SET(CRT_FLAG_DEBUG "/MTd")
		SET(CRT_FLAG_RELEASE "/MT")
	ELSE()
		SET(CRT_FLAG_DEBUG "/MDd")
		SET(CRT_FLAG_RELEASE "/MD")
	ENDIF()

	# /Zi - Create debugging information
	# /Od - Disable optimization
	# /D_DEBUG - #define _DEBUG
	# /MTd - Statically link the multithreaded debug version of the CRT
	# /MDd - Dynamically link the multithreaded debug version of the CRT
	# /RTC1 - Run time checks
	SET(CMAKE_C_FLAGS_DEBUG "/Zi /Od /D_DEBUG /RTC1 ${CRT_FLAG_DEBUG}")

	# /DNDEBUG - Disables asserts
	# /MT - Statically link the multithreaded release version of the CRT
	# /MD - Dynamically link the multithreaded release version of the CRT
	# /O2 - Optimize for speed
	# /Oy - Enable frame pointer omission (FPO) (otherwise CMake will automatically turn it off)
	# /GL - Link time code generation (whole program optimization)
	# /Gy - Function-level linking
	SET(CMAKE_C_FLAGS_RELEASE "/DNDEBUG /O2 /Oy /GL /Gy ${CRT_FLAG_RELEASE}")

	# /Oy- - Disable frame pointer omission (FPO)
	SET(CMAKE_C_FLAGS_RELWITHDEBINFO "/DNDEBUG /Zi /O2 /Oy- /GL /Gy ${CRT_FLAG_RELEASE}")

	# /O1 - Optimize for size
	SET(CMAKE_C_FLAGS_MINSIZEREL "/DNDEBUG /O1 /Oy /GL /Gy ${CRT_FLAG_RELEASE}")

	# /DYNAMICBASE - Address space load randomization (ASLR)
	# /NXCOMPAT - Data execution prevention (DEP)
	# /LARGEADDRESSAWARE - >2GB user address space on x86
	# /VERSION - Embed version information in PE header
	SET(CMAKE_EXE_LINKER_FLAGS "/DYNAMICBASE /NXCOMPAT /LARGEADDRESSAWARE /VERSION:${LIBGIT2_VERSION_MAJOR}.${LIBGIT2_VERSION_MINOR}")

	# /DEBUG - Create a PDB
	# /LTCG - Link time code generation (whole program optimization)
	# /OPT:REF /OPT:ICF - Fold out duplicate code at link step
	# /INCREMENTAL:NO - Required to use /LTCG
	# /DEBUGTYPE:cv,fixup - Additional data embedded in the PDB (requires /INCREMENTAL:NO, so not on for Debug)
	SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "/DEBUG")
	SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "/RELEASE /LTCG /OPT:REF /OPT:ICF /INCREMENTAL:NO")
	SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "/DEBUG /RELEASE /LTCG /OPT:REF /OPT:ICF /INCREMENTAL:NO /DEBUGTYPE:cv,fixup")
	SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "/RELEASE /LTCG /OPT:REF /OPT:ICF /INCREMENTAL:NO")

	# Same linker settings for DLL as EXE
	SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
	SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
	SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
	SET(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}")
	SET(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}")

	SET(WIN_RC "src/win32/git2.rc")

   # Precompiled headers

ELSE ()
	SET(CMAKE_C_FLAGS "-D_GNU_SOURCE -Wall -Wextra -Wno-missing-field-initializers -Wstrict-aliasing=2 -Wstrict-prototypes ${CMAKE_C_FLAGS}")

	IF (WIN32 AND NOT CYGWIN)
		SET(CMAKE_C_FLAGS_DEBUG "-D_DEBUG")
	ENDIF ()

	IF (MINGW) # MinGW always does PIC and complains if we tell it to
		STRING(REGEX REPLACE "-fPIC" "" CMAKE_SHARED_LIBRARY_C_FLAGS "${CMAKE_SHARED_LIBRARY_C_FLAGS}")
		# MinGW >= 3.14 uses the C99-style stdio functions
		# automatically, but forks like mingw-w64 still want
		# us to define this in order to use them
		ADD_DEFINITIONS(-D__USE_MINGW_ANSI_STDIO=1)

	ELSEIF (BUILD_SHARED_LIBS)
		SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden -fPIC")
	ENDIF ()
	IF (APPLE) # Apple deprecated OpenSSL
		SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-deprecated-declarations")
	ENDIF ()
	IF (PROFILE)
		SET(CMAKE_C_FLAGS "-pg ${CMAKE_C_FLAGS}")
		SET(CMAKE_EXE_LINKER_FLAGS "-pg ${CMAKE_EXE_LINKER_FLAGS}")
	ENDIF ()
ENDIF()

IF( NOT CMAKE_CONFIGURATION_TYPES )
	# Build Debug by default
	IF (NOT CMAKE_BUILD_TYPE)
		SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
	ENDIF ()
ELSE()
	# Using a multi-configuration generator eg MSVC or Xcode
	# that uses CMAKE_CONFIGURATION_TYPES and not CMAKE_BUILD_TYPE
ENDIF()

IF (OPENSSL_FOUND)
  ADD_DEFINITIONS(-DGIT_SSL)
  INCLUDE_DIRECTORIES(${OPENSSL_INCLUDE_DIR})
  SET(SSL_LIBRARIES ${OPENSSL_LIBRARIES})
ENDIF()

IF (THREADSAFE)
	IF (NOT WIN32)
		find_package(Threads REQUIRED)
	ENDIF()

	ADD_DEFINITIONS(-DGIT_THREADS)
ENDIF()

ADD_DEFINITIONS(-D_FILE_OFFSET_BITS=64)

# Collect sourcefiles
FILE(GLOB SRC_H include/git2/*.h)

# On Windows use specific platform sources
IF (WIN32 AND NOT CYGWIN)
	ADD_DEFINITIONS(-DWIN32 -D_WIN32_WINNT=0x0501)
	FILE(GLOB SRC_OS src/win32/*.c)
ELSEIF (AMIGA)
	ADD_DEFINITIONS(-DNO_ADDRINFO -DNO_READDIR_R)
	FILE(GLOB SRC_OS src/amiga/*.c)
ELSE()
	FILE(GLOB SRC_OS src/unix/*.c)
ENDIF()
FILE(GLOB SRC_GIT2 src/*.c src/transports/*.c src/xdiff/*.c)

# Determine architecture of the machine
IF (CMAKE_SIZEOF_VOID_P EQUAL 8)
	ADD_DEFINITIONS(-DGIT_ARCH_64)
ELSEIF (CMAKE_SIZEOF_VOID_P EQUAL 4)
	ADD_DEFINITIONS(-DGIT_ARCH_32)
ELSE()
	message(FATAL_ERROR "Unsupported architecture")
ENDIF()

# Compile and link libgit2
ADD_LIBRARY(git24kup ${SRC_GIT2} ${SRC_OS} ${SRC_ZLIB} ${SRC_HTTP} ${SRC_REGEX} ${SRC_SHA1} ${WIN_RC})
TARGET_LINK_LIBRARIES(git24kup ${SSL_LIBRARIES})
TARGET_LINK_LIBRARIES(git24kup ${SSH_LIBRARIES})
TARGET_OS_LIBRARIES(git24kup)

# Workaround for Cmake bug #0011240 (see http://public.kitware.com/Bug/view.php?id=11240)
# Win64+MSVC+static libs = linker error
IF(MSVC AND GIT_ARCH_64 AND NOT BUILD_SHARED_LIBS)
  SET_TARGET_PROPERTIES(git24kup PROPERTIES STATIC_LIBRARY_FLAGS "/MACHINE:x64")
ENDIF()

MSVC_SPLIT_SOURCES(git24kup)

IF (SONAME)
	SET_TARGET_PROPERTIES(git24kup PROPERTIES VERSION ${LIBGIT2_VERSION_STRING})
	SET_TARGET_PROPERTIES(git24kup PROPERTIES SOVERSION ${LIBGIT2_VERSION_MAJOR})
	IF (LIBGIT2_FILENAME)
		ADD_DEFINITIONS(-DLIBGIT2_FILENAME=\"${LIBGIT2_FILENAME}\")
		SET_TARGET_PROPERTIES(git24kup PROPERTIES OUTPUT_NAME ${LIBGIT2_FILENAME})
	ENDIF()
ENDIF()

IF (MSVC_IDE)
   # Precompiled headers
   SET_TARGET_PROPERTIES(git24kup PROPERTIES COMPILE_FLAGS "/Yuprecompiled.h /FIprecompiled.h")
   SET_SOURCE_FILES_PROPERTIES(src/win32/precompiled.c COMPILE_FLAGS "/Ycprecompiled.h")
ENDIF ()

# Install
INSTALL(TARGETS git24kup
	RUNTIME DESTINATION ${BIN_INSTALL_DIR}
	LIBRARY DESTINATION ${LIB_INSTALL_DIR}
	ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
)
#INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libgit2.pc DESTINATION ${LIB_INSTALL_DIR}/pkgconfig )
#INSTALL(DIRECTORY include/git2 DESTINATION ${INCLUDE_INSTALL_DIR} )
#INSTALL(FILES include/git2.h DESTINATION ${INCLUDE_INSTALL_DIR} )

