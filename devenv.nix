{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  containerPkg = let
    containerEnv = builtins.getEnv "CONTAINER_ENV";
  in
    if containerEnv == "docker" || containerEnv == ""
    then pkgs.docker
    else if containerEnv == "podman"
    then pkgs.podman
    else if containerEnv == "kubernetes"
    then pkgs.minikube
    else throw "Invalid env variable `CONTAINER_ENV` provided!";
in {
  dotenv.enable = true;
  packages = [
    containerPkg
    pkgs.act
    pkgs.actionlint
    pkgs.git
    pkgs.just
  ];
}
