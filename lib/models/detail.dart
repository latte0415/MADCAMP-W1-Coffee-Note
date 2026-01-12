import 'enums/process_type.dart';
import 'enums/roasting_point_type.dart';
import 'enums/method_type.dart';

class Detail {
    final String id;
    final String noteId;
    final String? originCountry;
    final String? originRegion;
    final String? variety;
    final ProcessType? process;
    final String? processText;
    final RoastingPointType? roastingPoint;
    final String? roastingPointText;
    final MethodType? method;
    final String? methodText;
    final List<String>? tastingNotes;

    Detail({
        required this.id,
        required this.noteId,
        this.originCountry,
        this.originRegion,
        this.variety,
        this.process,
        this.processText,
        this.roastingPoint,
        this.roastingPointText,
        this.method,
        this.methodText,
        this.tastingNotes,
    });
}