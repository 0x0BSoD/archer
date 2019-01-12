archive:
	rsync -av --progress --exclude .git ah build/
	rsync -av --progress --exclude .git --exclude .gitkeep etc build/
	rsync -av --progress --exclude .git st build/
	rsync -av --progress  *.sh build/
	rsync -av --progress  *.txt build/
	rsync -av --progress  params build/
	rsync -av --progress  sda.sfdisk build/
	tar --exclude='.git' --exclude='.gitkeep' -czvf s.tar.gz build/*
archive_dev:
	rsync -av --progress conf build/
	rsync -av --progress  params build/
	rsync -av --progress  src build/
	rsync -av --progress  utils build/
	rsync -av --progress  skel build/
	rsync -av --progress  scripts build/
	rsync -av --progress  run.sh build/
	rsync -av --progress  *.txt build/
	rsync -av --progress  run.sh build/
	tar --exclude='.git' --exclude='.gitkeep' -czvf archer.tar.gz build/*