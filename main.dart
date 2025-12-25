// This Module for File Organization
import 'dart:io';
import 'organizerSummayClass.dart';

OrganizationSummary organizationSummary = OrganizationSummary();

class Response {
  bool? success;
  String? message;
  dynamic data;

  Response({required this.success, required this.message, this.data});

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
  Response itemTypeByPath(String path) {
    try {
      final FileSystemEntityType type = FileSystemEntity.typeSync(path);
      Response response = Response(success: true, message: "");
      switch (type) {
        case FileSystemEntityType.file:
          response.data = "File";
          break;
        case FileSystemEntityType.directory:
          response.data = "Directory";
          break;
        case FileSystemEntityType.notFound:
          response.data = "Not Found";
          break;
        case FileSystemEntityType.link:
          response.data = "Link";
          break;
        case FileSystemEntityType.pipe:
          response.data = "PiPe";
          break;
        case FileSystemEntityType.unixDomainSock:
          response.data = "UnixDomainSock";
          break;
        default:
          response.data = "UnKnown";
          break;
      }
      return response;
    } catch (e) {
      return Response(success: false, message: e.toString());
    }
  }

  // 2- Delete a File or Directory (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  Response deleteFileOrDir(String path) {
    Response response = Response(success: true, message: "");
    switch (itemTypeByPath(path).data) {
      case "Not Found":
        response.data = "$path is not Found";
        break;
      case "File":
        File(path).deleteSync();
        response.data = "$path is Deleted Succesfully";
        break;
      case "Directory":
        Directory(path).deleteSync();
        response.data = "$path is Deleted Succesfully";
        break;
      case "Link":
        Link(path).deleteSync();
        response.data = "The Link is Deleted Succesffully";
        break;
      case "PiPe":
        response.data = "The Pipe Cannot be Deleted";
        break;
      case "UnixDomainSock":
        response.data = "The UnixDomainSock Cannot be Deleted";
        break;
      default:
    }
    return response;
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
  Response createFileOrDir(String path, {bool isFile = false, String? name}) {
    String fullPath;
    if (name == null) {
      fullPath = path;
    } else {
      fullPath = Platform.isWindows ? "$path\\$name" : "$path/$name";
    }
    Response response = Response(success: true, message: "");
    String type = itemTypeByPath(fullPath).data;
    try {
      if (type == "Not Found" && type != "UnKnown") {
        if (isFile) {
          File(fullPath).createSync();
          response.message = "The $fullPath is created succesfully";
          response.data = fullPath;
        } else {
          Directory(path).createSync();
          response.message = "The $type is created succesfully";
          response.data = fullPath;
        }
      }
      response.success = false;
      response.data = "the $type is Already Exists ";
    } catch (e) {
      response.success = false;
      response.message = "The $type is created succesfully";
    }
    return response;
  }

  // 5- Return List of the How Many Items in a Directory and a Dict of Their Names and Types (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  Response itemsInDir({String? path}) {
    Directory dir;
    if (path == null) {
      dir = Directory.current;
    } else {
      try {
        dir = Directory(path);
        if (!dir.existsSync())
          return Response(success: false, message: "$path is not exists");
      } catch (e) {
        return Response(success: false, message: e.toString());
      }
    }
    List items = dir.listSync();
    List report = [items.length];
    List<List> dirItems = [];
    List<String?> fileAttrs = [];

    for (var x in items) {
      String itemPath = x.path;
      String itemType = itemTypeByPath(itemPath).data;
      String? itemExt;
      if (x.toString().split(".").length > 1) {
        itemExt = x.toString().split(".").last;
      }
      if (itemType == "File") {
        fileAttrs = [itemType, itemPath, itemExt];
      } else {
        fileAttrs = [itemType, itemPath];
      }
      dirItems.add(fileAttrs);
    }
    report.add(dirItems);

    return Response(success: true, message: "", data: report);
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

  Response moveFiles(
    String folderName,
    Directory dir,
    List<dynamic> files,
    OrganizationSummary organizationSummary,
  ) {
    createFileOrDir(name: folderName, dir.path);
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
    return Response(success: true, message: "File is Moved");
  }

