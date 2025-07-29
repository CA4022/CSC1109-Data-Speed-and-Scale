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
  languages = {
    java = {
      enable = true;
      jdk.package = pkgs.jdk17;
      maven.enable = true;
    };
    python = {
      enable = true;
      package = pkgs.python313;
      uv = {
        enable = true;
      };
    };
    scala = {
      enable = true;
      package = pkgs.scala_2_13;
    };
  };
  packages = [
    containerPkg
    pkgs.act
    pkgs.actionlint
    pkgs.dive
    pkgs.git
    pkgs.google-java-format
    pkgs.jdk17
    pkgs.jdt-language-server
    pkgs.just
    pkgs.maven
    pkgs.metals
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.ruff
    pkgs.scala_2_13
    pkgs.scalafmt
    pkgs.stdenv.cc.cc.lib
    pkgs.zizmor
  ];
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
  ];
}
