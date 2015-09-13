FILES=delete-old-data lib/App/DeleteOldData.pm

all: test

test: tidy critic

tidy:
	perltidy --profile=.perltidyrc ${FILES}
	git diff

critic:
	perlcritic ${FILES}

.PHONY: tidy critic test
