submodule (h5fortran:write) writer
!! This submodule is for writing 0-D..7-D data
use hdf5, only: h5dwrite_f, H5T_STD_I64LE

implicit none (type, external)

contains


module procedure hdf_write_scalar

integer(HID_T)  :: sid, did
integer(HSIZE_T), allocatable :: dims(:)
integer :: ier

if(.not.self%is_open) error stop 'h5fortran:writer: file handle is not open'

allocate(dims(0))

did = 0
sid = 0
!! sentinel

select type (value)
type is (character(*))
  call h5ltmake_dataset_string_f(self%lid, dname, value, ier)
type is (real(real64))
  !! NOTE: 0d does not use chunk_size
  call hdf_create(self,dname, H5T_NATIVE_DOUBLE, dims,sid,did, compact=compact)
  call h5dwrite_f(did, H5T_NATIVE_DOUBLE, value, dims, ier)
type is (real(real32))
  call hdf_create(self,dname, H5T_NATIVE_REAL, dims,sid,did, compact=compact)
  call h5dwrite_f(did, H5T_NATIVE_REAL, value, dims, ier)
type is (integer(int32))
  call hdf_create(self,dname, H5T_NATIVE_INTEGER, dims,sid,did, compact=compact)
  call h5dwrite_f(did, H5T_NATIVE_INTEGER, value, dims, ier)
type is (integer(int64))
  call hdf_create(self,dname, H5T_STD_I64LE, dims,sid,did, compact=compact)
  call h5dwrite_f(did, H5T_STD_I64LE, value, dims, ier)
class default
  error stop 'h5fortran: invalid data type'
end select
if (ier/=0) then
  write(stderr,*) 'h5fortran:ERROR: could not write ',dname, ' to ', self%filename
  error stop
endif

call hdf_wrapup(did, sid, ier)

if (present(ierr)) ierr = ier
if (check(ier, self%filename, dname) .and. .not.present(ierr)) error stop

end procedure hdf_write_scalar


module procedure hdf_write_1d
@writer_template@
end procedure hdf_write_1d


module procedure hdf_write_2d
@writer_template@
end procedure hdf_write_2d


module procedure hdf_write_3d
@writer_template@
end procedure hdf_write_3d


module procedure hdf_write_4d
@writer_template@
end procedure hdf_write_4d


module procedure hdf_write_5d
@writer_template@
end procedure hdf_write_5d


module procedure hdf_write_6d
@writer_template@
end procedure hdf_write_6d


module procedure hdf_write_7d
@writer_template@
end procedure hdf_write_7d


end submodule writer
