class OrganizationSummary {
  Map<String, int> movedFileCounts = {};
  List<String> createdFolders = [];
  int totalFilesMoved = 0;
  List<String> errors = [];
  DateTime? startTime;
  DateTime? endTime;

  void start() {
    startTime = DateTime.now();
  }

  void end() {
    endTime = DateTime.now();
  }

  double elapsedSeconds() {
    if (startTime == null) return 0.0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inMilliseconds / 1000;
  }

  void addMovedFiles(String category, int count) {
    movedFileCounts[category] = (movedFileCounts[category] ?? 0) + count;
    totalFilesMoved += count;
  }

  void addCreatedFolder(String folderName) {
    createdFolders.add(folderName);
  }

  addError(String error) {
    errors.add(error);
  }

  void printSummary() {
    end();
    print('\n');
    print('╔════════════════════════════════════════╗');
    print('║     ملخص عملية تنظيم المجلدات        ║');
    print('╚════════════════════════════════════════╝');
    print('');

    print('📊 الإحصائيات:');
    print('   • إجمالي الملفات المنقولة: $totalFilesMoved ملف');
    print('   • الوقت المستغرق: ${elapsedSeconds().toStringAsFixed(2)} ثانية');
    print('');

    if (movedFileCounts.isNotEmpty) {
      print('📂 تفاصيل التنظيم:');
      movedFileCounts.forEach((category, count) {
        print('   ✓ $category: $count ملف');
      });
      print('');
    }

    if (createdFolders.isNotEmpty) {
      print('🆕 المجلدات المنشأة:');
      for (var folder in createdFolders) {
        print('   ✓ $folder');
      }
      print('');
    }

    if (errors.isNotEmpty) {
      print('⚠️ الأخطاء:');
      for (var error in errors) {
        print('   ✗ $error');
      }
      print('');
    }
  }


  Map<String, dynamic> getSummary() {
    return {
      "totalFilesMoved": totalFilesMoved,
      "elapsedSeconds": elapsedSeconds(),
      "movedFileCounts": movedFileCounts,
      "createdFolders": createdFolders,
      "errors": errors,
    };
  }

}

void main() {
  OrganizationSummary organizationSummary = OrganizationSummary();
  organizationSummary.printSummary();
}
