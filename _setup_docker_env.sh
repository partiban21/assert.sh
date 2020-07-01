#!/usr/bin/env bash

set -e


# cron

# systemctl enable crond

_files=('/etc/cron.d'
    '/etc/cron.hourly'
    '/etc/cron.daily'
    '/etc/cron.weekly'
    '/etc/cron.monthly'
)
for file in "${_files[@]}"
do
    touch "${file}" && chmod 700 "${file}" && chown root:root "${file}"
done

_files=('/etc/crontab'
    '/etc/cron.allow'
    '/etc/at.allow'
)
for file in "${_files[@]}"
do
    touch "${file}" && chmod 600 "${file}"
done

# file_perms

sed -ie  's/umask [0-9]*/umask 0027/' /etc/bashrc
sed -ie  's/umask [0-9]*/umask 0027/' /etc/profile
# replace umask 0000 with 0027 if exists otherwise append uasmk 0027.
sed -ie '/^umask [0-9]*/{h;s/umask [0-9]*/umask 0027/};${x;/^$/{s//umask 0027/;H};x}' /etc/profile.d/*.sh


_files=('/etc/passwd'
    '/etc/passwd-'
    '/etc/group'
    '/etc/group-'
)
for file in "${_files[@]}"
do
    chmod 0644 "${file}"
done

_files=('/etc/shadow'
    '/etc/gshadow'
    '/etc/shadow-'
    '/etc/gshadow-'
)
for file in "${_files[@]}"
do
    chmod 0000 "${file}"
done
