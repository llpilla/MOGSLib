CPP=g++
PYTHON_VERSION = 2.7
PV = 27
PYTHON_INCLUDE = /usr/include/python$(PYTHON_VERSION)
PYTHON_LIB = /usr/lib/python$(PYTHON_VERSION)/config
LIBS = -L$(PYTHON_LIB) -lboost_python -lpython$(PYTHON_VERSION)
MOGSLIB = ../../include/

TARGET = mogslib
SOURCES = cppsrc/scheduler_for_python

all: $(TARGET).so

$(TARGET).so: $(SOURCES).o
	$(CPP) -shared -Wl,--export-dynamic $(SOURCES).o $(LIBS) -o $(TARGET).so

$(SOURCES).o: $(SOURCES).cpp
	$(CPP) -I$(PYTHON_INCLUDE) -I$(MOGSLIB) -fPIC -c $(SOURCES).cpp -o $(SOURCES).o

clean:
	rm $(SOURCES).o $(TARGET).so
