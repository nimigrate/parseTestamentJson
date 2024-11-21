
##[ copied from nimpylib/pylib: src/pylib/Lib/os_impl/posix_like/truncate.nim
   simplified to make code shorter
   ]##

#import ../common

#import ./open_close
#import std/os

when defined(js):
  {.error: "not necessary to impl for JS".}
else:
  when defined(windows):
    # errno_t _chsize_s(int _FileHandle, __int64 _Size);
    proc chsize_s(fd: cint, size: int64): cint{.importc:"_chsize_s", header:"<io.h>".}
  else:
    import std/posix

  template ftruncateImpl(file: Positive, length: int64): cint =
    when defined(windows):
      chsize_s(file.cint, length)
    else:
      posix.ftruncate(file.cint, length.Off)

  proc strerror(err: cint): cstring{.importc, header: "<string.h>".}
  proc ftruncate*(file: Positive, length: int64) =
      let err = ftruncateImpl(file, length)
      if err != 0:
        let errMsg = $strerror(err)
        var exc = newException(OSError, errMsg)
        raise exc

  # proc truncate*(file: CanIOOpenT, length: Natural) =
  #   when file is int:
  #     ftruncate file, length
  #   else:
  #     let fd = open(file, os.O_WDONLY)
  #     let err = ftruncateImpl(fd, length)
  #     if 0 != err:
  #       file.raiseErrnoWithPath err
  #     close(fd)
  #
