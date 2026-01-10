import 'enums/process_type.dart';
import 'enums/roasting_point_type.dart';
import 'enums/method_type.dart';

class Detail {
    final String id;
    final String noteId;
    final String? originCountry;
    final String? originRegion;
    final String? variety;
    final ProcessType process;
    final String? processText;
    final RoastingPointType roastingPoint;
    final String? roastingPointText;
    final MethodType method;
    final String? methodText;
    final List<String>? tastingNotes;

    Detail({
        required this.id,
        required this.noteId,
        this.originCountry,
        this.originRegion,
        this.variety,
        required this.process,
        this.processText,
        required this.roastingPoint,
        this.roastingPointText,
        required this.method,
        this.methodText,
        this.tastingNotes,
    });
}