class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入姓名';
    }
    if (value.length < 2) {
      return '姓名至少需要2個字元';
    }
    if (value.length > 20) {
      return '姓名不能超過20個字元';
    }
    // 檢查是否包含特殊字符
    final RegExp nameRegExp = RegExp(r'^[\u4e00-\u9fa5a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return '姓名只能包含中文、英文字母和空格';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子郵件';
    }
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegExp.hasMatch(value)) {
      return '請輸入有效的電子郵件地址';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入手機號碼';
    }
    final RegExp phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '請輸入有效的10位手機號碼';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }
    if (value.length < 8) {
      return '密碼至少需要8個字元';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return '密碼需要包含至少一個大寫字母';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return '密碼需要包含至少一個小寫字母';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return '密碼需要包含至少一個數字';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return '密碼需要包含至少一個特殊字符';
    }
    return null;
  }
} 