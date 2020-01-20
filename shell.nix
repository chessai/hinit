with (import ./default.nix {});

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
  hie = all-hies.bios.selection { selector = p: { inherit (p) ghc865; }; };
in hsPkgs.shellFor {
  packages = ps: with ps; [
    hinit
  ];

  withHoogle = true;

  nativeBuildInputs = [ hie hsPkgs.hindent hsPkgs.hlint ];

  shellHook = ''
    export HIE_HOOGLE_DATABASE="$(cat $(which hoogle) | sed -n -e 's|.*--database \(.*\.hoo\).*|\1|p')"
  '';
}
