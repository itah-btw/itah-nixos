# zathura — PDF/DJVU/comic viewer (bundles mupdf/poppler plugins).
{lib, ...}: {
  flake.modules.homeManager.zathura = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      zathura
    ];

    xdg.mimeApps.defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
      "image/vnd.djvu" = ["org.pwmt.zathura-djvu.desktop"];
      "application/x-cbz" = ["org.pwmt.zathura-cb.desktop"];
      "application/postscript" = ["org.pwmt.zathura-ps.desktop"];
      "image/x-eps" = ["org.pwmt.zathura-ps.desktop"];
    };
  };
}
