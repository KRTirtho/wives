INNO_VERSION=6.2.0
TEMP_DIR=/tmp/wives-tar
BUNDLE_DIR=build/linux/x64/release/bundle

init:
			echo "This contains only some CI helper scripts. Read the CONTRIBUTION.md for guidance on how to build Wives :)"

innoinstall:
						powershell curl -o build\installer.exe http://files.jrsoftware.org/is/6/innosetup-${INNO_VERSION}.exe
						powershell build\installer.exe /verysilent /allusers /dir=build\iscc
						
tar:
		mkdir -p $(TEMP_DIR)\
		&& cp -r $(BUNDLE_DIR)/* $(TEMP_DIR)\
		&& cp linux/wives.desktop $(TEMP_DIR)\
		&& cp assets/logo.png $(TEMP_DIR)\
		&& tar -cJf build/wives-linux-${VERSION}-x86_64.tar.xz -C $(TEMP_DIR) .\
		&& rm -rf $(TEMP_DIR)


publishaur: 
					 echo '[Warning!]: you need SSH paired with AUR'\
					 && rm -rf build/wives\
					 && git clone ssh://aur@aur.archlinux.org/wives-bin.git build/wives\
					 && cp linux/publishing/PKGBUILD linux/publishing/.SRCINFO build/wives\
					 && cd build/wives\
					 && git add .\
					 && git commit -m "${MSG}"\
					 && git push