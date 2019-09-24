#!/bin/bash

alias mdp='mysqldump'

# 设置临时别名
shopt expand_aliases
exit
shopt -s  expand_aliases
shopt expand_aliases

mdp -h127.0.0.1 -uroot -p123456 test_db boy>tt.sql
