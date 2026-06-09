{pkgs, ...}: {
  environment.systemPackages = with pkgs; [mongosh];
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce;
    # enableAuth = true;
    # initialRootPasswordFile = /path/to/secure/passwordFile;
  };
}
