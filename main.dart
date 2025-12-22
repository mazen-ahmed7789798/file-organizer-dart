// This Module for File Organization
import 'dart:io';
import 'organizerSummayClass.dart';

OrganizationSummary organizationSummary = OrganizationSummary();

class Response {
  bool? success;
  String? message;
  dynamic data;

  Response({required bool success, required String message, dynamic data});

  Map<String, dynamic> toMap() {
    return {"success": success, "message": message, "data": data};
  }
}

class FileOrganzier {
  // 1- checkExistence (name, isFile = False, path) -> bool
  // 2- deleteFileOrDir (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  // 3- renameFileOrDir (name, path, newName) -> New Path or False and Reason if Renaming Fails
  // 4- createFileOrDir (name, path, isDirectory : bool = False) -> New Path or False and Reason if Creation Fails
  // 5- itemsInDir (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  // 6- readfile (path) -> (fileContents, lineCount, letterCount)
  // 7- write data to a file and overwrite existing data (path, data) -> True if Write Successful, False and Reason if Write Fails
  // 8- write data to a file and don't overwrite existing data (path, data) -> True if Write Successful, False and Reason if Write Fails
  // 10- Copy A file or Directory to another location and return How Many Items Were Copied and Their Name and Types and Date Copied (path, newPath) -> (copiedItemsCount, {itemName: itemType, ...), dataCopied)}) or False and Reason if Copy Fails
  /* 0- Organize Directory (path) -> (summary of organization process)
    - Know How Many Files and Directories are in a Directory (5rd Function)
    - Create a Subdirectory for Each File Type (e.g., .txt, .jpg, .png, .docx, etc.)
    - Move Each File to its Corresponding Subdirectory
    - Return a Summary of the Organization Process (How Many Files Moved to Each Subdirectory)
  */
  Response checkExistence(String name, path, {bool isFile = false}) {
    // Check if the directory or File already exists
    if (name.isEmpty || path.isEmpty) {
      return Response(
        success: false,
        message: "Name or Path cannot be empty",
        data: null,
      );
    }
    var fullPath = Platform.isWindows ? "${path}\\${name}" : "$path/$name";
    bool exists = isFile
        ? File(fullPath).existsSync()
        : Directory(fullPath).existsSync();
    return Response(
      success: exists,
      message: exists ? "Exists" : "Not found",
      data: fullPath,
    );
  }

