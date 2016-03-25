.PHONY: test

test:
	shellcheck -f checkstyle bin/*.sh > checkstyle.out || true

