{
  description = "Calibre-Web-Automated and its book downloader as a stack for homelab-ngx";

  # The homelab daemon builds nixosModules.default on its base module with
  # the nixpkgs homelab-stack.json recommends (manifest version 9).
  outputs = _: {
    nixosModules.default = ./stack.nix;
  };
}
