import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/providers/love_fortune_provider.dart';

/// 生日信息輸入畫面
class BirthInfoScreen extends ConsumerStatefulWidget {
  /// 構造函數
  const BirthInfoScreen({super.key});

  @override
  ConsumerState<BirthInfoScreen> createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends ConsumerState<BirthInfoScreen> {
  DateTime? selectedDate;
  final List<String> zodiacSigns = [
    '白羊座', '金牛座', '雙子座', '巨蟹座',
    '獅子座', '處女座', '天秤座', '天蠍座',
    '射手座', '摩羯座', '水瓶座', '雙魚座'
  ];
  String? selectedZodiac;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '請選擇你的生日',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Text(
                  selectedDate != null
                      ? '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日'
                      : '選擇生日',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '請選擇你的星座',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zodiacSigns.map((sign) {
                  return ChoiceChip(
                    label: Text(sign),
                    selected: selectedZodiac == sign,
                    onSelected: (selected) {
                      setState(() {
                        selectedZodiac = selected ? sign : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              CustomButton(
                text: '下一步',
                onPressed: selectedDate != null && selectedZodiac != null
                    ? () {
                        ref.read(userZodiacProvider.notifier).state = selectedZodiac;
                        ref.read(routerProvider).go('/fortune');
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 