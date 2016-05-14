# see: https://github.com/devkitPro/gba-examples/blob/master/template/Makefile

.SUFFIXES:
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM)
endif

include $(DEVKITARM)/gba_rules

TARGET   :=	$(shell basename $(CURDIR))_mb
BUILD	   :=	build
SOURCES  :=	src
DATA		 := data
GRAPHICS :=	gfx
INCLUDES := src

ARCH :=	-mthumb -mthumb-interwork

CFLAGS :=	-g -Wall -O3 -mcpu=arm7tdmi -mtune=arm7tdmi -fomit-frame-pointer -ffast-math $(ARCH)

CFLAGS += $(INCLUDE)

CXXFLAGS := $(CFLAGS) -fno-rtti -fno-exceptions

ASFLAGS := $(ARCH)
LDFLAGS = -g $(ARCH) -Wl,-Map,$(notdir $@).map

LIBS := -lgba

LIBDIRS := $(LIBGBA)

ifneq ($(BUILD),$(notdir $(CURDIR)))

export OUTPUT	:=	$(CURDIR)/$(TARGET)
export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) $(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))
BMPFILES	:=	$(foreach dir,$(GRAPHICS),$(notdir $(wildcard $(dir)/*.bmp)))

ifeq ($(strip $(CPPFILES)),)
	export LD	:=	$(CC)
else
	export LD	:=	$(CXX)
endif

export OFILES := $(addsuffix .o,$(BINFILES)) $(BMPFILES:.bmp=.o) $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

export INCLUDE := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) $(foreach dir,$(LIBDIRS),-I$(dir)/include) -I$(CURDIR)/$(BUILD)

export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

.PHONY: $(BUILD) clean

$(BUILD):
	@[ -d $@ ] || mkdir -p $@
	@make --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

all: $(BUILD)

clean:
	@echo clean ...
	@rm -fr $(BUILD) $(TARGET).elf $(TARGET).gba

else

DEPENDS	:= $(OFILES:.o=.d)

$(OUTPUT).gba: $(OUTPUT).elf

$(OUTPUT).elf: $(OFILES)

%.bin.o:	%.bin
	@echo $(notdir $<)
	@$(bin2o)

%.raw.o:	%.raw
	@echo $(notdir $<)
	@$(bin2o)

# TODO: Figure out why the rule below won't work
image.s image.h: ../gfx/image.bmp
	grit $< -fts -o$*

%.s %.h: %.bmp # %.grit
	grit $< -fts -o$*

-include $(DEPENDS)

endif
