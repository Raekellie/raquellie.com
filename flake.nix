{
	description = "My personal website's builder";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		# Theme
		archie-zola = {
			url = "github:XXXMrG/archie-zola";
			flake = false;
		};
	};

	outputs = {
		self,
		nixpkgs,
		...
	} @ inputs: let
		# https://zero-to-nix.com/concepts/flakes/#system-specificity and https://wiki.nixos.org/wiki/Flakes#Core_usage_patterns
		# Architecture list copied from Zola's
		systems = [
			"aarch64-darwin"
			"aarch64-linux"
			"i686-linux"
			"x86_64-darwin"
			"x86_64-linux"
		];
		forAllSystems = f:
			nixpkgs.lib.genAttrs systems (system:
					f {
						pkgs = import nixpkgs {inherit system;};
					});
	in {
		packages =
			forAllSystems ({pkgs}: {
					default =
						pkgs.stdenv.mkDerivation {
							name = "raquellie.com";
							src = ./.;
							# Fails to build without any CA certs on the system
							nativeBuildInputs = with pkgs; [zola cacert];

							preBuild = ''ln -s ${inputs.archie-zola} themes/archie-zola'';
							buildPhase = ''runHook preBuild; zola build; runHook postBuild'';

							installPhase = ''mv public $out'';

							meta = {
								description = "My website :3";
								homepage = "https://raquellie.com";
							};
						};
				});
		# Defining `devShells` is not necessary because `nix develop` drops us into a shell with the default
		# build dependencies by default
	};
}
