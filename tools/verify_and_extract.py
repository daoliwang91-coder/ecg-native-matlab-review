"""Check the fixed native/source payload before invoking genuine MATLAB.

No clinical calculations, random process or data modification are performed.
"""
from pathlib import Path, PurePosixPath
import hashlib
import json
import stat
import zipfile


def main():
    root = Path(__file__).resolve().parents[1]
    manifest = json.loads((root / 'payload_manifest.json').read_text())
    archive = root / manifest['archive_path']
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == manifest['archive_sha256']
    assert archive.stat().st_size == manifest['archive_bytes']
    destination = root / 'MATLAB_review'
    assert not destination.exists(), 'Prior extraction/output is retained'
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        assert len(z.infolist()) == len(manifest['files'])
        expected = {record['path'] for record in manifest['files']}
        assert set(z.namelist()) == expected
        for info in z.infolist():
            parts = PurePosixPath(info.filename)
            assert not parts.is_absolute() and '..' not in parts.parts
            assert not stat.S_ISLNK(info.external_attr >> 16)
        destination.mkdir()
        z.extractall(destination)
    for record in manifest['files']:
        p = destination / record['path']
        assert hashlib.sha256(p.read_bytes()).hexdigest() == record['sha256']
    state = {'native_and_source_files_verified': len(manifest['files']),
             'planned_ecgs': manifest['planned_ecgs'],
             'planned_attempts': manifest['planned_attempts'],
             'actual_matlab_executed': False, 'gate1_passed': False}
    (root / 'input_verification.json').write_text(json.dumps(state, indent=2) + '\n')
    print(json.dumps(state))


if __name__ == '__main__':
    main()
