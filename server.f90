!
! File server.f90
!
! This is a Fortran source code to demonstrate how to write a
! server in Fortran using sockets.
!
! This code creates and connects to a socket. Then it loops by
! sending a string on the socket (to show how to do it), then reads
! on the socket, echoing what it read on the terminal (stdout).
! The loop goes on until reading the string "STOP" at which point
! the program closes the connecton and exits.
!
! In this code, it is assumed that the server and the client are running
! on the same machine (IP 127.0.0.1). Both should use port 1024; this is
! very easy to change: simply change the value of the variable "port".
!
! This source is inspired by the server coded in C provided on
!   https://www.thegeekstuff.com/2011/12/c-socket-programming/
!
! This code has been developed and tested on a 64 bits PC computer
! running Ubuntu 18.04, compiled with gfortran (gcc version 7.5.0).
! I am not sure it is portable. A part is a Fortran
! translation of C struct as declared in this system; if this struct is
! different on your computer, or if it changes in the future, this code
! should be adapted.
! This struct translates into the sockaddr_in TYPE.
! 
! Code developed by Philippe Preux, Université de Lille, France & Inria.
! Put online April 4th, 2020, on https://ph-preux.github.io/...
!
! Disclaimer: I am no Fortran programmer; it is most likely that this code
! may be written better, that some parts may be better written, ...
! Being a C programmer, the real difficulty I met was figuring out how to
! translate C types into Fortran equivalent, and passing the arguments
! correctly for system calls.
!
! This code has been developed and is provided to the community only to
! serve as a demonstrator. It might not work on your computer, it mght not
! meet your expectations. In any case, this code has not been made in order
! to cause any harm neither to anyone, nor to any computer, nor to anything.
! That being said, you use this code under your own responsability, and risks.
!
! This code is freely available under MIT licence.
!
program testsocket
  use, intrinsic :: iso_c_binding
  use str2int_mod
  
  implicit none
  
  interface
     function socket(domain, type, protocol) bind(c, name="socket")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: socket
       integer(kind=c_int), value :: domain, type, protocol
     end function socket
     
     function bind(fd, addr, sizeof_arg) bind(c, name="bind")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: bind
       integer(kind=c_int), value :: fd
       type(c_ptr), value :: addr
       integer(kind=c_int64_t), value :: sizeof_arg
     end function bind
     
     function listen(listenfd, size) bind (c, name="listen")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: listen
       integer(kind=c_int), value :: listenfd
       integer(kind=c_int), value :: size
     end function listen
     
     function send(connfd, str, size, flags) bind (c, name="send")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: send
       integer(kind=c_int), value :: connfd
       character(1,kind=c_char), value :: str
       integer(kind=c_int), value :: size, flags
     end function send

     function c_read(fd, str, size) bind (c, name="read")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: c_read
       integer(kind=c_int), value :: fd
       type(c_ptr), value :: str
       integer(c_size_t), value :: size
     end function c_read

     function c_write(fd, str, size) bind (c, name="write")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: c_write
       integer(kind=c_int), value :: fd
       type(c_ptr), value :: str
       integer(c_size_t), value :: size
     end function c_write
     
     function accept(listenfd, np1, np2) bind (c, name="accept")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: accept
       integer(kind=c_int), value :: listenfd
       type(c_ptr), value :: np1, np2
     end function accept
     
     function htonl(i) bind (c, name="htonl")
       use, intrinsic :: iso_c_binding
       integer(kind=c_int) :: htonl
       integer(kind=c_int), value :: i
     end function htonl
     
     function htons(i) bind (c, name="htons")
       use, intrinsic :: iso_c_binding
       integer(kind=c_short) :: htons
       integer(kind=c_int), value :: i
     end function htons

     function C_memset(s, c, n) result(result) bind(C,name="memset")
       import C_ptr, C_int, C_size_t
       type(C_ptr) :: result
       type(C_ptr), value, intent(in) :: s
       integer(C_int), value, intent(in) :: c
       integer(C_size_t), value, intent(in) :: n
     end function C_memset

     function C_strlen(s) bind(C,name="strlen")
       use, intrinsic :: iso_c_binding
       integer(C_size_t) :: C_strlen
       type(C_ptr), value, intent(in) :: s
     end function C_strlen

     function C_strcmp(s1, s2) bind(C,name="strcmp")
       use, intrinsic :: iso_c_binding
       integer(C_int) :: C_strcmp
       type(C_ptr), value, intent(in) :: s1
       type(C_ptr), value, intent(in) :: s2
     end function C_strcmp
  end interface
  
  TYPE, BIND(C) :: sockaddr_in
     INTEGER(C_SHORT) :: sin_family, sin_port
     INTEGER(C_INT) :: sin_addr
     character(8,kind=c_char) :: sin_zero
  END TYPE sockaddr_in

  integer(kind=c_int) :: listenfd, connfd, b, l, port = 1024
  integer(c_size_t) lgth
  integer(kind=c_int64_t) :: seize, valread
  type(sockaddr_in), target :: addr
  type(c_ptr) :: NULL = C_NULL_PTR, n
  CHARACTER(len=128), target :: buffer
  integer(c_size_t) :: buffer_size = 128
  CHARACTER(len=32), target :: hw = "hello world"//C_NULL_CHAR
  CHARACTER(len=32), target :: stop_str = "STOP"//C_NULL_CHAR
  lgth = C_strlen (c_loc (hw))

  ! in the next statment, the first argument means AF_INET,
  ! the second one means SOCK_DGRAM, the third one is IP_PROTOCOL.
  listenfd = socket (2_c_int, 1_c_int, 0_c_int)
  if (listenfd .ne. -1) then
     n = C_memset (c_loc(addr), 0, sizeof(addr))        
     addr%sin_family = 2 ! AF_INET
     addr%sin_port = htons (port)
     addr%sin_addr = htonl (0) ! means INADDR_ANY
     addr%sin_zero = "00000000"
     seize = sizeof(addr)
     b = bind (listenfd, c_loc (addr), seize)
     l = listen (listenfd, 10_c_int)
     connfd = accept (listenfd, NULL, NULL)
     ! the main server/client interacting loop:
     ! first, the server (this program) sends a nice string to the client
     ! then, it reads a string sent by the client, and prints it out on stdout.
     ! The process goes on until the client gets bored by this dull
     ! conversation and sends a STOP.
     do
        l = c_write (connfd, c_loc (hw), lgth)
        n = C_memset (c_loc(buffer), 0, sizeof(buffer_size))
        valread = c_read (connfd, c_loc (buffer), buffer_size)
        buffer ((valread+1):buffer_size) = C_NULL_CHAR
        if (.not. (C_strcmp (c_loc (buffer), c_loc (stop_str)) .eq. 0)) then
           print "(a,a)", "I read: ", buffer
        else
           print "(a)", "I read STOP. Exiting..."
           exit
        end if
     end do
     close (connfd)
  else
     write (*,*) "Can not connect to port"
  end if
end program testsocket
