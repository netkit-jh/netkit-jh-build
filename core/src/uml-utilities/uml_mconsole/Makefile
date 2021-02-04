OBJS = uml_mconsole.o
BIN = uml_mconsole
CFLAGS ?= -g -Wall
LIBS = ../lib/libuml.a -lreadline

all : $(BIN)

$(BIN) : $(OBJS)
	$(CC) $(CFLAGS) -o $(BIN) $(OBJS) $(LIBS)

clean : 
	rm -f $(BIN) $(OBJS)