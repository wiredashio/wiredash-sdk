import 'package:test/test.dart';
import 'package:wiredash/src/core/wuid_generator.dart';

void main() {
  group('uuidToNanoId', () {
    test('default 21', () {
      const uuid = 'f7c1d7e0-8b48-11eb-8dcd-0242ac130003';
      final nanoId = uuidToNanoId(uuid);
      expect(nanoId, 'f7c1d7e08b4811eb8dcd0');
    });

    test('with length', () {
      const uuid = 'f7c1d7e0-8b48-11eb-8dcd-0242ac130003';
      final nanoIdLong = uuidToNanoId(uuid, maxLength: 32);
      expect(nanoIdLong, 'f7c1d7e08b4811eb8dcd0242ac130003');
    });

    test('short does not matter', () {
      const uuid = 'shortuuid';
      final nanoId = uuidToNanoId(uuid);
      expect(nanoId, 'shortuuid');
    });
  });
}
