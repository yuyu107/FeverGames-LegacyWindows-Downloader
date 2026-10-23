#!/usr/bin/env python3
"""Build stable v1.4.2 from verified official v1.4.1 release.
No GamePicker changes enter this release. 05 remains the base App ID picker, default 81.
"""
import base64, gzip, hashlib, io, os, pathlib, re, struct, urllib.request, zipfile, zlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
URL="https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/download/v1.4.1/FGWin7_v1.4.1.zip"
EXPECTED="d17005249560c15ede1b99beb463914db03df0c0e8756e31bb500555f14dc16c"
def digest(b): return hashlib.sha256(b).hexdigest()
def unpack_name(info):
    for off in range(0,len(info.extra)-4):
        try:
            t,ln=struct.unpack_from('<HH',info.extra,off)
            if t==0x7075 and ln>=5: return info.extra[off+9:off+4+ln].decode('utf-8')
        except Exception: pass
    return info.filename
def unicode_extra(raw,uni):
    p=b'\x01'+struct.pack('<I',zlib.crc32(raw)&0xffffffff)+uni.encode('utf8')
    return struct.pack('<HH',0x7075,len(p))+p
def escape_unicode(s):
    o=[]
    for c in s:
        n=ord(c)
        if n<128:o.append(c)
        elif n<=65535:o.append('#U%04x'%n)
        else:
            n-=65536
            o.extend(['#U%04x'%(0xD800+(n>>10)),'#U%04x'%(0xDC00+(n&1023))])
    return ''.join(o)
def trans_text(payload,pairs):
    bom=payload.startswith(b'\xef\xbb\xbf')
    s=payload.decode('utf-8-sig')
    for a,b in pairs:
        if a not in s: raise ValueError('Version marker not found: '+a)
        s=s.replace(a,b)
    return (b'\xef\xbb\xbf' if bom else b'')+s.encode('utf8')
