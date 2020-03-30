program test_shape
!! This program shows how HDF5 dimension orders are distinct in different langauges
use h5fortran, only: hdf5_file,hsize_t
use, intrinsic:: iso_fortran_env, only: real64, stdout=>output_unit, stderr=>error_unit
implicit none

type(hdf5_file) :: h5f
character(1024) :: argv
character(:), allocatable :: fn, dname
integer(HSIZE_T), allocatable :: dims(:)
integer :: ierr
logical :: exists

if (command_argument_count() /= 2) error stop "filename dset_name"

call get_command_argument(1, argv)
fn = trim(argv)

call get_command_argument(2, argv)
dname = trim(argv)

inquire(file=fn, exist=exists)
if (.not. exists) then
  write(stderr, *) fn // ' is not a file.'
  error stop 77
endif

call h5f%initialize(fn, ierr, status='old', action='r')

call h5f%shape(dname, dims, ierr)

print '(/,A,100I8)', 'Fortran dims: ',dims

call h5F%finalize(ierr)
if(ierr/=0) error stop 'finalize'

end program
