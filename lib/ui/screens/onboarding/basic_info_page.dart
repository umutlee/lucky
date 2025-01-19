import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/utils/validators.dart';
import 'package:all_lucky/core/models/user_profile.dart';

class BasicInfoPage extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const BasicInfoPage({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  @override
  ConsumerState<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends ConsumerState<BasicInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final _logger = Logger('BasicInfoPage');
  
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _selectedGender;
  bool _isSubmitting = false;
  bool _autoValidate = false;

  final List<String> _genderOptions = ['男', '女', '其他'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final userProfile = ref.read(userProfileServiceProvider).currentProfile;
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile.name;
          _selectedGender = userProfile.gender;
          _birthDate = userProfile.birthDateTime;
          _birthTime = TimeOfDay.fromDateTime(userProfile.birthDateTime);
        });
        _logger.info('成功加載用戶資料');
      }
    } catch (e) {
      _logger.error('加載用戶資料失敗: $e');
      if (mounted) {
        _showErrorSnackBar('無法加載已保存的資料');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _selectBirthTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _birthTime) {
      setState(() {
        _birthTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
        autovalidateMode: _autoValidate 
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本資料',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '請填寫您的基本資料以獲取更準確的運勢預測',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '姓名',
                hintText: '請輸入您的姓名',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入姓名';
                }
                if (value.length < 2) {
                  return '姓名至少需要2個字';
                }
                return null;
              },
              onChanged: (_) {
                if (!_autoValidate) {
                  setState(() {
                    _autoValidate = true;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: '性別',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請選擇性別';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '出生日期',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthDate == null
                          ? '請選擇出生日期'
                          : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
                      style: TextStyle(
                        color: _birthDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (_birthDate == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  '請選擇出生日期',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _selectBirthTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '出生時間',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthTime == null
                          ? '請選擇出生時間'
                          : '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _birthTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (_birthTime == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  '請選擇出生時間',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool validateForm() {
    if (!widget.formKey.currentState!.validate()) {
      return false;
    }
    if (_birthDate == null) {
      _showErrorSnackBar('請選擇出生日期');
      return false;
    }
    if (_birthTime == null) {
      _showErrorSnackBar('請選擇出生時間');
      return false;
    }
    return true;
  }

  Future<void> saveData() async {
    if (!validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final birthDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );

      final userProfile = UserProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        birthDateTime: birthDateTime,
      );

      await ref.read(userProfileServiceProvider).updateProfile(userProfile);
      _logger.info('成功保存用戶資料');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('資料保存成功'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _logger.error('保存用戶資料失敗: $e');
      if (mounted) {
        _showErrorSnackBar('保存失敗：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
} 