#!/usr/bin/env bash

source test_cron.sh
source test_file_perms.sh
#source test_filesystems.sh
#source test_kernel.sh
#source test_network.sh
#source test_tcpwrappers.sh

declare -a TEST_FILES=()
declare -a INDIVIDUAL_TESTS=()

WAITFORIT_cmdname=${0##*/}

# helper methods


function usage()
{
    cat << USAGE >&2
Usage:
    $WAITFORIT_cmdname [run <test_name> | list | help]
    run                         Run test specified.
    list                        List all tests.
    help                        Print usage.

    Examples:
    # Runs all tests
    ./integration_tests.sh

    # Runs all tests contained within test_cron.sh
    ./integration_tests.sh run test_cron.sh

    # Run single test 'test_chmod_0600_cron_files'
    ./integration_tests.sh run test_cron.sh:test_chmod_0600_cron_files
USAGE
    exit 1
}


function check_test_exists() # Check test exists
{
    if [[ " ${TEST_FILES[@]} " =~ " $1 " ]]; then
        echo "Running all '$1' ..."
        return 0
    fi

    if [[ ! " ${INDIVIDUAL_TESTS[@]} " =~ " $1 " ]]; then
        echo "The test '$1' does not exist."
        exit 1
    else
        echo "Running '$1' ..."
    fi
}


function print_test_list() # print existing tests
{
    collect_tests
    for i in "${INDIVIDUAL_TESTS[@]}"
    do
        echo $i
    done
}

function print_test_file_list() # print existing test files
{
    collect_test_files
    for i in "${TEST_FILES[@]}"
    do
        echo $i
    done
}


function run_single_test() # run single existing test
{
    local test_name test
    local err_count=0
    local pass_count=0

    case $1 in
        *:*)
            test_name=$( echo $1 | cut -f2 -d: )
            result=$( ${test_name} 2>&1 )
            if [ "_${result}" == "_" ]; then
                result=$(log_success "Passed" 2>&1)
                pass_count=$((pass_count+1))
            else
                err_count=$((err_count+1))
            fi
            echo "${1}: ${result}";;
        *)
            for test in "${INDIVIDUAL_TESTS[@]}"
            do
                if [[ "${test}" == *"$1"* ]]; then
                    test_name=$( echo $test | cut -f2 -d: )
                    result=$( ${test_name} 2>&1 )
                    if [ "_${result}" == "_" ]; then
                        result=$(log_success "Passed" 2>&1)
                        pass_count=$((pass_count+1))
                    else
                        err_count=$((err_count+1))
                    fi
                    echo "${test}: ${result}"
                fi
            done
    esac

    log_header "FAILED: ${err_count}, PASSED: ${pass_count}"

    if [ ${err_count} -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}


function run_all_tests() # run all tests within
{
    local err_count=0
    local pass_count=0

    for test in "${INDIVIDUAL_TESTS[@]}"
    do
        test_name=$( echo $test | cut -f2 -d: )
        result=$( ${test_name} 2>&1 )
        if [ "_${result}" == "_" ]; then
            result=$( log_success "Passed" 2>&1 )
            pass_count=$((pass_count+1))
        else
            err_count=$((err_count+1))
        fi
        echo "${test}: ${result}"
    done

    log_header "FAILED: ${err_count}, PASSED: ${pass_count}"

    if [ ${err_count} -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}


function collect_tests() # Collect all the tests
{
    local path string_tests _tmp_array
    collect_test_files

    for i in "${TEST_FILES[@]}"
    do
        path="$( dirname "$( realpath "$0" )" )"
        test_file_path="$path"/"$i"
        string_tests=$( grep "^test" "$test_file_path" | sed 's/() {/,/' | tr '\n' ' ' | xargs )
        IFS=',' read -a _tmp_array <<< "$string_tests"

        for t in "${_tmp_array[@]}"
        do
            INDIVIDUAL_TESTS+=("$i:$( echo "$t" | xargs )")
        done
    done

}


function collect_test_files() # Collect all the test files
{
    local path string_test_files

    path="$( dirname "$( realpath "$0" )" )"
    string_test_files=$( ls ${path}/ | grep "^test" | tr '\n' ',' | xargs )
    IFS=',' read -a TEST_FILES <<< "$string_test_files"
}


if [ "_$1" = "_" ]; then
    collect_tests
    run_all_tests

else
    if [ "$1" == "run" ]; then
        collect_tests

        if [ "_$2" == "_" ]; then
            echo "Provide test file to run."
        else
            check_test_exists "$2"
            run_single_test "$2"
        fi
    elif [ "$1" == "list" ]; then
        print_test_list
    elif [ "$1" == "help" ]; then
        usage
    else
        usage
    fi
fi

