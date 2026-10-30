"""Unmodified OpenMVS command-line tools, AGPL-3.0, installed only for local PC use."""
import hashlib
import json
from pathlib import Path
import urllib.request
import zipfile

ROOT=Path(__file__).resolve().parents[1]/'.scan-runtime/openmvs'
SOURCE='https://github.com/cdcseacave/openMVS/tree/v2.4.0'
DOWNLOAD='https://github.com/cdcseacave/openMVS/releases/download/v2.4.0/OpenMVS_Windows_x64.zip'
ARCHIVE_SHA256='0c31660c15c9ebc4c106873cf67564d9570d404aef7a6403451da1b6178b2167'


def setup():
    ROOT.mkdir(exist_ok=True)
    archive=ROOT/'release.zip'
    if not archive.is_file() or hashlib.sha256(archive.read_bytes()).hexdigest()!=ARCHIVE_SHA256:
        partial=archive.with_suffix('.download')
        urllib.request.urlretrieve(DOWNLOAD,partial)
        if hashlib.sha256(partial.read_bytes()).hexdigest()!=ARCHIVE_SHA256:
            raise RuntimeError('Incomplete OpenMVS download')
        partial.replace(archive)
    with zipfile.ZipFile(archive) as package:
        for member in package.infolist():
            name=member.filename
            if name.startswith('vc17/x64/Release/') and name.endswith(('.exe','.dll')):
                if '..' in name or '\\' in name:
                    raise RuntimeError('Invalid archive path')
                package.extract(member,ROOT)
    license_path=ROOT/'LICENSE'
    if not license_path.is_file():
        urllib.request.urlretrieve('https://raw.githubusercontent.com/cdcseacave/openMVS/v2.4.0/LICENSE',license_path)
    (ROOT/'upstream.json').write_text(json.dumps({
        'name':'OpenMVS','version':'2.4.0','author':'SEACAVE','license':'AGPL-3.0',
        'source':SOURCE,'download':DOWNLOAD,'modified':False,
        'archiveSha256':hashlib.sha256(archive.read_bytes()).hexdigest(),
        'notice':'Copyright SEACAVE. No warranty. License retained in LICENSE; corresponding source at source URL.'
    },indent=2))
    print('OpenMVS 2.4.0 ready. Copyright SEACAVE; AGPL-3.0. Source: '+SOURCE)


if __name__=='__main__':
    setup()
