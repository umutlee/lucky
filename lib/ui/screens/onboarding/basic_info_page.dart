import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/core/utils/validators.dart';
import 'package:all_lucky/core/utils/date_utils.dart' as date_utils;

class BasicInfoPage extends ConsumerStatefulWidget {
  const BasicInfoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends ConsumerState<BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _selectedGender = '男';
  bool _isSubmitting = false;

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
    final userProfile = ref.read(userProfileServiceProvider).currentProfile;
    if (userProfile != null) {
      setState(() {
        _nameController.text = userProfile.name;
        _selectedGender = userProfile.gender;
        _birthDate = userProfile.birthDateTime;
        _birthTime = TimeOfDay.fromDateTime(userProfile.birthDateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
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
              decoration: const InputDecoration(
                labelText: '姓名 *',
                border: OutlineInputBorder(),
                helperText: '2-20個字元',
                counterText: '',
              ),
              maxLength: 20,
              validator: (value) => Validators.validateName(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '性別 *',
                border: OutlineInputBorder(),
              ),
              items: ['男', '女', '其他'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
              },
              validator: (value) => value == null ? '請選擇性別' : null,
            ),
            const SizedBox(height: 24),
            _buildDateTimePicker(
              title: '出生日期 *',
              value: _birthDate != null 
                ? date_utils.DateUtils.formatDate(_birthDate!)
                : '請選擇',
              onTap: _selectBirthDate,
              error: _birthDate == null ? '請選擇出生日期' : null,
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker(
              title: '出生時間 *',
              value: _birthTime != null
                ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
                : '請選擇',
              onTap: _selectBirthTime,
              error: _birthTime == null ? '請選擇出生時間' : null,
            ),
            const SizedBox(height: 32),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateAndSave,
                  child: const Text('下一步'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String title,
    required String value,
    required VoidCallback onTap,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: error != null ? Colors.red : null,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '選擇出生日期',
      cancelText: '取消',
      confirmText: '確定',
      errorFormatText: '日期格式錯誤',
      errorInvalidText: '日期無效',
      fieldLabelText: '出生日期',
      fieldHintText: 'YYYY/MM/DD',
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
      helpText: '選擇出生時間',
      cancelText: '取消',
      confirmText: '確定',
      hourLabelText: '時',
      minuteLabelText: '分',
    );
    if (picked != null && picked != _birthTime) {
      setState(() {
        _birthTime = picked;
      });
    }
  }

  Future<void> validateAndSave() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null || _birthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫所有必填項目'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 組合出生日期時間
      final birthDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );

      // 驗證日期是否合理
      if (!date_utils.DateUtils.isValidBirthDate(birthDateTime)) {
        throw Exception('出生日期不在有效範圍內');
      }

      // 保存用戶資料
      await ref.read(userProfileServiceProvider).updateBasicInfo(
        name: _nameController.text,
        gender: _selectedGender,
        birthDateTime: birthDateTime,
      );

      if (mounted) {
        // 顯示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('資料保存成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失敗：${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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