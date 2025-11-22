// This Module for File Organization
// import 'dart:html_common';
import 'dart:io';

// import 'dart:convert';

class FileOrganzier {
  // 1- checkExistence (name, isFile = False, path) -> bool
  // 2- deleteFileOrDir (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  // 3- renameFileOrDir (name, path, newName) -> New Path or False and Reason if Renaming Fails
  // 4- createFileOrDir (name, path, isDirectory : bool = False) -> New Path or False and Reason if Creation Fails
  // 5- itemsInDir (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  // 6- readfile (path) -> (fileContents, lineCount, letterCount)
  // 7- write data to a file and overwrite existing data (path, data) -> True if Write Successful, False and Reason if Write Fails
  // 8- write data to a file and don't overwrite existing data (path, data) -> True if Write Successful, False and Reason if Write Fails
  // 9- Move A file or Directory to another location and return How Many Items Were Moved and Their Name and Types and Date Moved (path, newPath) -> (movedItemsCount, {itemName: itemType, ...), dataMoved)}) or False and Reason if Move Fails
  // 10- Copy A file or Directory to another location and return How Many Items Were Copied and Their Name and Types and Date Copied (path, newPath) -> (copiedItemsCount, {itemName: itemType, ...), dataCopied)}) or False and Reason if Copy Fails
  /* 0- Organize Directory (path) -> (summary of organization process)
    - Know How Many Files and Directories are in a Directory (3rd Function)
    - Create a Subdirectory for Each File Type (e.g., .txt, .jpg, .png, .docx, etc.)
    - Move Each File to its Corresponding Subdirectory
    - Return a Summary of the Organization Process (How Many Files Moved to Each Subdirectory)
  */
  bool checkExistence(String name, path, {bool isFile = false}) {
    "Check if the directory or File already exists";

    var fullPath = Platform.isWindows ? "${path}\\${name}" : "$path/$name";
    if (isFile) {
      return File("$fullPath").existsSync();
    } else {
      return Directory("$fullPath").existsSync();
    }
  }

  // 2- Delete a File or Directory (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  dynamic deleteFileOrDir(String name, path, {bool isFile = false}) {
    var fullPath = Platform.isWindows ? "${path}\\${name}" : "$path/$name";
    print("This is the Full Path => $fullPath");
    try {
      if (isFile) {
        File file = File(fullPath);
        if (!file.existsSync()) return [false, "This file is not found"];
        file.deleteSync();
        return [true, "The file '$name' was deleted successfully"];
      } else {
        Directory dir = Directory(fullPath);
        if (!dir.existsSync()) return [false, "This file is not found"];
        dir.deleteSync();
        return [true, "The file '$name' was deleted successfully"];
      }
    } catch (e) {
      return [false, e.toString()];
    }
  }

  // 3- Rename a File or Directory (name, path, newName) -> New Path or False and Reason if Renaming Fails
  dynamic renameFileOrDir(String name, path, newName, {bool isFile = false}) {
    String fullPath = Platform.isWindows ? "$path\\$name" : "$path/$name";
    String newPath = Platform.isWindows ? "$path\\$newName" : "$path/$newName";
    print(fullPath);
    print(newPath);
    try {
      if (isFile) {
        File file = File(fullPath);
        if (!file.existsSync()) return [false, "This file is not found"];
        print(1);
        file.renameSync(newPath);
        return [true, "$name was renamed to $newName Succesfully"];
      } else {
        Directory dir = Directory(fullPath);
        if (!dir.existsSync()) return [false, "This Dir is not found"];

        dir.renameSync(newPath);
        return [true, "$name was renamed to $newName Succesfully"];
      }
    } catch (e) {
      return [false, e.toString()];
    }
  }

  // Create a New Directory or File and Return its Path (name, path, isFile : bool = False) -> New Path or False and Reason if Creation Fails
  dynamic createFileOrDir(String name, path, {bool isFile = false}) {
    String fullPath = Platform.isWindows ? "$path\\$name" : "$path/$name";
    try {
      if (isFile) {
        File file = File(fullPath);
        if (!file.existsSync()) {
          file.createSync();
          return [true, fullPath];
        } else {
          return [false, "File is Already Exists"];
        }
      } else {
        Directory dir = Directory(fullPath);
        if (!dir.existsSync()) {
          dir.createSync();
          return [true, fullPath];
        } else {
          return [false, "File is Already Exists"];
        }
      }
    } on PathExistsException {
      return "Path is Already Exists";
    } on PathAccessException {
      return [false, "Access is denied in $path"];
    } catch (e) {
      return [false, e.toString()];
    }
  }

  // 5- Return List of the How Many Items in a Directory and a Dict of Their Names and Types (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  dynamic itemsInDir({String? path}) {
    if (path == null) {
      return [
        Directory.current.listSync().length,
        Directory.current.listSync(),
      ];
    } else {
      try {
        Directory dir = Directory(path);
        if (!dir.existsSync()) return [false, "$path is not exists"];
        return [dir.listSync().length, dir.listSync()];
      } on FileSystemException {
        return [false, "$path is not exists"];
      } catch (e) {
        return [false, e.toString()];
      }
    }
  }

  Future readfile(String path) async {
    var config = File('$path');
    try {
      var contents = await config.readAsString();
      int chars = contents.length;
      int lines = contents.split("\n").length;
      return {"File-Content": contents, "Charactars": chars, "Lines": lines};
    } on FileSystemException {
      return "$path is not found";
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> writefile(
    String path,
    String content, {
    String mode = "w",
  }) async {
    File file = File(path);

    if (mode.toLowerCase() != "w" && mode.toLowerCase() != "a") {
      return {"success": false, "error": "invalid mode"};
    }

    try {
      await file.writeAsString(
        content,
        mode: mode.toLowerCase() == "w" ? FileMode.write : FileMode.append,
      );
      return {"success": true, "path": path, "mode": mode};
    } on FileSystemException catch (e) {
      return {"success": false, "error": "Path not found: ${e.message}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}

void main() async {
  // Example usage of the FileOrganzier class
  FileOrganzier fileOrganizer = FileOrganzier();
}
