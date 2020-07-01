#!/usr/bin/env bash

source assert.sh


# CIS 2.2.0 section 5.4.4

test_umask_bashrc_contains_0027() {
    local expected actual
    expected="umask 0027"
    actual=$( grep "umask" /etc/bashrc )
    assert_contain "$actual" "$expected" "Should contain ${expected}!"
}

test_umask_bashrc_only_contains_0027() {
    local not_expected_1 not_expected_2 actual
    actual=$( grep "umask" /etc/bashrc )

    not_expected_1="umask 0022"
    assert_not_contain "$actual" "$not_expected_1" "Should not contain ${not_expected_1}!"

    not_expected_2="umask 0002"
    assert_not_contain "$actual" "$not_expected_2" "Should not contain ${not_expected_2}!"
}

test_umask_profile_contains_0027() {
    local expected actual
    expected="umask 0027"
    actual=$( grep "umask" /etc/profile )
    assert_contain "$actual" "$expected" "Should contain ${expected}!"
}

test_umask_profile_only_contains_0027() {
    local not_expected_1 not_expected_2 actual
    actual=$( grep "umask" /etc/profile )

    not_expected_1="umask 0022"
    assert_not_contain "$actual" "$not_expected_1" "Should not contain ${not_expected_1}!"

    not_expected_2="umask 0002"
    assert_not_contain "$actual" "$not_expected_2" "Should not contain ${not_expected_2}!"
}

test_umask_profile_d_contains_0027() {
    local expected actual profile_d_path
    profile_d_path="/etc/profile.d"

    if [ $( ls -l "${profile_d_path}"/*.sh | wc -l ) -eq "0" ]; then
        log_skip "Skip. ${profile_d_path} contains no *.sh files."
        return 0
    else
        expected="umask 0027"
    fi

    actual=$( grep "umask" /etc/profile.d/*.sh )
    assert_contain "$actual" "$expected" "Should contain ${expected}!"
}


test_umask_profile_d_only_contains_0027() {
    local not_expected_1 not_expected_2 actual profile_d_path
    profile_d_path="/etc/profile.d"

    if [ $( ls -l "${profile_d_path}"/*.sh | wc -l ) -eq "0" ]; then
        log_skip "Skip. ${profile_d_path} contains no *.sh files."
        return 0
    else
        expected="umask 0027"
    fi

    actual=$( grep "umask" /etc/profile.d/*.sh )
    not_expected_1="umask 0022"
    assert_not_contain "$actual" "$not_expected_1" "Should not contain ${not_expected_1}!"

    not_expected_2="umask 0002"
    assert_not_contain "$actual" "$not_expected_2" "Should not contain ${not_expected_2}!"
}

test_chmod_0644_files() {
    local expected _files
    _files=('/etc/passwd' '/etc/passwd-' '/etc/group' '/etc/group-')
    expected="0644"

    for file in "${_files[@]}"
    do
        actual=$( stat ${file} )
        assert_contain "$actual" "$expected" \
            "File does not have correct '${expected}' access permissions."
    done
}

test_chmod_0000_files() {
    local expected _files
    _files=('/etc/passwd' '/etc/passwd-' '/etc/group' '/etc/group-')
    expected="0000"

    for file in "${_files[@]}"
    do
        actual=$( stat ${file} )
        assert_contain "$actual" "$expected" \
            "File does not have correct '${expected}' access permissions."
    done
}
