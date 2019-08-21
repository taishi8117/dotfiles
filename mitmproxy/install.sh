#!/bin/bash
MITMPROXY_DIR=$HOME/.mitmproxy
MITMPROXY_CONF=$MITMPROXY_DIR/config.yaml

mkdir -p $MITMPROXY_DIR
ln -sfn $DOTFILES_BASE/mitmproxy/config.yaml $MITMPROXY_CONF
