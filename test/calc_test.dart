import 'package:flutter_test/flutter_test.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/model/position.dart';
import 'package:vieiros/utils/calc.dart';

void main() {
  group('Measurements', () {
    test('Add distance test', () {
      final CurrentTrack currentTrack = CurrentTrack();
      Calc().addDistance(currentTrack);
      expect(currentTrack.distance, 0);
      currentTrack.positions.add(RecordedPosition(43.454530, -8.245961, 0.0, DateTime.now()));
      Calc().addDistance(currentTrack);
      expect(currentTrack.distance, 0);
      currentTrack.positions.add(RecordedPosition(43.503428, -8.190043, 0.0, DateTime.now()));
      Calc().addDistance(currentTrack);
      expect(currentTrack.distance.roundToDouble(), 7073.0);
    });

    test('Add gain', () {
      final CurrentTrack currentTrack = CurrentTrack();
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 0.0, DateTime.now()));
      Calc().setGain(currentTrack);
      expect(currentTrack.altitudeGain, 0);
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 1.0, DateTime.now()));
      Calc().setGain(currentTrack);
      expect(currentTrack.altitudeGain, 1);
    });

    test('Check top/min', () {
      final CurrentTrack currentTrack = CurrentTrack();
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 1.0, DateTime.now()));
      Calc().setTop(currentTrack);
      Calc().setMin(currentTrack);
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 3.0, DateTime.now()));
      Calc().setTop(currentTrack);
      Calc().setMin(currentTrack);
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 2.0, DateTime.now()));
      Calc().setTop(currentTrack);
      Calc().setMin(currentTrack);
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 8.0, DateTime.now()));
      Calc().setTop(currentTrack);
      Calc().setMin(currentTrack);
      currentTrack.positions.add(RecordedPosition(0.0, 0.0, 5.0, DateTime.now()));
      Calc().setTop(currentTrack);
      Calc().setMin(currentTrack);
      expect(currentTrack.altitudeTop, 8.0);
      expect(currentTrack.altitudeMin, 1.0);
    });
  });
}
