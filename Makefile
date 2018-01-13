# Makefile for TMalign

HEADERS = TMalign.cpp basic_fun.h  Kabsch.h NW.h TMalign.h
CXXFLAGS = -static -ffast-math -lm
RLSFLAGS = $(CXXFLAGS) -O3  # release build flags
DBGFLAGS = $(CXXFLAGS) -g3  # debugging build flags

EXECUTABLE = TMalign

all: TMalign

TMalign: $(HEADERS) TMalign.cpp

	g++ $(RLSFLAGS) -o $(EXECUTABLE) TMalign.cpp

debug: $(HEADERS) TMalign.cpp

	g++ $(DBGFLAGS) -o $(EXECUTABLE)_debug TMalign.cpp

clean:
	rm -f $(EXECUTABLE) $(EXECUTABLE)_debug

.PHONY: clean
