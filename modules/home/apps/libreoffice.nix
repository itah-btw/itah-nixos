# LibreOffice — office suite.
{lib, ...}: {
  flake.modules.homeManager.libreoffice = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      libreoffice
    ];

    xdg.mimeApps.defaultApplications = {
      # Word processing → LibreOffice Writer
      "application/vnd.oasis.opendocument.text" = ["writer.desktop"];
      "application/vnd.oasis.opendocument.text-template" = ["writer.desktop"];
      "application/msword" = ["writer.desktop"];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["writer.desktop"];
      "application/rtf" = ["writer.desktop"];
      "text/rtf" = ["writer.desktop"];

      # Spreadsheets → LibreOffice Calc
      "application/vnd.ms-excel" = ["calc.desktop"];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = ["calc.desktop"];
      "application/vnd.oasis.opendocument.spreadsheet" = ["calc.desktop"];
      "application/vnd.oasis.opendocument.spreadsheet-template" = ["calc.desktop"];
      "text/csv" = ["calc.desktop"];

      # Presentations → LibreOffice Impress
      "application/vnd.ms-powerpoint" = ["impress.desktop"];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
      "application/vnd.oasis.opendocument.presentation" = ["impress.desktop"];
      "application/vnd.oasis.opendocument.presentation-template" = ["impress.desktop"];
    };
  };
}
