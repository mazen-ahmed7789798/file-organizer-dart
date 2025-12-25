import 'dart:io';
import 'organizerSummayClass.dart';

void moveFiles(String folderName,
               Directory dir, 
               List<dynamic> files,
               OrganizationSummary organizationSummary,
              ) {
  createFileOrDir(folderName, dir.path);
  organizationSummary.addCreatedFolder(folderName);
  for (var file in files) {
    renameOrMove(
      file[1],
      Platform.isWindows
          ? "${dir.path}\\$folderName\\${file[1].split("\\").last}"
          : "${dir.path}/$folderName/${file[1].split("/").last}",
    );
    organizationSummary.addMovedFiles("$folderName", 1);
  }
}