  Response organizerDir({String? path, bool deleteEmptyDirs = false}) {
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
    List textFilesExt = ["txt", "docx", "doc", "rtf"];
    List audioExt = ["mp3", "wav", "wma", "midi", "rm"];
    List execFilesExt = ["exe", "com", "bat"];
    List archiveFilesExt = ["zip", "rar", "7z", "tar", "iso"];
    List internetFilesExt = ["html", "htm", "js", "css"];
    List presentionFilesExt = ["pptx", "ppt", "odp"];
    List dataBaseFileExt = ["db", "sql"];
    List emailFilesExt = ["eml", "msg", "pst"];

    List emptyDirs = [];
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
      if (isSingleTypeDir(dir).data == true) {
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
    String folderName;
    if (photos.isNotEmpty && photos.length > 1) {
      folderName = "Photos";
      moveFiles(folderName, dir, photos, organizationSummary);
    }
    if (videos.isNotEmpty && videos.length > 1) {
      folderName = "Videos";
      moveFiles(folderName, dir, videos, organizationSummary);
    }
    if (systemFiles.isNotEmpty && systemFiles.length > 1) {
      folderName = "Documents";
      moveFiles(folderName, dir, systemFiles, organizationSummary);
    }
    if (textFiles.isNotEmpty && textFiles.length > 1) {
      folderName = "Text Files";
      moveFiles(folderName, dir, textFiles, organizationSummary);
    }
    if (audioFiles.isNotEmpty && audioFiles.length > 1) {
      folderName = "Audio Files";
      moveFiles(folderName, dir, audioFiles, organizationSummary);
    }
    if (execFiles.isNotEmpty && execFiles.length > 1) {
      folderName = "Executable Files";
      moveFiles(folderName, dir, execFiles, organizationSummary);
    }
    if (archiveFiles.isNotEmpty && archiveFiles.length > 1) {
      folderName = "Archive Files";
      moveFiles(folderName, dir, archiveFiles, organizationSummary);
    }
    if (intnterFiles.isNotEmpty && intnterFiles.length > 1) {
      folderName = "Internet Files";
      moveFiles(folderName, dir, intnterFiles, organizationSummary);
    }
    if (presentationFiles.isNotEmpty && presentationFiles.length > 1) {
      folderName = "Presentation Files";
      moveFiles(folderName, dir, presentationFiles, organizationSummary);
    }
    if (dataBaseFiles.isNotEmpty && dataBaseFiles.length > 1) {
      folderName = "Database Files";
      moveFiles(folderName, dir, dataBaseFiles, organizationSummary);
    }
    if (emailFiles.isNotEmpty && emailFiles.length > 1) {
      folderName = "Email Files";
      moveFiles(folderName, dir, emailFiles, organizationSummary);
    }
    if (pdfFiles.isNotEmpty && pdfFiles.length > 1) {
      folderName = "PDF Files";
      moveFiles(folderName, dir, pdfFiles, organizationSummary);
    }
    if (others.isNotEmpty && others.length > 1) {
      for (var other in others) {
        var otherExt = other[2];
        folderName = "$otherExt Files";
        createFileOrDir(name: folderName, dir.path);
        organizationSummary.addCreatedFolder(folderName);
        renameOrMove(
          other[1],
          "${dir.path}\\$folderName\\${other[1].split("\\").last}",
        );
        organizationSummary.addMovedFiles(folderName, 1);
      }
    }

    for (var directory in directories) {
      if (deleteEmptyDirs == true &&
          Directory(directory[1]).listSync().isEmpty) {
        emptyDirs.add(directory[1]);
        continue;
      }
      organizerDir(path: directory[1]);
    }
    for (var emptyDir in emptyDirs) {
      deleteFileOrDir(emptyDir[1]);
    }
    organizationSummary.end();
    return Response(success: true, message: "", data: organizationSummary);
  }
}

void main() async {
  FileOrganzier fileOrganzier = FileOrganzier();

  // Example Usage:
  fileOrganzier.itemsInDir();
}
