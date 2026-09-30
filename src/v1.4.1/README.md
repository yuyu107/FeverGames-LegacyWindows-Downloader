# v1.4.1 source / reproducible release

v1.4.1 is a compatibility patch release built reproducibly from:

1. the original v1.4.0 Release ZIP (SHA-256 `3894648a653094c5b2083e049929877c4f9d287e9a85079461f4b4247a68e31a`);
2. `src/v1.4.0/FGWin7_v1.4.0_2026-09-30_source.patch.gz.b64`;
3. `tools/build_v1.4.1_release.py`.

The build updates both downloader paths (`app/core.cs` and `app/ipc.cs`), promotes the verified Legacy AES-CTR + GZip compatibility to v1.4.1, updates package-visible version strings, and preserves the Windows 7-compatible ZIP path encoding.

The third-party `libzstd.dll` binary remains distributed only in the Release ZIP.
