.PHONY: all clean release debug unittest
.DELETE_ON_ERROR:

RELEASE_BIN := warp.release
DEBUG_BIN   := warp.debug
UT_BIN      := warp.ut

RELEASE_DEBUG := $(RELEASE_BIN).debug

DC := dmd
STRIP := strip
OBJCOPY := objcopy

src_ext := .d
obj_ext := .o

COMMON_DFLAGS         := $(DFLAGS)
$(RELEASE_BIN)_DFLAGS := -O -inline -release
$(DEBUG_BIN)_DFLAGS   := -debug -g
$(UT_BIN)_DFLAGS      := -unittest


SRCS := cmdline.d constexpr.d context.d directive.d expanded.d file.d \
        id.d lexer.d loc.d macros.d main.d number.d outdeps.d ranges.d skip.d \
        sources.d stringlit.d textbuf.d charclass.d

g_objd = $(foreach x,$1,.$(patsubst warp.%,%,$x))

all : release debug unittest

release: $(RELEASE_DEBUG)
$(RELEASE_DEBUG): $(RELEASE_BIN)
	$(OBJCOPY) --only-keep-debug $< $@
	$(OBJCOPY) --add-gnu-debuglink=$@ $<
	$(STRIP) -s $<

debug: $(DEBUG_BIN)

unittest: $(UT_BIN)
	./$<

$(RELEASE_BIN) $(DEBUG_BIN) $(UT_BIN): $(SRCS)
	$(DC) $($@_DFLAGS) $(COMMON_DFLAGS) -od$(call g_objd,$@) -of$@ $^

clean :
	-rm -f $(RELEASE_BIN) $(DEBUG_BIN) $(UT_BIN) $(RELEASE_DEBUG)
	-rm -rf $(call g_objd,$(RELEASE_BIN) $(DEBUG_BIN) $(UT_BIN))

