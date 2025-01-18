import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/core/services/api_client.dart';

@GenerateMocks([ApiClient])
void main() {
  group('ApiClient Tests', () {
    test('placeholder test', () {
      expect(true, isTrue);
    });
  });
}