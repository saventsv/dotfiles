# Simple Makefile for SWM

# Compiler
CC = gcc

# Compiler flags
CFLAGS = -O2 -Wall -Wextra -std=c11

# Libraries to link
LIBS = -lX11

# Target executable
TARGET = swm

# Source files
SRC = main.c

# Desktop file location
DESKTOP_FILE = desktop/swm.desktop
XSESSION_DIR = /usr/share/xsessions/

# Install locations
BIN_DIR = /usr/local/bin
DESKTOP_DIR = /usr/share/applications

# Default target
all: $(TARGET)

# Build the target
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LIBS)

# Clean up build files
clean:
	rm -f $(TARGET)

# Install the binary and the .desktop file
install: $(TARGET)
	# Install the window manager binary to /usr/local/bin
	install -Dm755 $(TARGET) $(BIN_DIR)/$(TARGET)
	# Install the desktop entry to /usr/share/xsessions
	install -Dm644 $(DESKTOP_FILE) $(DESKTOP_DIR)/$(TARGET).desktop
	# Optional: You can also install to the Xsession directory if you need a custom session
	install -Dm644 $(DESKTOP_FILE) $(XSESSION_DIR)/$(TARGET).desktop

# Uninstall (removes files from system)
uninstall:
	rm -f $(BIN_DIR)/$(TARGET)
	rm -f $(DESKTOP_DIR)/$(TARGET).desktop
	rm -f $(XSESSION_DIR)/$(TARGET).desktop

# Run the window manager (for testing or usage purposes)
run:
	./$(TARGET)