def main():
    if os.environ.get('OLD_ZIP'):
        old=pathlib.Path(os.environ['OLD_ZIP']).read_bytes()
    else:
        old=urllib.request.urlopen(URL,timeout=120).read()
    if digest(old)!=EXPECTED: raise RuntimeError('v1.4.1 release checksum mismatch')
    files={}
    with zipfile.ZipFile(io.BytesIO(old)) as z:
        for info in z.infolist():
            name=unpack_name(info)
            if name.endswith('/'):continue
            rel=name.split('/',1)[1] if '/' in name else name
            if not rel:continue
            files[rel]=z.read(info)
    original=files['app/main.ps1'].decode('utf-8-sig')
    if 'GamePicker' in original or 'Select-GameFromList' in original:raise RuntimeError('Not the base standalone UI')
    if '请输入 App ID【直接回车默认 81 = 我的世界基岩互通版】' not in original: raise RuntimeError('App ID 81 default missing')
    if 'index_url' not in files['app/core.cs'].decode('utf-8-sig'):raise RuntimeError('Legacy Index support missing')
    if 'GZip' not in files['app/ipc.cs'].decode('utf-8-sig'):raise RuntimeError('Legacy chunk support missing')
    scanner='patch/FeverGames_AutoProfileScanner_v1.3.cs'
    v2=ROOT/'src/v1.4.2/autoprofile_v2.patch.gz.b64'
    patch=gzip.decompress(base64.b64decode(''.join(v2.read_text().split()))).decode('utf8')
    import subprocess,tempfile
    with tempfile.TemporaryDirectory() as t:
        w=pathlib.Path(t)
        (w/'patch').mkdir()
        (w/scanner).write_bytes(files[scanner])
        run=subprocess.run(['patch','-p1','--forward'],cwd=w,input=patch.encode(),capture_output=True)
        if run.returncode: raise RuntimeError('Auto Profile v2 patch failed:\n'+run.stdout.decode()+run.stderr.decode())
        files[scanner]=(w/scanner).read_bytes()
    # Integrate same strict SHA-locked Exact Profile proven with 1.18.45.8.
    profiles='patch/FeverGames_PatchProfiles_v1.3.ps1'
    p=files[profiles].decode('utf-8-sig')
    if '1.18.45.8-A' in p: raise RuntimeError('Profile already exists')
    block=r'''
# v1.4.2 | FeverGames 1.18.45.8 / layout A. Runtime download tested.
# Require both exact original SHA and 5/5 original bytes before modifying anything.
$FeverGamesPatchProfiles["1.18.45.8-A"] = @{
    Build = "1.18.45.8 / layout A"
    FolderBuild = "1.18.45.8"
    InstallerOriginalSha256 = "5fe909598061f12dac8225503854e4703c90cc457eae231fefabe47587866a65"
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xAD7520
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x71D6ED
            Original=[byte[]]@(0x0F,0x85,0xD6,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xD6,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA7A76C
            Original=[byte[]]@(0x48,0x8D,0x15,0x95,0xC9,0x4E,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0xB5,0xC9,0x4E,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA7A7E2
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA7BE30
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x95,0x84,0x29,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}
'''
    p=p.rstrip()+'\r\n\r\n'+block.replace('\n','\r\n')
    files[profiles]=(b'\xef\xbb\xbf' if files[profiles].startswith(b'\xef\xbb\xbf') else b'')+p.encode('utf8')
    installer='patch/Install_From_Zero_v1.3.ps1'
    s=files[installer].decode('utf-8-sig')
    anchor='function Profile-MatchesKnownLayout([string]$Path,$Profile) {'
    if s.count(anchor)!=1:raise RuntimeError('Profile validator changed')
    sha_guard=r'''
    # Reject newer or repacked EXE, even when folder version is identical.
    if ([string]$Profile["FolderBuild"] -eq "1.18.45.8") {
        $expectedSha = [string]$Profile["InstallerOriginalSha256"]
        if ([String]::IsNullOrEmpty($expectedSha)) { return $false }
        if ((Get-Sha256 $Path) -ne $expectedSha) { return $false }
    }
'''
    s=s.replace(anchor,anchor+'\r\n'+sha_guard.replace('\n','\r\n'))
    autoguard=r'''
    # Fail closed if the file changed after Auto Profile scanner read it.
    if ([string]$profile["ProfileSource"] -eq "AUTO_STRUCTURE_V1") {
        [string]$expectedOriginalHash = [string]$profile["InstallerOriginalSha256"]
        if ([String]::IsNullOrEmpty($expectedOriginalHash) -or
            ((Get-Sha256 $installer) -ne $expectedOriginalHash)) {
            throw "Auto Profile source EXE changed after scanning. Refusing unsafe patch."
        }
    }
'''
    for a in ['$profile = Resolve-PatchProfile $installer $folderBuild $compiler $scriptDir','    Copy-Item $patchedInstaller $installer -Force']:
        if s.count(a)!=1:raise RuntimeError('Installer scanner/write anchor not unique')
        s=s.replace(a,a+'\r\n'+autoguard.replace('\n','\r\n') if a.startswith('$profile') else autoguard.replace('\n','\r\n')+'\r\n'+a)
    s=s.replace('Version: 1.4.1','Version: 1.4.2').replace('v1.4.1','v1.4.2').replace('1.4.1','1.4.2')
    files[installer]=(b'\xef\xbb\xbf' if files[installer].startswith(b'\xef\xbb\xbf') else b'')+s.encode('utf8')
    for key,b in list(files.items()):
        if key==installer:continue
        if key.endswith(('.ps1','.cs','.txt')) and key not in (scanner,profiles):
            bom=b.startswith(b'\xef\xbb\xbf')
            try:t=b.decode('utf-8-sig')
            except UnicodeDecodeError:continue
            t=t.replace('1.4.1','1.4.2')
            files[key]=(b'\xef\xbb\xbf' if bom else b'')+t.encode('utf8')
    # Keep basic App ID selector and force safe default on Enter.
    m=files['app/main.ps1'].decode('utf-8-sig')
    assert 'GamePicker' not in m and 'if ([String]::IsNullOrEmpty($appId)) { $appId = "81" }' in m
    files['RELEASE_NOTES_v1.4.2_CN.txt']=('FGWin7 v1.4.2 正式版\r\n\r\n'
      '1. 独立下载器恢复基础 App ID 输入；直接回车默认 App ID 81（我的世界基岩互通版）。\r\n'
      '2. 支持 FeverGames 1.18.45.8，保留五处原始字节和 SHA-256 安全校验。\r\n'
      '3. 正式合入 Auto Profile v2；支持有限对象字段偏移变化，候选必须唯一。\r\n'
      '4. 保留 v1.4.1 的第五人格 Legacy AES-CTR+GZip 下载兼容及所有下载、更新、修复功能。\r\n'
      '5. 在线游戏列表/搜索/历史记录等 GamePicker 实验功能不随本版本发布。\r\n'
      '注意：未知后续版本仍可能无法识别，此时会安全拒绝修改。\r\n').encode('utf-8-sig')
    files.pop('RELEASE_NOTES_v1.4.1_CN.txt',None)
    out=pathlib.Path(os.environ.get('OUT_DIR','dist'));out.mkdir(parents=True,exist_ok=True)
    fn=out/'FGWin7_v1.4.2.zip'
    with zipfile.ZipFile(fn,'w',compression=zipfile.ZIP_STORED,allowZip64=True) as z:
        names=['FGWin7_142/']+['FGWin7_142/'+x for x in files]
        for name in names:
            raw=escape_unicode(name)
            info=zipfile.ZipInfo(raw,(2026,10,23,20,0,0))
            info.create_system=0;info.compress_type=zipfile.ZIP_STORED
            info.extra=unicode_extra(raw.encode('ascii'),name)
            z.writestr(info,b'' if name.endswith('/') else files[name[len('FGWin7_142/'):]])
    with zipfile.ZipFile(fn) as z:
        if z.testzip():raise RuntimeError('ZIP damaged')
    hash=digest(fn.read_bytes())
    (out/'FGWin7_v1.4.2.sha256.txt').write_text(hash+'  FGWin7_v1.4.2.zip\n')
    print('OK',hash,fn.stat().st_size)
if __name__=='__main__':main()
