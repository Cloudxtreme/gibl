.PHONY: test

test:
	shellcheck -f checkstyle *.sh > checkstyle.out || true

