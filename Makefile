
COMMON_FLAGS=

ifeq ($(ARCH),arm)
	ARCHFLAGS = -DHAVE_ARM_TLS_REGISTER -DANDROID_ARM_LINKER
else
	ARCHFLAGS = -DANDROID_X86_LINKER
endif


COMMON_SOURCES=common/strlcpy.c common/hooks.c common/properties.c

GINGERBREAD_SOURCES=gingerbread/linker.c gingerbread/dlfcn.c gingerbread/rt.c gingerbread/linker_environ.c gingerbread/linker_format.c
ICS_SOURCES=ics/linker.c ics/dlfcn.c ics/rt.c ics/linker_environ.c ics/linker_format.c

all:  libhybris_ics.so libEGL.so.1 test_egl libGLESv2.so.2 test_glesv2


libhybris_ics.so: $(COMMON_SOURCES) $(ICS_SOURCES)
	$(CC) -g -shared -o $@ -ldl -pthread -fPIC -Igingerbread -Icommon -DLINKER_DEBUG=1 -DLINKER_TEXT_BASE=0xB0000100 -DLINKER_AREA_SIZE=0x01000000 $(ARCHFLAGS) \
		$(ICS_SOURCES) $(COMMON_SOURCES)


libEGL.so.1.0: egl/egl.c
	$(CC) -g -shared -o $@ -fPIC -Wl,-soname,libEGL.so.1 $< libhybris_ics.so

libEGL.so.1: libEGL.so.1.0
	ln -sf libEGL.so.1.0 libEGL.so.1

test_egl: libEGL.so.1 libGLESv2.so.2 egl/test.c libhybris_ics.so
	$(CC) -g -o $@ egl/test.c libEGL.so.1 libGLESv2.so.2 libhybris_ics.so  -I .

libGLESv2.so.2.0: glesv2/gl2.c
	$(CC) -g -shared -o $@ -fPIC -Wl,-soname,libGLESv2.so.2 $< libhybris_ics.so

libGLESv2.so.2: libGLESv2.so.2.0
	ln -sf libGLESv2.so.2.0 libGLESv2.so.2

test_glesv2: libEGL.so.1 libGLESv2.so.2 egl/test.c libhybris_ics.so
	$(CC) -g -o $@ glesv2/test.c -lm libEGL.so.1 libhybris_ics.so libGLESv2.so.2 

clean:
	rm -rf libhybris_gingerbread.so test_gingerbread
	rm -rf libhybris_ics.so test_ics
	rm -rf libEGL* libGLESv2*
	rm -rf test_*

