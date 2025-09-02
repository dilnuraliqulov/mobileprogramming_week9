 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
 int main(int argc, char *argv[])
 {
 pid_t  x, y;
 x = fork();
 if (x == 0) {
 y = fork();
 if (y == 0) {
 printf("PID=%d\n", getpid());
 exit(0);
 }
 }
 wait(NULL);
 printf("PID=%d\n", getpid());
 exit(0);
}