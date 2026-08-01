class Helpers {
  static String formatTime(DateTime dt) => '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  static String formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
  
  static String extractName(String text) {
    if (text.contains('اسمي')) {
      return text.split('اسمي').last.trim().split(RegExp(r'[؟!.,]')).first.trim();
    }
    return '';
  }
}
