FORMAT=elf
CC=/usr/bin/nasm
LD=/usr/bin/ld
RM=/bin/rm
CFLAGS=-f $(FORMAT) -g -w-macro-params
SOURCES=linux.asm stdio.asm stdlib.asm ctype.asm string.asm time.asm terminal.asm FusoCommon.asm
OBJECTS=$(SOURCES:.asm=.o)

all: FusoGrav FusoCalc

clean:
	@echo "Cleaning"
	@$(RM) -f *.o *~ FusoGrav FusoCalc

%.o: %.asm
	@echo "Assembling $@"
	@$(CC) $(CFLAGS) $< -o $@

FusoGrav: FusoGrav.o $(OBJECTS)
	@echo "Linking $@"
	@$(LD) $(LDFLAGS) $^ -o $@

FusoCalc: FusoCalc.o $(OBJECTS)
	@echo "Linking $@"
	@$(LD) $(LDFLAGS) $^ -o $@
