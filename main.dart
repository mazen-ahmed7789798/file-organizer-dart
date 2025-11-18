// This Module for File Organization
import 'dart:io';

import 'dart:convert';

class FileOrganzier {
  // 1- checkExistence (name, isFile = False, path) -> bool
  // 2- Delete a File or Directory (name, path) -> True if Deleted Successfully, False and Reason if Deletion Fails
  // 3- Rename a File or Directory (name, path, newName) -> New Path or False and Reason if Renaming Fails
  // 4- Create a New Directory or File and Return its Path (name, path, isDirectory : bool = False) -> New Path or False and Reason if Creation Fails
  // 5- Return List of the How Many Items in a Directory and a Dict of Their Names and Types (path = Current Working Directory) -> (Total Items Count, {itemName: itemType, ...})
  // 6- Open a File and Return its Contents and How Many Lines And Letters It has (path) -> (fileContents, lineCount, letterCount)
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

    var fullPath = Platform.isWindows ? r"$path\\$name" : "$path/$name";

    if (isFile) {
      return File("$fullPath").existsSync();
    } else {
      return Directory("$fullPath").existsSync();
    }
  }
}

void main() {
  // Example usage of the FileOrganzier class
  FileOrganzier fileOrganizer = FileOrganzier();
  bool exists = fileOrganizer.checkExistence(
    "img.jpg",
    r"C:\Users\Mazen\Desktop",
  );
  print(Directory("C:\Users\Mazen\Desktop").exists());
  print(exists);
}
