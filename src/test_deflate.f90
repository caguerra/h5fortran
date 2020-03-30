program test_deflate
!! unit tests and registration tests of HDF5 deflate compression write
use, intrinsic:: iso_fortran_env, only: int32, real32, real64, stderr=>error_unit
use, intrinsic:: iso_c_binding, only: c_null_char
use h5fortran, only: hdf5_file, toLower, strip_trailing_null, truncate_string_null
use hdf5, only: H5D_CHUNKED_F, H5D_CONTIGUOUS_F, hsize_t

implicit none

character(:), allocatable :: path
character(256) :: argv
integer :: i,l

call get_command_argument(1, argv, length=l, status=i)
if (i /= 0 .or. l == 0) then
  write(stderr,*) 'please specify test directory e.g. /tmp'
  error stop 77
endif
path = trim(argv)
print *, 'test path: ', path

call test_hdf5_deflate(path)
print *,'PASSED: HDF5 compression'

contains

subroutine test_hdf5_deflate(path)
type(hdf5_file) :: h5f
character(*), intent(in) :: path
integer(hsize_t), parameter :: N=1000
integer(hsize_t) :: crat, chunks(3)
integer ::  fsize, layout

integer :: ibig2(N,N) = 0, ibig3(N,N,4) = 0
real(real32) :: big2(N,N) = 0., big3(N,N,4) = 0.
character(:), allocatable :: fn

fn = path // '/deflate1.h5'
call h5f%initialize(fn, status='new', action='rw', comp_lvl=1, debug=.true.)
call h5f%write('/big2', big2, chunk_size=[100,100])
call h5f%write('/small_contig', big2(:5,:5))
call h5f%finalize()

inquire(file=fn, size=fsize)
crat = (N*N*storage_size(big2)/8) / fsize
print '(A,F6.2,A,I6)','filesize (Mbytes): ',fsize/1e6, '   2D compression ratio:',crat
if (h5f%comp_lvl > 0 .and. crat < 10) error stop '2D low compression'

call h5f%initialize(fn, status='old', action='r', debug=.false.)

layout = h5f%layout('/big2')
if(layout /= H5D_CHUNKED_F) error stop '#1 not chunked layout'
if(.not.h5f%is_chunked('/big2')) error stop '#1 not chunked layout'
call h5f%chunks('/big2', chunks(:2))
if(any(chunks(:2) /= [100, 100])) error stop '#1 get_chunk mismatch'

layout = h5f%layout('/small_contig')
if(layout /= H5D_CONTIGUOUS_F) error stop '#1 not contiguous layout'
if(.not.h5f%is_contig('/small_contig')) error stop '#1 not contig layout'
call h5f%chunks('/small_contig', chunks(:2))
if(any(chunks(:2) /= -1)) error stop '#1 get_chunk mismatch'

call h5f%finalize()

!======================================
fn = path // '/deflate2.h5'
call h5f%initialize(fn, status='new',action='rw',comp_lvl=1, debug=.true.)
call h5f%write('/big3', big3, chunk_size=[100,100,1])

call h5f%write('/big3_autochunk', big3)
call h5f%chunks('/big3_autochunk', chunks)
if(any(chunks /= [63,125,1])) error stop '#3 auto chunk unexpected chunk size'

call h5f%finalize()

inquire(file=fn, size=fsize)
crat = (2*N*N*storage_size(big3)/8) / fsize

print '(A,F6.2,A,I6)','#2 filesize (Mbytes): ',fsize/1e6, '   3D compression ratio:',crat

if (h5f%comp_lvl > 0 .and. crat < 10) error stop '#2 3D low compression'
!======================================
fn = path // '/deflate3.h5'
call h5f%initialize(fn, status='new',action='rw',comp_lvl=1, debug=.true.)

call h5f%write('/ibig3', ibig3(:N-10,:N-20,:))
call h5f%chunks('/ibig3', chunks)
if(any(chunks /= [62,123,1])) error stop '#3 auto chunk unexpected chunk size'

call h5f%finalize()

inquire(file=fn, size=fsize)
crat = (N*N*storage_size(ibig3)/8) / fsize

print '(A,F6.2,A,I6)','#3 filesize (Mbytes): ',fsize/1e6, '   3D compression ratio:',crat

if (h5f%comp_lvl > 0 .and. crat < 10) error stop '#3 3D low compression'
!======================================
fn = path // '/deflate4.h5'
call h5f%initialize(fn, status='new',action='rw',comp_lvl=1, debug=.true.)
call h5f%write('/ibig2', ibig2, chunk_size=[100,100])
call h5f%finalize()

inquire(file=fn, size=fsize)
crat = (N*N*storage_size(ibig2)/8) / fsize

print '(A,F6.2,A,I6)','#4 filesize (Mbytes): ',fsize/1e6, '   3D compression ratio:',crat

if (h5f%comp_lvl > 0 .and. crat < 10) error stop '#4 3D low compression'

end subroutine test_hdf5_deflate

end program