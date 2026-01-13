import '../repositories/detail_repository.dart';
import '../models/detail.dart';

class DetailService {
    final DetailRepository detailRepository;

    DetailService({required this.detailRepository});

    Future<Detail> createDetail(Detail detail) async {
        return await detailRepository.createDetail(detail);
    }

    Future<Detail?> getDetailByNoteId(String noteId) async {
        return await detailRepository.getDetailByNoteId(noteId);
    }

    Future<Detail> updateDetail(Detail detail) async {
        return await detailRepository.updateDetail(detail);
    }

    Future<bool> deleteDetail(String id) async {
        return await detailRepository.deleteDetail(id);
    }
}