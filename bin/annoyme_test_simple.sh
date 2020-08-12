#!/usr/bin/env bash
set -u

declare -a FAILURES=()


## parse_args
if [[ "$(annoyme -h 2>&1)" != *"usage:"*"A utility for annoying yourself"*"Flags:"* ]]; then
    FAILURES+=("Help should be printed when -h is passed.")
fi
if [[ "$(annoyme -every 99 -debug 2>&1)" != *"opt_interval: 99"* ]]; then
    FAILURES+=("opt_interval should be set by -every")
fi
if [[ "$(annoyme -msg 'test message here' -debug 2>&1)" != *"opt_message: test message here"* ]]; then
    FAILURES+=("opt_message should be set by -msg")
fi
if [[ "$(annoyme -hydrate -debug 2>&1)" != *"opt_message: Hydrate, fool!"* ]]; then
    FAILURES+=("opt_message should be set by -hydrate")
fi
out="$(annoyme -foo 2>&1)"
code=$?
if [[ "$out" != *"Unrecognized option: -foo"* ]]; then
    FAILURES+=("Unrecognized options should throw an error")
fi
if [[ "$code" == 0 ]]; then
    FAILURES+=("Unrecognized options should return nonzero exit code")
fi

## check_args
out="$(annoyme 2>&1)"
code=$?
if [[ "$out" != *"No message to annoy you with"* ]]; then
    FAILURES+=("message should be required but isn't")
fi
if [[ "$out" != *"usage"* ]]; then
    FAILURES+=("usage should be printed if no args are provided")
fi
if [[ "$code" == 0 ]]; then
    FAILURES+=("Missing message arg should produce an error.")
fi

out="$(annoyme -msg blah -every NAN 2>&1)"
code=$?
if [[ "$out" != *NAN*"is not an integer"* ]]; then
    FAILURES+=("non-integer arguments to -every should produce an error")
fi
if [[ "$code" == 0 ]]; then
    FAILURES+=("non-integer arguments to -every should produce a nonzero exit code")
fi

out="$(annoyme -msg blah -every 0 2>&1)"
code=$?
if [[ "$out" != *"Interval must be greater than 0"* ]]; then
    FAILURES+=("interval of 0 should produce an error")
fi
if [[ "$code" == 0 ]]; then
    FAILURES+=("interval of 0 should produce a nonzero exit code")
fi

## main
#out="$(annoyme -msg MESSAGE -every 999 2>&1)"
#code="$?"
#if [[ "$out" != *"Annoying you every 999 minutes with message: MESSAGE" ]]; then
#    :
#fi



if (( "${#FAILURES[@]}" )); then
    echo "${#FAILURES[@]} tests failed:"
    for f in "${FAILURES[@]}"; do
        echo "- $f"
    done
else
    echo "All tests pass"
fi
