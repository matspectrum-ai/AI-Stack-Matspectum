doctor:
    ./ai-stack doctor

check:
    bash -n ai-stack scripts/*.sh
    ./ai-stack profile list >/dev/null
    ./ai-stack toolchain list >/dev/null
    ./ai-stack bootstrap --help >/dev/null
    ./ai-stack init --help >/dev/null
    ./ai-stack detect --help >/dev/null
    ./ai-stack apply --help >/dev/null
    echo "AI Stack validation: PASS"

profiles:
    ./ai-stack profile list

toolchains:
    ./ai-stack toolchain list

detect path=".":
    ./ai-stack detect "{{path}}"
