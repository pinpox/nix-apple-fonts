{
  description = "Apple fonts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
  {

    overlay = final: prev: { 
        sf-mono-font = final.callPackage self.packages.sf-mono-font { };
    };
  } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        sources = {
          sf-compact = {
            url =
              "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
            sha256 = "sha256-U3F91nQki5W1vpb7Yitvr3mPK7b5eyqkGv8iJynVdPI=";
          };

          sf-pro = {
            url =
              "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
            sha256 = "sha256-P69DHx/V0NoDcI6jrZdlhbpjrdHo8DEGT+2yg5jYw/M=";
          };
          sf-mono = {
            url =
              "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
            sha256 = "sha256-P69DHx/V0NoDcI6jrZdlhbpjrdHo8DEGT+2yg5jYw/O=";
          };
          sf-arabic = {
            url =
              "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
            sha256 = "sha256-P69DHx/V0NoDcI6jrZdlhbpjrdHo8DEGT+2yg5jYw/O=";
          };
          new-york = {
            url =
              "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
            sha256 = "sha256-P69DHx/V0NoDcI6jrZdlhbpjrdHo8DEGT+2yg5jYw/O=";
          };
        };

      in rec {
        packages = flake-utils.lib.flattenTree (pkgs.lib.mapAttrs (name: value:

          pkgs.stdenv.mkDerivation {
            pname = "${name}-font";
            version = "1.0";

            src = pkgs.fetchurl {
              url = value.url;
              sha256 = value.sha256;
            };

            nativeBuildInputs = [ pkgs.p7zip ];

            unpackCmd = ''
              7z x $curSrc
              find . -name "*.pkg" -print -exec 7z x {} \;
              find . -name "Payload~" -print -exec 7z x {} \;
            '';

            sourceRoot = "./Library/Fonts";

            dontBuild = true;

            installPhase = ''
              find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/truetype {} \;
              find . -name '*.otf' -exec install -m444 -Dt $out/share/fonts/opentype {} \;
                    '';

            meta = with pkgs.lib; {
              homepage = "https://developer.apple.com/fonts/";
              description = "Apple fonts";
              # license = licenses.unfree;
              maintainers = [ maintainers.pinpox ];
            };
          }) sources);
        defaultPackage = packages.sf-mono;
      });
}
