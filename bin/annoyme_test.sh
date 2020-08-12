#!/usr/bin/env bash
set -euo pipefail
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly BOLD="$(tput bold)"
readonly END="$(tput sgr0)"

export annoyme

declare -a SUCCESSES
declare -a FAILURES

setup() {
    if which annoyme >/dev/null; then
        annoyme="annoyme"
    elif [[ -e "./annoyme" ]]; then
        annoyme="./annoyme"
    else
        echo "Couldn't find annoyme! Make sure it's on the path or in this directory!"
        exit 1
    fi
}

finish() {
    echo
    echo "${GREEN}Passed ${#SUCCESSES[@]}. ${RED}Failed ${#FAILURES[@]}.${END}"
    if (( "${#FAILURES[@]}" )); then
        echo "Tests failed:"
        for f in "${FAILURES[@]}"; do
            echo "$f"
        done
    else
        echo "All tests passed!"
    fi
}

pass() {
    printf .
    SUCCESSES+=("$1")
}

fail() {
    printf x
    FAILURES+=("$1")
}

t() {
    local -r test="$1"
    local -r msg="${2-}"
    if eval "$1"; then
        pass "$1"
    else
        if [[ "$2" != "" ]]; then
            fail "Test $1 failed: $2"
        else
            fail "Test $1 failed"
        fi
    fi
}


runtests() {
    t '[[ "$($annoyme 2>&1)" == *"No message to annoy you with"* ]]'
}

main() {
    setup
    runtests
    finish
}
main
