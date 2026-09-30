# v1.4.0 Release source snapshot

This directory tracks the project-authored source used by the v1.4.0 Release, excluding only the third-party `libzstd.dll` binary.

The original v1.4.0 source snapshot remains available in the split Base64 archive files.  
The 2026-09-30 legacy-format compatibility update is synced as:

```text
FGWin7_v1.4.0_2026-09-30_source.patch.gz.b64
```

This patch updates both downloader paths:

- `app/core.cs` — 05 standalone downloader;
- `app/ipc.cs` — 06 / FeverGames in-client downloadIPC patch.

It adds Legacy Index AES-CTR + GZip support and AES-decrypted Chunk auto-detection for Zstd / GZip. The change was verified by completing an Identity V download on Windows 7.

Reconstruction of the dated patch:

1. Base64-decode `FGWin7_v1.4.0_2026-09-30_source.patch.gz.b64`;
2. GZip-decompress it to obtain the unified source patch;
3. Apply it to the original v1.4.0 source snapshot.

Checksums:

```text
2026-09-30 source patch (decoded):
d31ff06a62ac7d2e718081d152d6aeb05736058dca5e862d03382876bb5b91de

2026-09-30 source patch (gzip+base64 file):
45a9bf3ca27d7c0bd5f40cfc41e99636942ca457220be291b1297001c60930bb

Updated v1.4.0 Release ZIP:
a235a628e3aee0d9c49201d9ac035519eb640f666f4bd46f5589a88653d8cdd4

libzstd.dll 1.5.6:
4d540a749823e5b8a6eb56deca5715150442d45f1e8863dd185fc31002b9b5d1
```

`libzstd.dll` is intentionally not committed to the source repository. Use the Release ZIP for normal use.
