#!/usr/bin/env bash

source assert.sh


test_crond_enabled() {
    local expected actual
    expected="enabled"
    actual=$( systemctl is-enabled crond 2>&1 )
    assert_contain "$actual" "$expected" "crond has not been '${expected}'."
}

test_chmod_0600_cron_files() {
    local expected _files
    _files=('/etc/crontab'
        '/etc/cron.allow'
        '/etc/at.allow'
    )
    expected="600"

    for file in "${_files[@]}"
    do
        actual=$( stat -c '%a' ${file} 2>&1 )
        assert_eq "$actual" "$expected" \
            "'${file}' does not have correct '${expected}' access permissions."
    done
}

test_chmod_0700_cron_files() {
    local expected _files
    _files=('/etc/cron.d'
        '/etc/cron.hourly'
        '/etc/cron.daily'
        '/etc/cron.weekly'
        '/etc/cron.monthly'
    )
    expected="700"

    for file in "${_files[@]}"
    do
        actual=$( stat -c '%a' ${file} 2>&1 )
        assert_eq "$actual" "$expected" \
            "'${file}' does not have correct '${expected}' access permissions."
    done
}

test_cron_files_user_access() {
    local expected _files
    _files=('/etc/crontab'
        '/etc/cron.d'
        '/etc/cron.hourly'
        '/etc/cron.daily'
        '/etc/cron.weekly'
        '/etc/cron.monthly'
        '/etc/cron.allow'
        '/etc/at.allow'
    )
    expected="root"

    for file in "${_files[@]}"
    do
        actual=$( stat -c '%U' ${file} 2>&1)
        assert_eq "$actual" "$expected" "'${file}' Uid is not '${expected}'."
    done
}

test_cron_files_group_access() {
    local expected _files
    _files=('/etc/crontab'
        '/etc/cron.d'
        '/etc/cron.hourly'
        '/etc/cron.daily'
        '/etc/cron.weekly'
        '/etc/cron.monthly'
        '/etc/cron.allow'
        '/etc/at.allow'
    )
    expected="root"

    for file in "${_files[@]}"
    do
        actual=$( stat -c '%G' ${file} 2>&1 )
        assert_eq "$actual" "$expected" "'${file}' Gid is not '${expected}'."
    done
}

test_cron_deny_files_absent() {
    local _files
    _files=('/etc/cron.deny' '/etc/at.deny')

    for file in "${_files[@]}"
    do
        assert_file_not_exist "$file" "$file should not exist."
    done
}

