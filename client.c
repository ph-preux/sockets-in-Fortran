/*
 * File client.c
 *
 * This C source file comes along the server.f90 Fortran source to
 * demonstrate a simple server/client communication through sockets.
 * This client could have been written in any language. It is straitforward 
 * to write such a client in e.g. Python.
 *
 * This codes open a socket on which it expects a server is waiting for it.
 * As provided, server and client should run on the ame computer 
 * (IP 127.0.0.1), and communicate through port 1024. This value is easy 
 * to change through the PORT macro definition below.
 * 
 * When the connection is established with the server, this client loops.
 * At each iteration, it reads a string sent by the server, 
 * and then sends a message to it. The content of this message is a number,
 * starting at 10, incrementing it until 19 at which points is sends a
 * "STOP" string to the server to stop the communication.
 * I think the code is very simple and anyone understanding what it is about
 * may tailor it to his/her needs.
 * I have the hope that this client code is pretty portable; as explained in
 * its source code, I don't have the same optimism about the server.
 * This code has been developed and tested on a 64 bits PC computer
 * running Ubuntu 18.04, compiled by gcc version 7.5.0.
 *
 * Code developed by Philippe Preux, Université de Lille, France & Inria.
 * Put online on April 4th, 2020, on https://ph-preux.github.io/...
 *
 * Inspired by
 *    https://www.binarytides.com/server-client-example-c-sockets-linux/
 *
 * This code has been developed and is provided to the community only to
 * serve as a demonstrator. It might not work on your computer, it mght not
 * meet your expectations. In any case, this code has not been made in order
 * to cause any harm neither to anyone, nor to any computer, nor to anything.
 * That being said, you use this code under your own responsability, and risks.
 *
 * This code is freely available under MIT licence.
 *
 */

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h> 

#define PORT 1024

int main()
{
  int sockfd = 0, n = 0;
  char recvBuff[1024];
  struct sockaddr_in serv_addr; 
  
  memset(recvBuff, '0',sizeof(recvBuff));
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    printf("\n Error : Could not create socket \n");
    exit (EXIT_FAILURE);
  }
  
  memset(&serv_addr, '0', sizeof(serv_addr)); 
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(PORT); 
  
  char adresse_IP [10] = "127.0.0.1";
    
  if (inet_pton (AF_INET, adresse_IP, &serv_addr.sin_addr)<=0) {
    printf("\n inet_pton error occured\n");
    exit (EXIT_FAILURE);
  }

  if (connect (sockfd, (struct sockaddr *) &serv_addr,
	       sizeof(serv_addr)) < 0) {
    printf("\n Error : Connect Failed \n");
    return 1;
  } 
  char buffer[10] = {0};
  for (;;) {
    static int count = 10;
    while ((n = read(sockfd, recvBuff, sizeof(recvBuff)-1)) > 0) {
      recvBuff [n] = 0;
      fprintf (stderr, "I read: %s\n", recvBuff);
      if (count < 20) sprintf (buffer, "%d", count ++);
      else {
	sprintf (buffer, "STOP");
	fprintf (stderr, "I stop.\n");
	write (sockfd, buffer, strlen (buffer));
	exit (EXIT_SUCCESS);
      }
      fprintf (stderr, "I send %d (%s)\n", count - 1, buffer);
      write (sockfd, buffer, strlen (buffer));
    }
    if (n < 0) printf("\n Read error \n");
  }
  /* the program can not reach this point. */
  exit (EXIT_SUCCESS);
}
