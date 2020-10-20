
dest:=sla

.PHONY:all
all : $(dest)

libsla_challenge.so : SLA_Challenge.c SLA_Challenge.h libcrypto.a
	gcc SLA_Challenge.c libcrypto.a -fPIC -shared -o libsla_challenge.so
	
$(dest) : libsla_challenge.so main.c
	gcc -o $(dest) main.c -L. -lsla_challenge -lpthread -ldl
	
	
.PHONY:clean
clean:
	-rm $(dest) *.o libsla_challenge.so

