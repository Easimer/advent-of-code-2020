NIMC=nim c

EXES=$(patsubst %.nim,%.exe,$(wildcard *.nim))
DBGEXES=$(patsubst %.nim,%.dbg.exe,$(wildcard *.nim))

all: $(EXES) $(DBGEXES)

%.dbg.exe: %.nim
	$(NIMC) --debugger:native --checks:on --assertions:on -o:$@ $<

%.exe: %.nim
	$(NIMC) -d:release -o:$@ $<

clean:
	rm -f $(EXES) $(DBGEXES)

.PHONY: clean
