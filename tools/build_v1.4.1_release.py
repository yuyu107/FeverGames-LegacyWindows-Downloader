#!/usr/bin/env python3
from pathlib import Path
import base64, gzip, hashlib, os, shutil, struct, subprocess, tempfile, urllib.request, zipfile, zlib

ROOT = Path(__file__).resolve().parents[1] if 'tools' in Path(__file__).parts else Path.cwd()
OLD_URL = 'https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/download/v1.4.0/FGWin7_v1.4.0.zip'
OLD_SHA = '3894648a653094c5b2083e049929877c4f9d287e9a85079461f4b4247a68e31a'
PATCH_REL = Path('src/v1.4.0/FGWin7_v1.4.0_2026-09-30_source.patch.gz.b64')
OUT_NAME = 'FGWin7_v1.4.1.zip'
OUT_SHA_NAME = 'FGWin7_v1.4.1.sha256.txt'
FIXED_DT = (2026, 9, 30, 10, 6, 0)

def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

def escape_unicode(s):
    out = []
    for ch in s:
        o = ord(ch)
        if o < 128:
            out.append(ch)
        elif o <= 0xffff:
            out.append(f'#U{o:04x}')
        else:
            cp = o - 0x10000
            out.append(f'#U{0xD800+(cp>>10):04x}#U{0xDC00+(cp&0x3ff):04x}')
    return ''.join(out)

def unicode_extra(raw_name_ascii, unicode_name):
    payload = b'\x01' + struct.pack('<I', zlib.crc32(raw_name_ascii) & 0xffffffff) + unicode_name.encode('utf-8')
    return struct.pack('<HH', 0x7075, len(payload)) + payload

def read_text(path):
    b = path.read_bytes()
    bom = b.startswith(b'\xef\xbb\xbf')
    return b.decode('utf-8-sig'), bom

def write_text(path, s, bom=False):
    path.write_bytes((b'\xef\xbb\xbf' if bom else b'') + s.encode('utf-8'))

def bump_tree(root):
    repls = {
        'app/run.ps1': [('独立下载核心 v1.4.0', '独立下载核心 v1.4.1')],
        'app/main.ps1': [('v1.4.0', 'v1.4.1')],
        'app/patch_ipc.ps1': [('v1.4.0', 'v1.4.1')],
        'app/core.cs': [('Standalone Downloader core / v1.4.0', 'Standalone Downloader core / v1.4.1')],
        'app/ipc.cs': [('FGWin7 downloadIPC / v1.4.0', 'FGWin7 downloadIPC / v1.4.1')],
        'patch/Install_Latest_FeverGames_v1.3.ps1': [('Legacy Windows Downloader v1.4.0', 'Legacy Windows Downloader v1.4.1')],
        'patch/Install_From_Zero_v1.3.ps1': [
            ('$PackageVersion = "1.4.0"', '$PackageVersion = "1.4.1"'),
            ('v1.4.0 requires libzstd.dll', 'v1.4.1 requires libzstd.dll'),
            ('the v1.4.0 package', 'the v1.4.1 package'),
            ('# Full-patch backup used by v1.3.x / v1.4.0.', '# Full-patch backup used by v1.3.x / v1.4.x.'),
        ],
        'patch/THIRD_PARTY_NOTICES.txt': [('This v1.4.0 package', 'This v1.4.1 package')],
        'patch/Check_Status_v1.3.ps1': [('Legacy Windows Downloader v1.4.0 - Status', 'Legacy Windows Downloader v1.4.1 - Status')],
        'patch/Collect_Diagnostics_v1.3.ps1': [('FeverGames_v1.4.0_Diagnostic_Result', 'FeverGames_v1.4.1_Diagnostic_Result')],
    }
    for rel, pairs in repls.items():
        p = root / rel
        s, bom = read_text(p)
        for a, b in pairs:
            s = s.replace(a, b)
        write_text(p, s, bom)

    p = root / 'README_CN.txt'
    s, bom = read_text(p)
    s = s.replace('FGWin7 v1.4.0', 'FGWin7 v1.4.1', 1)
    s = s.replace('同时安装 v1.4.0 的 Win7 downloadIPC', '同时安装 v1.4.1 的 Win7 downloadIPC')
    s = s.replace('v1.4.0 新增的独立游戏下载安装入口。', 'v1.4.0 起提供的独立游戏下载安装入口。')
    s = s.replace('v1.4.0 新增功能放在 05 / 06', 'v1.4.0 起新增功能放在 05 / 06')
    intro = """
【v1.4.1 更新】
- 将已验证的旧版文件分发兼容正式并入稳定版。
- Legacy Index 支持 index_url / AES-CTR + GZip。
- Chunk 在 AES-CTR 解密后自动识别 Zstd / GZip。
- 05 独立下载器与 06 / FeverGames 平台内 downloadIPC 两条链均已同步。
- 已完成《第五人格》完整下载实机验证。
"""
    anchor = '所有功能仍使用独立 CMD，不使用总菜单。'
    if intro.strip() not in s:
        replacement = anchor + (intro.replace('\n', '\r\n') if '\r\n' in s else intro)
        s = s.replace(anchor, replacement, 1)
    write_text(p, s, bom)

    version = """FeverGames Legacy Windows Downloader
Version: 1.4.1
Release status: Stable
Verified FeverGames frontend builds/layouts: 1.18.42.12 / layout A, 1.18.42.14 / layout A, 1.18.42.14 / layout B, 1.18.43.22 / layout A, 1.18.44.2 / layout A

v1.4.1:
- Promotes the verified legacy distribution compatibility fix to a stable patch release.
- Supports legacy index_url / AES-CTR + GZip Index decoding.
- Auto-detects Zstd / GZip after AES-CTR Chunk decryption instead of forcing all chunks through Zstd.
- Syncs the same compatibility path to the standalone downloader and the patched FeverGames downloadIPC.
- Verified by completing an Identity V download on Windows 7.
- Keeps all v1.4.0 standalone download/update/repair, downloadIPC-only patch and Index Tail Recovery features.
- Games using FeverGames Aria2/classic download paths must still use the platform native downloader.

Frontend patch framework inherited from v1.3.8:
- Known layouts prefer Built-in Exact Profiles.
- Unknown / changed layouts use Auto Profile only when all 5 structural targets verify.
- Any ambiguous or failed detection stops safely instead of reusing old offsets.
"""
    write_text(root / 'patch/VERSION.txt', version, False)

    notes = """FGWin7 v1.4.1 正式版

v1.4.1 是 v1.4.0 的兼容性修复版本，重点解决部分旧资源“索引能够完成，但实际 Chunk 下载中途失败”的问题。

主要更新：

1. 旧版 Index 兼容
   - 支持旧版 Manifest 中的 index_url / pb_size；
   - 支持 AES-CTR + GZip Index 解码；
   - 保留新版 index_url_v2 / AES-CTR + Zstd 路径。

2. 旧版 Chunk 兼容
   - AES-CTR 解密后自动识别 Zstd / GZip；
   - 不再把所有数据块强制按 Zstd 解码；
   - 未知格式仍保留 first16 诊断信息，方便后续扩展兼容。

3. 两条下载链同步
   - 05_独立下载_检查更新与修复.cmd 使用的 core.cs 已同步；
   - 06_仅修补downloadIPC.cmd / FeverGames 平台内任务使用的 ipc.cs 已同步。

4. 实机验证
   - 《第五人格》此前会在 439/439 Index 全部完成后，于 Chunk 阶段中途停止；
   - 合入 AES-CTR + GZip Chunk 兼容后已成功完整下载。

5. 继续保留 v1.4.0 功能
   - 独立下载、最新版解析、更新检查、增量更新、校验/修复；
   - downloadIPC-only 修补；
   - Index Tail Recovery；
   - Built-in Exact Profile + Auto Profile 5/5 前端验证；
   - libzstd.dll 1.5.6。

已知限制：
- 05 独立下载器仍不处理 FeverGames 的 Aria2 / 经典下载链；这类游戏请使用平台原生下载。
- 本项目解决的是 FeverGames 下载流程兼容，不保证下载后的每个游戏本体都能在 Windows 7 上运行。
"""
    old = root / 'RELEASE_NOTES_v1.4.0_CN.txt'
    if old.exists():
        old.unlink()
    write_text(root / 'RELEASE_NOTES_v1.4.1_CN.txt', notes, True)

