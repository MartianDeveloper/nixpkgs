{ lib
, runCommand
, ln-boot
, mes
, mes-libc
}:
let
  pname = "mes-libc";
  inherit (mes) version;

  sources = (import ./sources.nix).x86.linux.gcc;
  inherit (sources) libtcc1_SOURCES libc_gnu_SOURCES;

  prefix = "${mes}/share/mes-${version}";

  # Concatenate all source files into a convenient bundle
  # "gcc" variants of source files (eg. "lib/linux/x86-mes-gcc") can also be
  # compiled by tinycc
  #
  # Passing this many arguments is too much for kaem so we need to split
  # the operation in two
  firstLibc = lib.take 100 libc_gnu_SOURCES;
  lastLibc = lib.drop 100 libc_gnu_SOURCES;
in runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [ ln-boot ];

  passthru.CFLAGS = "-DHAVE_CONFIG_H=1 -I${mes-libc}/include -I${mes-libc}/include/linux/x86";

  meta = with lib; {
    description = "The Mes C Library";
    homepage = "https://www.gnu.org/software/mes";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ emilytrau ];
    platforms = [ "i686-linux" ];
  };
} ''
  cd ${prefix}

  # mescc compiled libc.a
  mkdir -p ''${out}/lib/x86-mes
  cp lib/x86-mes/libc.a ''${out}/lib/x86-mes

  # libc.c
  catm ''${TMPDIR}/first.c ${lib.concatStringsSep " " firstLibc}
  catm ''${out}/lib/libc.c ''${TMPDIR}/first.c ${lib.concatStringsSep " " lastLibc}

  # crt{1,n,i}.c
  cp lib/linux/x86-mes-gcc/crt1.c ''${out}/lib
  cp lib/linux/x86-mes-gcc/crtn.c ''${out}/lib
  cp lib/linux/x86-mes-gcc/crti.c ''${out}/lib

  # libtcc1.c
  catm ''${out}/lib/libtcc1.c ${lib.concatStringsSep " " libtcc1_SOURCES}

  # getopt.c
  cp lib/posix/getopt.c ''${out}/lib/libgetopt.c

  # Install headers
  ln -s ${prefix}/include ''${out}/include
''
