import '../repositories/detail_repository.dart';
import '../models/detail.dart';

class DetailService {
    static final DetailService instance = DetailService._init();

    DetailService._init();

    Future<Detail> createDetail(Detail detail) async {
        return await DetailRepository.instance.createDetail(detail);
    }

    Future<Detail?> getDetailByNoteId(String noteId) async {
        return await DetailRepository.instance.getDetailByNoteId(noteId);
    }

    Future<Detail> updateDetail(Detail detail) async {
        return await DetailRepository.instance.updateDetail(detail);
    }

    Future<bool> deleteDetail(String id) async {
        return await DetailRepository.instance.deleteDetail(id);
    }
}