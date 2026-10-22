{
	description = "My personal website's builder";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
	};

	outputs = {
		self,
		nixpkgs,
	}: let
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
							nativeBuildInputs = with pkgs; [zola];

							buildPhase = ''zola build --output-dir "$out"'';

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
