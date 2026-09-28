# downloader sources

The repository does not commit precompiled downloader executables or the third-party `libzstd.dll` binary.

The historical v1.2 managed downloader source remains under `src/downloadIPC_Win7_v1.2.cs.gz.b64`.

For v1.4.0, the exact project-authored Release source snapshot is stored under:

```text
src/v1.4.0/
```

The snapshot is an `xz`-compressed tar archive encoded as Base64 and split into five numbered text parts. Concatenate the five files in numeric order, Base64-decode them, then decompress/extract the resulting `tar.xz`.

The archive excludes only the third-party `libzstd.dll` binary. Normal users should use the GitHub Release ZIP, which includes the verified Zstandard 1.5.6 x64 DLL.
