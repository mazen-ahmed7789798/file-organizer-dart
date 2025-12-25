import 'dart:io';

bool sortFilesByExt(File item, List<String> extensions, List<File> targetList) {
  String? ext = item.path.split('.').last.toLowerCase();
  if (extensions.contains(ext)) {
    targetList.add(item);
    return true;
  
  }
  return false;
}
