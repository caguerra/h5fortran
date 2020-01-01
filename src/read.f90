!! This submodule is for reading HDF5, via child submodules
submodule (hdf5_interface) read

use H5LT, only: h5ltget_dataset_info_f, h5ltread_dataset_f, h5ltget_dataset_ndims_f, &
    h5dopen_f, h5dread_f, h5dclose_f, h5ltread_dataset_string_f, h5ltpath_valid_f

implicit none

contains


module procedure hdf_setup_read

! module subroutine hdf_setup_read(self, dname, dims, ierr)
!   class(hdf5_file), intent(in) :: self
!   character(*), intent(in) :: dname
!   integer(HSIZE_T), intent(out) :: dims(:)
!   integer, intent(out) :: ierr
integer(SIZE_T) :: dsize
integer :: dtype
logical :: exists

call h5ltpath_valid_f(self%lid, dname, .true., exists, ierr)
if (.not.exists .or. ierr /= 0) then
  write(stderr,*) 'ERROR: ' // dname // ' does not exist in ' // self%filename
  ierr = -1
  return
endif

call h5ltget_dataset_info_f(self%lid, dname, dims, dtype, dsize, ierr)
if (ierr /= 0) write(stderr,*) 'ERROR: open ' // dname // ' read ' // self%filename

end procedure hdf_setup_read


module procedure hdf_get_shape
!! must get dims before info, as "dims" must be allocated or segfault occurs.
integer(SIZE_T) :: dsize
integer :: dtype, drank
logical :: exists

call h5ltpath_valid_f(self%lid, dname, .true., exists, ierr)
if (.not.exists .or. ierr /= 0) then
  write(stderr,*) 'ERROR: ' // dname // ' does not exist in ' // self%filename
  ierr = -1
  return
endif

call h5ltget_dataset_ndims_f(self%lid, dname, drank, ierr)
if (ierr /= 0) then
  write(stderr,*) 'ERROR: '// dname // ' rank ' // self%filename
  return
endif

allocate(dims(drank))
call h5ltget_dataset_info_f(self%lid, dname, dims, dtype, dsize, ierr)
if (ierr /= 0) write(stderr,*) 'ERROR: ' // dname // ' info ' // self%filename

end procedure hdf_get_shape


end submodule read
