INNO_VERSION=6.2.0
TEMP_DIR=/tmp/wives-tar
BUNDLE_DIR=build/linux/x64/release/bundle

innoinstall:
						powershell curl -o build\installer.exe http://files.jrsoftware.org/is/6/innosetup-${INNO_VERSION}.exe
						powershell build\installer.exe /verysilent /allusers /dir=build\iscc
