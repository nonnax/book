#!/usr/bin/env bash
# Id$ nonnax 2021-12-06 23:15:20 +0800
book -l | fzf --preview='book {} | bat -l md --color=always'
