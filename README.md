Demo of a Fortran code communicating through a socket with a client
===================================================================

Purpose of this repo
--------------------

I wanted to be able to make a Fortran code communicate with an other program. Sockets were the simplest solution to achieve this. Being no Fortran programmer, I struggled to figure out how to do it. I was expecting to find some sort of example code on the web but I failed to. The web contains many examples of server/client programming in C and higher level languages. I was not able to find such an example in Fortran. So, now that I achieved my goal, I put a simple example on the web in the hope that this may help people out there.

Difficulties
-------------

Server/client communications is part of the basic training of a student in computer science at master level. Usually, this is put into practice in C or some other higher level language (usually in Python these days). 

I am a C programmer (and other languages) but I am no Fortran programmer. So the biggest difficulty turned out for me to understand the equivalence between Fortran types and C types, and how to call (C) system functions passing the correctly typed parameters in the Fortran code.

The content of this repo
------------------------

This repo contains:
* ``server.f90``: a Fortran code that acts as a server in a socket based server/client communication.
* ``client.c``: a C code that acts as a client in a socket based server/client communication.
* ``str2int.f90``: a utility Fortran subroutine to cnvert a string into an integer value.
* ``Makefile``: to create the executables, ``server`` and ``client``.

Usage
-----

* ``git clone ...``
* ``cd xxx``
* ``make``
  This should create two executable files, one named ``server`` the second one named ``client``
* ``./server``
* in an other window, type ``./client``
  There is goes: the two are exchanging a couple of mundanities and stop.

Feedback
--------

If you find some bug, or if you can provide a better coded source, or a more portable code, please email me.

Ack
---

While developing this demo, I benefited from a couple of helps:
* the client/server example in C at this url:
* this other client/server example in C at this url:
* the client/server example in Fortran at this url: