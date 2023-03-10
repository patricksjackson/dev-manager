{
  pkgs,
  lib,
}: let
  # Generate a yaml file from settings with a top-comment.
  yaml = {
    generate = name: value:
      pkgs.callPackage ({
        runCommand,
        remarshal,
      }:
        runCommand name {
          nativeBuildInputs = [remarshal];
          value = builtins.toJSON value;
          passAsFile = ["value"];
        } ''
          json2yaml "$valuePath" "$out"
          sed -i '1s/^/# DO NOT EDIT!!\n# File generated by dev-manager\n\n/' "$out"
        '') {};

    type = with lib.types; let
      valueType =
        nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ])
        // {
          description = "YAML value";
        };
    in
      valueType;
  };
in {
  inherit yaml;
}
