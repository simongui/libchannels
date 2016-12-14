projectpath = ${CURDIR}
libuv_path = ${projectpath}/lib/libuv
wrk_path = ${projectpath}/lib/wrk
wrk2_path = ${projectpath}/lib/wrk2
sds_path = ${projectpath}/lib/sds


ifeq ($(OS),Windows_NT)
		OPERATING_SYSTEM = WINDOWS
    CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        CCFLAGS += -D AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            CCFLAGS += -D AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            CCFLAGS += -D IA32
        endif
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
				OPERATING_SYSTEM = LINUX
				PLATFORM_TARGET = linux
        CCFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
				OPERATING_SYSTEM = OSX
				PLATFORM_TARGET = osx
        CCFLAGS += -D OSX
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        CCFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        CCFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        CCFLAGS += -D ARM
    endif
endif

all: deps $(PLATFORM_TARGET)

target: all 

osx: deps
	if [ ! -d "build" ]; then mkdir -p build; fi
	if [ ! -d "build/Makefile" ]; then cd build;cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 ..; fi
	cmake --build ./build --target all --config Debug -- -j 10

xcode: deps
	if [ ! -d "build" ]; then mkdir -p build; fi
	if [ ! -d "build/libchannels.xcodeproj" ]; then cd build;cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 -G Xcode ..; fi
	cd build;xcodebuild -project libchannels.xcodeproj/

linux:
	rm -rf build
	mkdir -p build
	cd build;cmake ..
	cd build;make VERBOSE=1

$(libuv_path)/.libs/libuv.a:
	if [ ! -d "$(libuv_path)" ]; then git clone https://github.com/libuv/libuv.git $(libuv_path); fi
	cd $(libuv_path);sh autogen.sh
	cd $(libuv_path);./configure
	cd $(libuv_path);make

$(wrk_path)/wrk:
	if [ ! -d "$(wrk_path)" ]; then git clone https://github.com/wg/wrk.git $(wrk_path); fi
	cd $(wrk_path);make

$(wrk2_path)/wrk:
	if [ ! -d "$(wrk2_path)" ]; then git clone https://github.com/giltene/wrk2.git $(wrk2_path); fi
	cd $(wrk2_path);make

$(sds_path):
	if [ ! -d "$(sds_path)" ]; then git clone https://github.com/antirez/sds.git $(sds_path); fi

tools: $(wrk_path)/wrk $(wrk2_path)/wrk

deps: $(libuv_path)/.libs/libuv.a $(sds_path)
