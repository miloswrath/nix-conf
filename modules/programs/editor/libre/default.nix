{pkgs, ...}: let
  lib = pkgs.lib;
  inherit (lib) concatStringsSep;

  libreoffice = pkgs.libreoffice;

  listToEntryString = list:
    if list == []
    then ""
    else concatStringsSep ";" list + ";";

  mkComponent = {
    name,
    flag,
    desktopName,
    comment,
    categories,
    keywords,
    mimeTypes,
  }: let
    script = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [libreoffice];
      text = ''
        exec ${libreoffice}/bin/libreoffice ${flag} "$@"
      '';
    };

    desktopText = lib.concatStringsSep "\n" [
      "[Desktop Entry]"
      "Version=1.0"
      "Type=Application"
      "Name=${desktopName}"
      "Comment=${comment}"
      "Exec=${script}/bin/${name} %U"
      "Icon=${name}"
      "Terminal=false"
      "Categories=${listToEntryString categories}"
      "Keywords=${listToEntryString keywords}"
      "MimeType=${listToEntryString mimeTypes}"
    ] + "\n";

    desktopFile = pkgs.writeTextFile {
      name = "${name}-desktop-entry";
      destination = "/share/applications/${name}.desktop";
      text = desktopText;
    };
  in pkgs.symlinkJoin {
    inherit name;
    paths = [script desktopFile];
  };

  writer = mkComponent {
    name = "libreoffice-writer";
    flag = "--writer";
    desktopName = "LibreOffice Writer";
    comment = "Create and edit text documents";
    categories = ["Office" "WordProcessor"];
    keywords = ["text" "document" "writer"];
    mimeTypes = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.text-template"
      "application/msword"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/rtf"
      "text/plain"
    ];
  };

  draw = mkComponent {
    name = "libreoffice-draw";
    flag = "--draw";
    desktopName = "LibreOffice Draw";
    comment = "Create and edit drawings and diagrams";
    categories = ["Office" "Graphics"];
    keywords = ["diagram" "drawing" "vector"];
    mimeTypes = [
      "application/vnd.oasis.opendocument.graphics"
      "application/vnd.oasis.opendocument.graphics-template"
      "application/vnd.visio"
      "image/svg+xml"
    ];
  };
in {
  environment.systemPackages = [
    writer
    draw
  ];
}
