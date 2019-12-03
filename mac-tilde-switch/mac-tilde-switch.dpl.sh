#:title:        Divine deployment: mac-tilde-switch
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    Execute unswitch script on removal
#:created_at:   2019.06.30

D_DPL_NAME='mac-tilde-switch'
D_DPL_DESC="Switch around keys '~' and '±' on Mac's physical keyboard"
D_DPL_PRIORITY=1000
D_DPL_FLAGS=i!
D_DPL_WARNING="Keys '~' and '±' on physical keyboard will switch places"
D_DPL_OS=( macos )

D_TILDE_PLIST_NAME='org.divine.tilde-switch'
D_TILDE_PLIST_PATH="/Library/LaunchDaemons/$D_TILDE_PLIST_NAME.plist"
D_TILDE_SWS_PATH="$D__DPL_ASSET_DIR/switch.sh"
D_TILDE_UNS_PATH="$D__DPL_ASSET_DIR/unswitch.sh"

d_dpl_check()
{
  # Relevant on macOS only; also, rely on stash
  if ! [ "$D__OS_FAMILY" = macos ]
  then d__notify -q -- 'This deployment is macOS only'; return 3; fi
  d__stash -- ready || return 3

  # Init storage variables; source config; do cut-off checks
  local erra=()
  if ! [ -r "$D_TILDE_SWS_PATH" -a -f "$D_TILDE_SWS_PATH" ]
  then erra+=( -i- "- unreadable switch script: '$D_TILDE_SWS_PATH'" ); fi
  if ! [ -r "$D_TILDE_UNS_PATH" -a -f "$D_TILDE_UNS_PATH" ]
  then erra+=( -i- "- unreadable unswitch script: '$D_TILDE_UNS_PATH'" ); fi
  if ((${#erra[@]})); then
    d__notify -lx -- 'Problems detected with this deployment:' "${erra[@]}"
    return 3
  fi

  # Do the check, rely on .plist name being unique enough
  if d__stash -s -- has installed
  then [ -e "$D_TILDE_PLIST_PATH" ] && return 5 || return 6
  else [ -e "$D_TILDE_PLIST_PATH" ] && return 7 || return 2; fi
}

d_dpl_install()
{
  d__context -- notch; d__context -- push 'Installing tilde-switch script'
  local els=( --else-- 'Unable to install' )
  d__cmd chmod +x --SCRIPT_PATH-- "$D_TILDE_SWS_PATH" "${els[@]}" || return 1
  source "$D_TILDE_SWS_PATH" &>/dev/null
  local cmd='tee'; d__require_wfile "$D_TILDE_PLIST_PATH" || cmd='sudo tee'
  d__pipe --sb-- cat <<EOF --pipe-- $cmd --PLIST_PATH-- "$D_TILDE_PLIST_PATH" "${els[@]}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>${D_TILDE_PLIST_NAME}</string>
    <key>Program</key>
    <string>${D_TILDE_SWS_PATH}</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
  </dict>
</plist>
EOF
  (($?)) && return 1
  d__notify -q -- "Loading .plist into launchctl:" -i- "$D_TILDE_PLIST_PATH"
  d__require_sudo launchctl
  if d__cmd sudo launchctl load -w -- --PLIST_PATH-- "$D_TILDE_PLIST_PATH" \
    "${els[@]}"; then d__context -- lop; return 0; else return 1; fi
}

d_dpl_remove()
{
  d__context -- notch; d__context -- push 'Removing tilde-switch script'
  local els=( --else-- 'Unable to remove' )
  d__notify -q -- "Unloading .plist from launchctl:" -i- "$D_TILDE_PLIST_PATH"
  d__require_sudo launchctl
  d__cmd sudo launchctl unload -w -- --PLIST_PATH-- "$D_TILDE_PLIST_PATH" \
    "${els[@]}" || return 1
  local cmd='rm'; d__require_wfile "$D_TILDE_PLIST_PATH" || cmd='sudo rm'
  if d__cmd $cmd -f -- --PLIST_PATH-- "$D_TILDE_PLIST_PATH" "${els[@]}"
  then source "$D_TILDE_UNS_PATH" &>/dev/null; d__context -- lop; return 0
  else return 1; fi
}