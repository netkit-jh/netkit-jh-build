OBJS = rights.o
LIB = libuml.a
CFLAGS ?= -g -Wall

all : $(LIB)

$(LIB) : $(OBJS)
	$(AR) r $@ $<

clean :
	rm -f $(LIB) $(OBJS)