{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      android-nixpkgs-sdk = inputs.android-nixpkgs.sdk.${pkgs.stdenv.hostPlatform.system} (sdkPkgs:
        with sdkPkgs; [
          cmdline-tools-latest
          build-tools-34-0-0
          platform-tools
          platforms-android-34
        ]);
    })
  ];
  environment.systemPackages = with pkgs; [
    android-tools
    android-nixpkgs-sdk
    nodejs_latest
    typescript-language-server
    watchman
  ];
  environment.variables = {
    ANDROID_HOME = "${pkgs.android-nixpkgs-sdk}/share/android-sdk";
    ANDROID_SDK_ROOT = "${pkgs.android-nixpkgs-sdk}/share/android-sdk";
    JAVA_HOME = "${pkgs.jdk17.home}";
    # Fix for Gradle AAPT2 issues (same as before, but global)
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${pkgs.android-nixpkgs-sdk}/share/android-sdk/build-tools/34.0.0/aapt2";
  };
}