def build_zip(old_zip, tree_root, out_zip):
    with zipfile.ZipFile(old_zip, 'r') as zin, zipfile.ZipFile(out_zip, 'w', allowZip64=True) as zout:
        for oldzi in zin.infolist():
            old_name = oldzi.filename
            new_name = old_name.replace('FGWin7_140/', 'FGWin7_141/', 1)
            if new_name.endswith('RELEASE_NOTES_v1.4.0_CN.txt'):
                new_name = new_name.replace('RELEASE_NOTES_v1.4.0_CN.txt', 'RELEASE_NOTES_v1.4.1_CN.txt')
            raw_name = escape_unicode(new_name).encode('ascii')
            rel = old_name[len('FGWin7_140/'):] if old_name.startswith('FGWin7_140/') else old_name
            if rel.endswith('RELEASE_NOTES_v1.4.0_CN.txt'):
                rel = 'RELEASE_NOTES_v1.4.1_CN.txt'
            content = b'' if old_name.endswith('/') else (tree_root / rel).read_bytes()
            zi = zipfile.ZipInfo(raw_name.decode('ascii'), date_time=FIXED_DT)
            zi.compress_type = zipfile.ZIP_STORED
            zi.create_system = 0
            zi.extract_version = 20
            zi.create_version = 20
            zi.flag_bits = 0
            zi.external_attr = oldzi.external_attr
            zi.internal_attr = oldzi.internal_attr
            zi.extra = unicode_extra(raw_name, new_name)
            zout.writestr(zi, content)

def main():
    outdir = Path(os.environ.get('OUT_DIR', 'dist')).resolve()
    outdir.mkdir(parents=True, exist_ok=True)
    local_old = os.environ.get('OLD_ZIP')
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        oldzip = td / 'old.zip'
        if local_old:
            shutil.copy2(local_old, oldzip)
        else:
            urllib.request.urlretrieve(OLD_URL, oldzip)
        if sha256(oldzip) != OLD_SHA:
            raise SystemExit('Unexpected v1.4.0 release SHA-256')
        with zipfile.ZipFile(oldzip) as z:
            z.extractall(td / 'work')
        tree = td / 'work' / 'FGWin7_140'
        patch_b64 = (ROOT / PATCH_REL).read_text(encoding='ascii')
        patch = gzip.decompress(base64.b64decode(''.join(patch_b64.split())))
        pr = subprocess.run(['patch', '-p1', '--binary'], cwd=td / 'work', input=patch, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if pr.returncode:
            raise SystemExit(pr.stdout.decode('utf-8', 'replace'))
        bump_tree(tree)
        outzip = outdir / OUT_NAME
        build_zip(oldzip, tree, outzip)
        digest = sha256(outzip)
        (outdir / OUT_SHA_NAME).write_text(f'{digest}  {OUT_NAME}\n', encoding='ascii')
        print(digest)
        with zipfile.ZipFile(outzip) as z:
            if z.testzip():
                raise SystemExit('ZIP integrity check failed')

if __name__ == '__main__':
    main()
