!! This module is for string manipulation
module string_utils

use, intrinsic:: iso_c_binding, only: c_null_char
implicit none
contains

elemental function toLower(str)
!! convert uppercase characters to lowercase
!!
!! can be trivially extended to non-ASCII
character(*), intent(in) :: str
character(len(str)) :: toLower
character(*), parameter :: lower="abcdefghijklmnopqrstuvwxyz", &
                           upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
integer :: i,j

toLower = str

do concurrent (i = 1:len(str))
  j = index(upper,str(i:i))
  if (j > 0) toLower(i:i) = lower(j:j)
end do

end function toLower


pure function strip_trailing_null(str) result(stripped)
!! strip trailing C null from strings

character(*), intent(in) :: str
character(:), allocatable :: stripped
integer :: i

i = len_trim(str)
if (str(i:i) == c_null_char) then
  stripped = str(:i-1)
else
  stripped = str
endif

end function strip_trailing_null

end module string_utils
