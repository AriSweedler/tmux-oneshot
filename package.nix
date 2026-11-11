# tmux-oneshot's package: the one bin, with its library default pinned to ari-zshlib's store
# copy. The source keeps its live default (Ari's dotfiles path), so a checkout's
# bin/tmux-oneshot runs unpackaged on a machine that has it. jq, fzf and tmux come from PATH at
# run time, not from a wrapper: a wrapper is one more process on a launch path that counts them.
{ lib, stdenvNoCC, zsh, jq, fzf, zshlib }:
let
  libDefault = "\${ARI_ZSHLIB:-\${HOME}/.config/zsh/plugins}";
in
stdenvNoCC.mkDerivation {
  pname = "tmux-oneshot";
  version = "0";
  src = ./bin;
  buildInputs = [ zsh ];
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin tmux-oneshot
    patchShebangs $out/bin
    substituteInPlace $out/bin/tmux-oneshot \
      --replace-fail ${lib.escapeShellArg libDefault} ${lib.escapeShellArg "\${ARI_ZSHLIB:-${zshlib}/lib}"}
    runHook postInstall
  '';

  # A one-file menu lists and assembles; no library path is left unpinned; every library file
  # the bin names exists in the pinned ari-zshlib.
  doInstallCheck = true;
  nativeInstallCheckInputs = [ jq fzf ];
  installCheckPhase = ''
    export HOME=$TMPDIR ZDOTDIR=$TMPDIR
    echo '[{"cmd": "echo hello", "menu": {"name": "hi"}}, {"cmd": "killall Dock"}]' > $TMPDIR/db.json
    [[ "$(TMUX_ONESHOT_DB=$TMPDIR/db.json $out/bin/tmux-oneshot --list | head -n 1)" == hi ]]
    TMUX_ONESHOT_DB=$TMPDIR/db.json $out/bin/tmux-oneshot --dry-run hi | grep -q 'echo hello'
    if grep -n '\.config/zsh/plugins' $out/bin/tmux-oneshot; then echo "the bin still names a live library path"; exit 1; fi
    for f in log.zsh fzf_group.zsh fzf_groups.zsh log_rotate.zsh strip_ansi.zsh; do
      [[ -r ${zshlib}/lib/$f ]] || { echo "ari-zshlib lacks $f"; exit 1; }
    done
  '';

  meta.mainProgram = "tmux-oneshot";
}
