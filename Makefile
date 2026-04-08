.PHONY: all validate checksums gen-checksums test

all: validate

validate: scripts/validate-checksums.sh
	@bash scripts/validate-checksums.sh

checksums: gen-checksums

gen-checksums:
	@bash scripts/gen-checksums.sh

test:
	@echo "No tests configured"
