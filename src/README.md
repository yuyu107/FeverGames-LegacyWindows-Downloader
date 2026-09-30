# downloader sources

The repository does not commit precompiled downloader executables or the third-party `libzstd.dll` binary.

The historical v1.2 managed downloader source remains under `src/downloadIPC_Win7_v1.2.cs.gz.b64`.

For v1.4.0, the exact project-authored Release source snapshot is stored under:

```text
src/v1.4.0/
```

The snapshot is an `xz`-compressed tar archive encoded as Base64 and split into five numbered text parts. Concatenate the five files in numeric order, Base64-decode them, then decompress/extract the resulting `tar.xz`.

The archive excludes only the third-party `libzstd.dll` binary. Normal users should use the GitHub Release ZIP, which includes the verified Zstandard 1.5.6 x64 DLL.


## v1.4.1

v1.4.1 is a reproducible patch release built from the original v1.4.0 Release ZIP plus the verified 2026-09-30 source patch.

Build script:

```text
tools/build_v1.4.1_release.py
```

The builder verifies the original v1.4.0 SHA-256 before applying the source delta, updates all package-visible version strings to v1.4.1, preserves the Windows 7-compatible ZIP Unicode-path layout, and emits the v1.4.1 ZIP plus SHA-256 file.
