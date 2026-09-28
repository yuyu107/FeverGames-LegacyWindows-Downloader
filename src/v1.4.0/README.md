# v1.4.0 Release source snapshot

This directory contains the exact project-authored source snapshot used for the v1.4.0 Release package, excluding only the third-party `libzstd.dll` binary.

Files:

```text
FGWin7_v1.4.0_source.tar.xz.b64.part01
FGWin7_v1.4.0_source.tar.xz.b64.part02
FGWin7_v1.4.0_source.tar.xz.b64.part03
FGWin7_v1.4.0_source.tar.xz.b64.part04
FGWin7_v1.4.0_source.tar.xz.b64.part05
```

Reconstruction:

1. Concatenate the five parts in numeric order with no added separators.
2. Base64-decode the result to `FGWin7_v1.4.0_source.tar.xz`.
3. Extract the xz-compressed tar archive.

Checksums:

```text
Concatenated Base64 SHA-256:
34301c78cd680214386878d1c0cd3553a32f4c4186773d2997d268030215865e

Decoded tar.xz SHA-256:
d2cb49d37ee6311341f9a51610348bae19e3c2c31a3efb6828220764e7317322

Final Release ZIP SHA-256:
3894648a653094c5b2083e049929877c4f9d287e9a85079461f4b4247a68e31a

libzstd.dll 1.5.6 SHA-256:
4d540a749823e5b8a6eb56deca5715150442d45f1e8863dd185fc31002b9b5d1
```

`libzstd.dll` is intentionally not committed to the source repository. Use the GitHub Release ZIP for normal use.
