class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static bool isValidBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    final minDate = DateTime(1900);
    
    if (birthDate.isAfter(now)) {
      return false;
    }
    
    if (birthDate.isBefore(minDate)) {
      return false;
    }

    final age = now.year - birthDate.year;
    if (age > 120) {
      return false;
    }

    return true;
  }

  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String getChineseZodiac(DateTime birthDate) {
    final year = birthDate.year;
    final animals = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    return animals[(year - 4) % 12];
  }

  static String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    switch (month) {
      case 1:
        return day <= 19 ? '摩羯座' : '水瓶座';
      case 2:
        return day <= 18 ? '水瓶座' : '雙魚座';
      case 3:
        return day <= 20 ? '雙魚座' : '白羊座';
      case 4:
        return day <= 19 ? '白羊座' : '金牛座';
      case 5:
        return day <= 20 ? '金牛座' : '雙子座';
      case 6:
        return day <= 21 ? '雙子座' : '巨蟹座';
      case 7:
        return day <= 22 ? '巨蟹座' : '獅子座';
      case 8:
        return day <= 22 ? '獅子座' : '處女座';
      case 9:
        return day <= 22 ? '處女座' : '天秤座';
      case 10:
        return day <= 23 ? '天秤座' : '天蠍座';
      case 11:
        return day <= 21 ? '天蠍座' : '射手座';
      case 12:
        return day <= 21 ? '射手座' : '摩羯座';
      default:
        return '';
    }
  }
} 