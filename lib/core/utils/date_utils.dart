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
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  static String getChineseZodiac(DateTime birthDate) {
    final List<String> zodiacSigns = [
      '鼠', '牛', '虎', '兔', '龍', '蛇',
      '馬', '羊', '猴', '雞', '狗', '豬'
    ];
    
    final year = birthDate.year;
    final index = (year - 1900) % 12;
    return zodiacSigns[index];
  }

  static String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return '白羊座';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return '金牛座';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return '雙子座';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return '巨蟹座';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return '獅子座';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return '處女座';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return '天秤座';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return '天蠍座';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return '射手座';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return '摩羯座';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return '水瓶座';
    } else {
      return '雙魚座';
    }
  }
} 