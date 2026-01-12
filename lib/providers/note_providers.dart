import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_manager.dart';
import '../services/image_service.dart';
import '../repositories/note_repository.dart';
import '../services/note_service.dart';

/// DatabaseManager Provider (필요 시 override 가능)
final databaseManagerProvider = Provider<DatabaseManager>((ref) {
  return DatabaseManager.instance;
});

/// ImageService Provider (필요 시 override 가능)
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService.instance;
});

/// NoteRepository DI용 Provider.
/// DatabaseManager 의존성을 주입받아 생성하며, 테스트에서 override 가능.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final dbManager = ref.watch(databaseManagerProvider);
  return NoteRepository(databaseManager: dbManager);
});

/// NoteService DI용 Provider.
/// NoteRepository와 ImageService를 주입해 생성하며, override 가능.
final noteServiceProvider = Provider<NoteService>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  final imageSvc = ref.watch(imageServiceProvider);
  return NoteService(noteRepository: repo, imageService: imageSvc);
});
