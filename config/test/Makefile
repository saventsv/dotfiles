# Simple Makefile for SWM

CC = g++

CFLAGS = -O2 -Wall -Wextra 

LIBS = -lX11 $(shell pkg-config --libs lua)
CXXFLAGS += $(shell pkg-config --cflags lua)
TARGET = swm

SRC = main.cpp

DESKTOP_FILE = desktop/swm.desktop
XSESSION_DIR = /usr/share/xsessions/

BIN_DIR = /usr/local/bin
DESKTOP_DIR = /usr/share/applications

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LIBS)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -Dm755 $(TARGET) $(BIN_DIR)/$(TARGET)
	install -Dm644 $(DESKTOP_FILE) $(DESKTOP_DIR)/$(TARGET).desktop
	install -Dm644 $(DESKTOP_FILE) $(XSESSION_DIR)/$(TARGET).desktop

uninstall:
	rm -f $(BIN_DIR)/$(TARGET)
	rm -f $(DESKTOP_DIR)/$(TARGET).desktop
	rm -f $(XSESSION_DIR)/$(TARGET).desktop

run:
	./$(TARGET)
