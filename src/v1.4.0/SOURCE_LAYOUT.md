# Source layout

v1.4.0 keeps the original exact source snapshot and a dated source patch for the 2026-09-30 compatibility update.

Current legacy-format fix is stored as:

```text
FGWin7_v1.4.0_2026-09-30_source.patch.gz.b64
```

The patch updates `app/core.cs` and `app/ipc.cs` so both the standalone downloader and patched FeverGames downloadIPC share the verified AES-CTR + GZip compatibility logic.
