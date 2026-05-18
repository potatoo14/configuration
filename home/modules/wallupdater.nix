{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.wallupdater = {
    Unit = {
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {WantedBy = ["graphical-session.target"];};
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.config/hypr/bin/wallupdater.sh";
    };
  };

  systemd.user.timers.wallupdater = {
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    Install = {WantedBy = ["timers.target"];};
  };
}
