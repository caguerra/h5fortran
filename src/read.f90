submodule (h5fortran) read
!! This submodule is for reading HDF5 via submodules
use hdf5, only : h5dget_create_plist_f, &
  h5pget_layout_f, h5pget_chunk_f, H5D_CONTIGUOUS_F, H5D_CHUNKED_F
use H5LT, only : h5ltpath_valid_f

implicit none

contains


module procedure hdf_get_shape
!! must get dims before info, as "dims" must be allocated or segfault occurs.
integer(SIZE_T) :: dsize
integer :: dtype, drank, ier

ier = 0

if (.not.self%exist(dname)) then
  write(stderr, *) 'ERROR:get_shape: ' // dname // ' does not exist in ' // self%filename
  ier = -1
endif

if (ier == 0) call h5ltget_dataset_ndims_f(self%lid, dname, drank, ier)

if (ier == 0) then
  allocate(dims(drank))
  call h5ltget_dataset_info_f(self%lid, dname, dims, dtype, dsize, ier)
endif

if (present(ierr)) ierr = ier
if (ier /= 0) then
  if (present(ierr)) return
  error stop
endif

end procedure hdf_get_shape


module procedure hdf_get_chunk

integer :: ierr, drank
integer(HID_T) :: pid, did

chunk_size = -1
if (.not.self%exist(dname)) then
  write(stderr, *) 'ERROR:get_chunk: ' // dname // ' does not exist in ' // self%filename
  ierr = -1
  return
endif

if(.not.self%is_chunked(dname)) return

call h5ltget_dataset_ndims_f(self%lid, dname, drank, ierr)
if (check(ierr, 'ERROR:get_chunk: get rank ' // dname // ' ' // self%filename)) return
call h5dopen_f(self%lid, dname, did, ierr)
if (check(ierr, 'ERROR:get_chunk: open dataset ' // dname // ' ' // self%filename)) return
call h5dget_create_plist_f(did, pid, ierr)
if (check(ierr, 'ERROR:get_chunk: get property list ID ' // dname // ' ' // self%filename)) return

call h5pget_chunk_f(pid, drank, chunk_size, ierr)
if (ierr /= drank) then
  write(stderr,*) 'ERROR:get_chunk read ' // dname // ' ' // self%filename
  return
endif

call h5dclose_f(did, ierr)
if (check(ierr, 'ERROR:get_chunk: close dataset: ' // dname // ' ' // self%filename)) return


end procedure hdf_get_chunk


module procedure hdf_get_layout

integer(HID_T) :: pid, did
integer :: ierr

layout = -1

if (.not.self%exist(dname)) then
  write(stderr, *) 'ERROR:get_layout: ' // dname // ' does not exist in ' // self%filename
  return
endif

call h5dopen_f(self%lid, dname, did, ierr)
if (check(ierr, 'ERROR:get_layout: open dataset ' // dname // ' ' // self%filename)) return
call h5dget_create_plist_f(did, pid, ierr)
if (check(ierr, 'ERROR:get_layout: get property list ID ' // dname // ' ' // self%filename)) return
call h5pget_layout_f(pid, layout, ierr)
if (check(ierr, 'ERROR:get_layout read ' // dname //' ' // self%filename)) return
call h5dclose_f(did, ierr)
if (check(ierr, 'ERROR:get_layout: close dataset: ' // dname //' ' // self%filename)) return

end procedure hdf_get_layout


module procedure hdf_is_contig
hdf_is_contig = self%layout(dname) == H5D_CONTIGUOUS_F
end procedure hdf_is_contig

module procedure hdf_is_chunked
hdf_is_chunked = self%layout(dname) == H5D_CHUNKED_F
end procedure hdf_is_chunked


module procedure hdf_check_exist

integer :: ierr

if (self%lid == 0) then
  write(stderr,*) 'ERROR: must initialize file before checking existance of variable'
  exists = .false.
  return
endif

call h5ltpath_valid_f(self%lid, &
  path=dname, &
  check_object_valid=.true., &
  path_valid=exists, &
  errcode=ierr)

if (ierr/=0) then
  write(stderr,*) 'ERROR: could not determine status of ' // dname // ' in ' // self%filename
  return
endif

end procedure hdf_check_exist

end submodule read
