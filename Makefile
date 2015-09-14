FILES=delete-old-data lib/App/DeleteOldData.pm

all: precommit

precommit: tidy critic test

test:
	t/create_files.sh
	prove -lv t/*.t

tidy:
	perltidy --profile=.perltidyrc ${FILES}
	git diff

critic:
	perlcritic ${FILES}

.PHONY: tidy critic test
