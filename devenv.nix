{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = [
    pkgs.act
    pkgs.docker
    pkgs.git
  ];
}