  // 2- Delete a File or Directory (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  Response deleteFileOrDir(String name, path, {bool isFile = false}) {
    var fullPath = Platform.isWindows ? "${path}\\${name}" : "$path/$name";
    try {
      if (isFile) {
        File file = File(fullPath);
        if (!file.existsSync())
          return Response(success: false, message: "This file is not found");
        file.deleteSync();
        return Response(
          success: true,
          message: "The file '$name' was deleted successfully",
        );
      } else {
        Directory dir = Directory(fullPath);
        if (!dir.existsSync())
          return Response(success: false, message: "This file is not found");
        dir.deleteSync();
        return Response(
          success: true,
          message: "The file '$name' was deleted successfully",
        );
      }
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  // 3- Rename a File or Directory (name, path, newName) -> New Path or False and Reason if Renaming Fails
  Future<Response> renameOrMove(String oldPath, String newPath) async {
    final entity = FileSystemEntity.typeSync(oldPath);
    try {
      if (entity == FileSystemEntityType.file) {
        await File(oldPath).rename(newPath);
        return Response(
          success: true,
          message: "The File $oldPath renamed to $newPath",
        );
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(oldPath).rename(newPath);
        return Response(
          success: true,
          message: "The Director $oldPath renamed to $newPath",
        );
      } else {
        return Response(success: false, message: "Not found.");
      }
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  // Create a New Directory or File and Return its Path (name, path, isFile : bool = False) -> New Path or False and Reason if Creation Fails
  Response createFileOrDir(String name, path, {bool isFile = false}) {
    String fullPath = Platform.isWindows ? "$path\\$name" : "$path/$name";

    try {
      if (isFile == true) {
        File file = File(fullPath);
        if (!file.existsSync()) {
          file.createSync();
          return Response(success: true, message: fullPath);
        } else {
          return Response(success: false, message: "File is Already Exists");
        }
      } else {
        Directory dir = Directory(fullPath);
        if (!dir.existsSync()) {
          dir.createSync();
          return Response(success: true, message: fullPath);
        } else {
          return Response(success: false, message: "File is Already Exists");
        }
      }
    } on PathExistsException {
      return Response(success: false, message: "Path is Already Exists");
    } on PathAccessException {
      return Response(success: false, message: "Access is denied in $path");
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  // 5- Return List of the How Many Items in a Directory and a Dict of Their Names and Types (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  Response itemsInDir({String? path}) {
    if (path == null) {
      Directory dir = Directory.current;
      List report = [dir.listSync().length];
      List dirItems = [];
      List items = dir.listSync();
      for (int i = 0; i < items.length; i++) {
        String itemType = items[i].toString().split(" ").first;
        String itemPath = items[i].path;
        String? itemExt;
        if (dir.listSync()[i].toString().split(".").length > 1) {
          itemExt = dir.listSync()[i].toString().split(".").last;
        }
        if (itemType == "File:") {
          List fileAttrs = [itemType, itemPath, itemExt];

          dirItems.add(fileAttrs);
        } else {
          List fileAttrs = [itemType, dir.listSync()[i].path];
          dirItems.add(fileAttrs);
        }
      }
      report.add(dirItems);
      return Response(success: true, message: "", data: report);
    } else {
      try {
        Directory dir = Directory(path);
        if (!dir.existsSync())
          return Response(success: false, message: "$path is not exists");
        List dirItems = [];
        List report = [dir.listSync().length];
        for (int i = 0; i < dir.listSync().length; i++) {
          String itemType = dir.listSync()[i].toString().split(" ").first;
          if (itemType == "File:") {
            List fileAttrs = [
              itemType,
              dir.listSync()[i].path,
              dir.listSync()[i].toString().split(".").last,
            ];
            dirItems.add(fileAttrs);
          } else {
            List fileAttrs = [itemType, dir.listSync()[i].path];
            dirItems.add(fileAttrs);
          }
        }
        report.add(dirItems);
        return Response(success: true, message: "", data: report);
      } on FileSystemException {
        return Response(success: false, message: "$path is not exists");
      } catch (e) {
        return Response(success: false, message: e.toString());
      }
    }
  }

  Future<Response> readfile(String path) async {
    var config = File('$path');
    try {
      var contents = await config.readAsString();
      int chars = contents.length;
      int lines = contents.split("\n").length;
      return Response(
        success: true,
        message: "",
        data: {"File-Content": contents, "Charactars": chars, "Lines": lines},
      );
    } on FileSystemException {
      return Response(success: false, message: "$path is not found");
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  Future<Response> writefile(
    String path,
    String content, {
    String mode = "w",
  }) async {
    File file = File(path);

    if (mode.toLowerCase() != "w" && mode.toLowerCase() != "a") {
      return Response(success: false, message: "invalid mode");
    }

    try {
      await file.writeAsString(
        content,
        mode: mode.toLowerCase() == "w" ? FileMode.write : FileMode.append,
      );
      return Response(
        success: true,
        message: "",
        data: {"path": path, "mode": mode},
      );
    } on FileSystemException catch (e) {
      return Response(success: false, message: "Path not found: ${e.message}");
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  Future<Response> copyFile(String nowPath, newPath) async {
    try {
      File file = File(nowPath);
      await file.copySync(newPath);
      return Response(
        success: true,
        message: "${nowPath.split(r"\").last} is copied to ${newPath}",
        data: File(newPath),
      );
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  Response scanDir(Directory dir) {
    List allItems = itemsInDir(path: dir.path).data[1];
    List files = [];
    List directories = [];

    for (var item in allItems) {
      String itemType = item[0];
      if (itemType == "File:") {
        files.add(item);
      } else {
        directories.add(item);
      }
    }
    return Response(success: true, message: "", data: [files, directories]);
  }

  Response typesInDir(Directory dir) {
    List files = scanDir(dir).data[0];
    List types = [];
    for (var file in files) {
      String? itemExt;
      if (file.length > 2 && file[2] != null) {
        itemExt = (file[2] as String).replaceAll("'", "").trim();
        types.add(itemExt);
      }
    }
    return Response(success: true, message: "", data: types);
  }

  // هذه الدالة تخبرنا اذا كان هذا المجلد يحتوي علي ملفات من نوع واحد ام لا
  Response isSingleTypeDir(Directory dir) {
    List types = typesInDir(dir).data;
    if (types.isNotEmpty) {
      var firstType = types[0];
      for (var type in types) {
        if (type != firstType) {
          return Response(success: true, message: "", data: false);
        }
      }
      return Response(success: true, message: "", data: true);
    } else {
      return Response(success: true, message: "", data: false);
    }
  }

  Response organizerDir({
    String? path,
    bool deleteEmptyDirs = false,
  }) {
    Directory dir;
    List items = [];
    List files = [];
    List directories = [];
    if (itemsInDir(path: Directory.current.path).data[0] == 0) {
      return Response(success: false, message: "The Directory is Empty");
    }
    // Files Extensions
    List photoExt = ["jpg", "jpeg", "png", "ico", "gif", "tif", "bmp", 'svg'];
    List videoExt = ["flv", "wmv", "mkv", "mov", "avi", "mp4", "mpeg", "3gp"];
    List systemFilesExt = ["dll", "sys", "ini"];
    List textFilesExt = ["txt", "pdf", "docx", "doc", "rtf"];
    List audioExt = ["mp3", "wav", "wma", "midi", "rm"];
    List execFilesExt = ["exe", "com", "bat"];
    List archiveFilesExt = ["zip", "rar", "7z", "tar", "iso"];
    List internetFilesExt = ["html", "htm", "js", "css"];
    List presentionFilesExt = ["pptx", "ppt", "odp"];
    List dataBaseFileExt = ["db", "sql"];
    List emailFilesExt = ["eml", "msg", "pst"];

    // Files Lists
    List photos = [];
    List videos = [];
    List systemFiles = [];
    List textFiles = [];
    List audioFiles = [];
    List execFiles = [];
    List archiveFiles = [];
    List intnterFiles = [];
    List presentationFiles = [];
    List dataBaseFiles = [];
    List emailFiles = [];
    List pdfFiles = [];
    List shortcuts = [];
    List others = [];
    if (path == null) {
      dir = Directory.current;
    } else {
      try {
        dir = Directory(path);
      } catch (e) {
        return Response(success: false, message: e.toString());
      }
    }
    if (!dir.existsSync()) {
      return Response(success: false, message: "The Directory is not exists");
    } else {
      if (isSingleTypeDir(dir) == true) {
        return Response(
          success: false,
          message: "The Directory contains a single file type",
        );
      }
    }
    organizationSummary.start();
    items = scanDir(dir).data;
    files = items[0];
    directories = items[1];
    for (List item in files) {
      String? itemExt;
      if (item.length > 2 && item[2] != null) {
        itemExt = (item[2] as String).replaceAll("'", "").trim();
      }

      if (itemExt == null) continue;

      if (itemExt == "lnk") {
        shortcuts.add(item);
        continue;
      } else if (photoExt.contains(itemExt)) {
        photos.add(item);
        continue;
      } else if (videoExt.contains(itemExt)) {
        videos.add(item);
        continue;
      } else if (systemFilesExt.contains(itemExt)) {
        systemFiles.add(item);
        continue;
      } else if (textFilesExt.contains(itemExt)) {
        textFiles.add(item);
        continue;
      } else if (audioExt.contains(itemExt)) {
        audioFiles.add(item);
        continue;
      } else if (execFilesExt.contains(itemExt)) {
        execFiles.add(item);
        continue;
      } else if (archiveFilesExt.contains(itemExt)) {
        archiveFiles.add(item);
        continue;
      } else if (internetFilesExt.contains(itemExt)) {
        intnterFiles.add(item);
        continue;
      } else if (presentionFilesExt.contains(itemExt)) {
        presentationFiles.add(item);
        continue;
      } else if (dataBaseFileExt.contains(itemExt)) {
        dataBaseFiles.add(item);
        continue;
      } else if (emailFilesExt.contains(itemExt)) {
        emailFiles.add(item);
        continue;
      } else if (itemExt == "pdf") {
        pdfFiles.add(item);
        continue;
      } else {
        others.add(item);
        continue;
      }
    } // End of files loop

    if (photos.isNotEmpty && photos.length > 1) {
      createFileOrDir("Photos", dir.path);
      organizationSummary.addCreatedFolder("Photos");
      for (var photo in photos) {
        renameOrMove(
          photo[1],
          "${dir.path}\\Photos\\${photo[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Photos", 1);
      }
    }
    if (videos.isNotEmpty && videos.length > 1) {
      createFileOrDir("Videos", dir.path);
      organizationSummary.addCreatedFolder("Videos");
      for (var video in videos) {
        renameOrMove(
          video[1],
          "${dir.path}\\Videos\\${video[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Videos", 1);
      }
    }
    if (systemFiles.isNotEmpty && systemFiles.length > 1) {
      createFileOrDir("Documents", dir.path);
      organizationSummary.addCreatedFolder("Documents");
      for (var systemFile in systemFiles) {
        renameOrMove(
          systemFile[1],
          "${dir.path}\\Documents\\${systemFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Documents", 1);
      }
    }
    if (textFiles.isNotEmpty && textFiles.length > 1) {
      createFileOrDir("Text Files", dir.path);
      organizationSummary.addCreatedFolder("Text Files");
      for (var textFile in textFiles) {
        renameOrMove(
          textFile[1],
          "${dir.path}\\Text Files\\${textFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Text Files", 1);
      }
    }
    if (audioFiles.isNotEmpty && audioFiles.length > 1) {
      createFileOrDir("Audio Files", dir.path);
      organizationSummary.addCreatedFolder("Audio Files");
      for (var audioFile in audioFiles) {
        renameOrMove(
          audioFile[1],
          "${dir.path}\\Audio Files\\${audioFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Audio Files", 1);
      }
    }
    if (execFiles.isNotEmpty && execFiles.length > 1) {
      createFileOrDir("Executable Files", dir.path);
      organizationSummary.addCreatedFolder("Executable Files");
      for (var execFile in execFiles) {
        renameOrMove(
          execFile[1],
          "${dir.path}\\Executable Files\\${execFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Executable Files", 1);
      }
    }
    if (archiveFiles.isNotEmpty && archiveFiles.length > 1) {
      createFileOrDir("Archive Files", dir.path);
      organizationSummary.addCreatedFolder("Archive Files");
      for (var archiveFile in archiveFiles) {
        renameOrMove(
          archiveFile[1],
          "${dir.path}\\Archive Files\\${archiveFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Archive Files", 1);
      }
    }
    if (intnterFiles.isNotEmpty && intnterFiles.length > 1) {
      createFileOrDir("Internet Files", dir.path);
      organizationSummary.addCreatedFolder("Internet Files");
      for (var internetFile in intnterFiles) {
        renameOrMove(
          internetFile[1],
          "${dir.path}\\Internet Files\\${internetFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Internet Files", 1);
      }
    }
    if (presentationFiles.isNotEmpty && presentationFiles.length > 1) {
      createFileOrDir("Presentation Files", dir.path);
      organizationSummary.addCreatedFolder("Presentation Files");
      for (var presentationFile in presentationFiles) {
        renameOrMove(
          presentationFile[1],
          "${dir.path}\\Presentation Files\\${presentationFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Presentation Files", 1);
      }
    }
    if (dataBaseFiles.isNotEmpty && dataBaseFiles.length > 1) {
      createFileOrDir("Database Files", dir.path);
      organizationSummary.addCreatedFolder("Database Files");
      for (var databaseFile in dataBaseFiles) {
        renameOrMove(
          databaseFile[1],
          "${dir.path}\\Database Files\\${databaseFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Database Files", 1);
      }
    }
    if (emailFiles.isNotEmpty && emailFiles.length > 1) {
      createFileOrDir("Email Files", dir.path);
      organizationSummary.addCreatedFolder("Email Files");
      for (var emailFile in emailFiles) {
        renameOrMove(
          emailFile[1],
          "${dir.path}\\Email Files\\${emailFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("Email Files", 1);
      }
    }
    if (pdfFiles.isNotEmpty && pdfFiles.length > 1) {
      createFileOrDir("PDF Files", dir.path);
      organizationSummary.addCreatedFolder("PDF Files");
      for (var pdfFile in pdfFiles) {
        renameOrMove(
          pdfFile[1],
          "${dir.path}\\PDF Files\\${pdfFile[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("PDF Files", 1);
      }
    }
    if (others.isNotEmpty && others.length > 1) {
      for (var other in others) {
        var otherExt = other[2];
        createFileOrDir("$otherExt Files", dir.path);
        organizationSummary.addCreatedFolder("$otherExt Files");
        renameOrMove(
          other[1],
          "${dir.path}\\$otherExt Files\\${other[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles("$otherExt Files", 1);
      }
    }

    for (var directory in directories) {
      if (deleteEmptyDirs == true &&
          Directory(directory[1]).listSync().isEmpty) {
        deleteFileOrDir(directory[1].split("\\").last, dir.path, isFile: false);
        continue;
      }
      organizerDir(path: directory[1]);
    }
    organizationSummary.end();
    return Response(success: true, message: "", data: organizationSummary);
  }
}

void main() async {
  FileOrganzier fileOrganzier = FileOrganzier();

  // Example Usage:
  
}
