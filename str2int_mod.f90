!
! str2int_mod.f90
!
! This source is from
! https://stackoverflow.com/questions/24071722/converting-a-string-to-an-integer-in-fortran-90
!

module str2int_mod
contains 

  elemental subroutine str2int(str,int,stat)
    implicit none
    ! Arguments
    character(len=*),intent(in) :: str
    integer,intent(out)         :: int
    integer,intent(out)         :: stat

    read(str,*,iostat=stat)  int
  end subroutine str2int

end module str2int_mod
