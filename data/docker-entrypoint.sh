#!/bin/bash

. $HOME/.bashrc

$HOME/.local/bin/code-server \
    --auth none \
    --bind-addr 0.0.0.0:8080 \
    $HOME/workspaces/contests/contests.code-workspace

