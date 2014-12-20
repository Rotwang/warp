.PHONY: all clean release debug unittest
.DELETE_ON_ERROR:

ifneq ($(MAKECMDGOALS),clean)
    ifeq ($(or $(COMPILER),$(INIT_FLAGS)),)
        $(error COMPILER or INIT_FLAGS parameters are mandatory!)
    endif
endif

GEN_DIR := generated
INIT_FLAGS := $(GEN_DIR)/$(COMPILER)/initialflags.d
_dir_out := $(dir $(INIT_FLAGS))

RELEASE_BIN := $(_dir_out)/warp.release
DEBUG_BIN   := $(_dir_out)/warp.debug
UT_BIN      := $(_dir_out)/warp.ut

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
        sources.d stringlit.d textbuf.d charclass.d $(INIT_FLAGS)

g_objd = $(foreach x,$1,$(_dir_out)/$(patsubst warp.%,%,$(notdir $x)))


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

$(INIT_FLAGS): $(COMPILER) | $(_dir_out)
	./prepare-init-flags --compiler "$(COMPILER)" > $@

clean :
	-rm -rf $(GEN_DIR)

$(_dir_out):
	-mkdir -p "$@"
