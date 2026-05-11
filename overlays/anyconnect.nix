self: super: {
  cisco-anyconnect = super.stdenv.mkDerivation {
    pname = "cisco-anyconnect";
    version = "4.10.04071";

    src = super.fetchurl {
      url = "https://github.com/miloswrath/private-vpn/releases/download/vpn/anyconnect-linux64-4.10.04071-core-vpn-webdeploy-k9.sh";
      sha256 = "8a2db6ea0a8882c48445ebd7b0dee4f53b8321e4e4eac1e7b0d2749c6faaec63";
    };

    nativeBuildInputs = [ super.cacert ]; # Ensure HTTPS works
    installPhase = ''
      mkdir -p $out/opt/cisco/anyconnect
      bash $src --deploy --prefix=$out/opt/cisco/anyconnect
      ln -s $out/opt/cisco/anyconnect/bin/vpnagentd $out/bin/vpnagentd
      ln -s $out/opt/cisco/anyconnect/bin/vpnui $out/bin/vpnui
    '';
    meta = { license = super.licenses.unfree; };
  };
}

