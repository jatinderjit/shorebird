import 'package:shorebird_code_push_protocol/shorebird_code_push_protocol.dart';
import 'package:test/test.dart';

void main() {
  group(UpdateReleaseRequest, () {
    test('can be (de)serialized', () {
      const request = UpdateReleaseRequest(
        platform: ReleasePlatform.android,
        status: ReleaseStatus.active,
        metadata: {'foo': 'bar'},
      );
      expect(
        UpdateReleaseRequest.fromJson(request.toJson()).toJson(),
        equals(request.toJson()),
      );
    });

    test('can be (de)serialized without metadata', () {
      const request = UpdateReleaseRequest(
        platform: ReleasePlatform.ios,
        status: ReleaseStatus.active,
        metadata: null,
      );
      expect(
        UpdateReleaseRequest.fromJson(request.toJson()).toJson(),
        equals(request.toJson()),
      );
    });
  });
}
