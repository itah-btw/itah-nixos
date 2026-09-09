# mpv — video/audio player.
{lib, ...}: {
  flake.modules.homeManager.mpv = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      mpv
    ];

    xdg.mimeApps.defaultApplications = {
      # Video → mpv
      "video/mp4" = ["mpv.desktop"];
      "video/x-matroska" = ["mpv.desktop"];
      "video/webm" = ["mpv.desktop"];
      "video/quicktime" = ["mpv.desktop"];
      "video/ogg" = ["mpv.desktop"];
      "video/x-msvideo" = ["mpv.desktop"];
      "video/x-flv" = ["mpv.desktop"];
      "video/mpeg" = ["mpv.desktop"];
      "video/x-m4v" = ["mpv.desktop"];
      "video/mp2t" = ["mpv.desktop"];
      "video/3gpp" = ["mpv.desktop"];
      "video/x-ms-wmv" = ["mpv.desktop"];
      "application/vnd.apple.mpegurl" = ["mpv.desktop"];
      "application/x-mpegurl" = ["mpv.desktop"];

      # Audio → mpv
      "audio/mpeg" = ["mpv.desktop"];
      "audio/mp4" = ["mpv.desktop"];
      "audio/x-m4a" = ["mpv.desktop"];
      "audio/aac" = ["mpv.desktop"];
      "audio/ogg" = ["mpv.desktop"];
      "audio/opus" = ["mpv.desktop"];
      "audio/vorbis" = ["mpv.desktop"];
      "audio/x-vorbis+ogg" = ["mpv.desktop"];
      "audio/flac" = ["mpv.desktop"];
      "audio/x-flac" = ["mpv.desktop"];
      "audio/wav" = ["mpv.desktop"];
      "audio/x-wav" = ["mpv.desktop"];
      "audio/x-aiff" = ["mpv.desktop"];
      "audio/midi" = ["mpv.desktop"];
      "audio/x-midi" = ["mpv.desktop"];
      "audio/x-matroska" = ["mpv.desktop"];
      "audio/webm" = ["mpv.desktop"];
      "audio/3gpp" = ["mpv.desktop"];
    };
  };
}
