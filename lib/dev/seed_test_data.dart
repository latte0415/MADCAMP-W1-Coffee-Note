import 'package:uuid/uuid.dart';

import '../models/detail.dart';
import '../models/enums/method_type.dart';
import '../models/enums/process_type.dart';
import '../models/enums/roasting_point_type.dart';
import '../models/note.dart';
import '../repositories/detail_repository.dart';
import '../repositories/note_repository.dart';

/// 디버그/테스트용 시드 데이터 주입 스크립트.
/// 앱 시작 전 한 번 호출했다가 완료 후 제거하세요.
Future<void> seedTestData() async {
  final now = DateTime.now();
  final uuid = const Uuid();
  final noteRepo = NoteRepository.instance;
  final detailRepo = DetailRepository.instance;

  final noteSeeds = [
    (
      id: 'seed-note-01',
      location: '성수 로스터리 카페',
      menu: '게이샤 핸드드립',
      acidity: 9,
      body: 3,
      bitterness: 2,
      score: 5,
      comment: '플로럴, 시트러스 폭발. 필터/검색 테스트용 키워드: 꽃, 레몬',
      daysAgo: 1,
    ),
    (
      id: 'seed-note-02',
      location: 'Starbucks Gangnam',
      menu: 'Iced Americano',
      acidity: 4,
      body: 5,
      bitterness: 6,
      score: 3,
      comment: '무난한 데일리. 검색 키워드: 아메리카노, 스타벅스',
      daysAgo: 3,
    ),
    (
      id: 'seed-note-03',
      location: '이디야 신촌',
      menu: '바닐라 라떼',
      acidity: 2,
      body: 6,
      bitterness: 3,
      score: 4,
      comment: '바닐라 단향, 바디감 중간. 키워드: 달콤, 라떼',
      daysAgo: 7,
    ),
    (
      id: 'seed-note-04',
      location: '브루클린 커피바',
      menu: '에스프레소 더블샷',
      acidity: 3,
      body: 9,
      bitterness: 8,
      score: 2,
      comment: '탄맛 강함, 쓴맛 강조. 키워드: 쓴, 다크, 에스프레소',
      daysAgo: 12,
    ),
    (
      id: 'seed-note-05',
      location: '제주 해안 카페',
      menu: '콜드브루',
      acidity: 5,
      body: 4,
      bitterness: 4,
      score: 5,
      comment: '깔끔한 단짠 밸런스. 키워드: 콜드브루, 해안, 깔끔',
      daysAgo: 2,
    ),
    (
      id: 'seed-note-06',
      location: '투썸 플레이스',
      menu: '카페 라떼',
      acidity: 4,
      body: 5,
      bitterness: 3,
      score: 3,
      comment: '고소한 우유, 중간 바디. 키워드: 라떼, 고소',
      daysAgo: 20,
    ),
    (
      id: 'seed-note-07',
      location: '홍대 스페셜티',
      menu: '케냐 AA 브루잉',
      acidity: 7,
      body: 4,
      bitterness: 5,
      score: 4,
      comment: '베리, 카시스 계열 산미. 키워드: 베리, 케냐',
      daysAgo: 15,
    ),
    (
      id: 'seed-note-08',
      location: '을지로 감성다방',
      menu: '카푸치노',
      acidity: 3,
      body: 7,
      bitterness: 4,
      score: 4,
      comment: '시나몬 토핑, 크리미. 키워드: 카푸치노, 시나몬',
      daysAgo: 5,
    ),
    (
      id: 'seed-note-09',
      location: 'Megacoffee',
      menu: '헤이즐넛 아메리카노',
      acidity: 2,
      body: 3,
      bitterness: 5,
      score: 2,
      comment: '향은 강한데 맛은 옅음. 키워드: 헤이즐넛, 향',
      daysAgo: 9,
    ),
    (
      id: 'seed-note-10',
      location: '동네 베이커리',
      menu: '플랫화이트',
      acidity: 5,
      body: 6,
      bitterness: 3,
      score: 5,
      comment: '빵과 잘 어울림. 키워드: 플랫화이트, 베이커리',
      daysAgo: 30,
    ),
  ];

  final detailSeeds = [
    (
      id: 'seed-detail-01',
      noteId: 'seed-note-01',
      origin: '에티오피아 예가체프',
      variety: '게이샤',
      process: ProcessType.washed,
      roasting: RoastingPointType.light,
      method: MethodType.filter,
      tasting: ['플로럴', '레몬', '자스민'],
    ),
    (
      id: 'seed-detail-02',
      noteId: 'seed-note-02',
      origin: '콜롬비아 수프리모',
      variety: '아라비카',
      process: ProcessType.natural,
      roasting: RoastingPointType.medium,
      method: MethodType.espresso,
      tasting: ['견과', '초콜릿'],
    ),
    (
      id: 'seed-detail-03',
      noteId: 'seed-note-04',
      origin: '인도네시아 만델링',
      variety: '아라비카',
      process: ProcessType.natural,
      roasting: RoastingPointType.dark,
      method: MethodType.espresso,
      tasting: ['스파이스', '다크초콜릿'],
    ),
    (
      id: 'seed-detail-04',
      noteId: 'seed-note-05',
      origin: '브라질 세라도',
      variety: '버번',
      process: ProcessType.pulpedNatural,
      roasting: RoastingPointType.medium,
      method: MethodType.coldBrew,
      tasting: ['카라멜', '너티', '깔끔'],
    ),
    (
      id: 'seed-detail-05',
      noteId: 'seed-note-07',
      origin: '케냐 AA',
      variety: 'SL28',
      process: ProcessType.washed,
      roasting: RoastingPointType.medium,
      method: MethodType.filter,
      tasting: ['블랙커런트', '베리', '주스'],
    ),
  ];

  for (final seed in noteSeeds) {
    final existing = await noteRepo.getNoteById(seed.id);
    if (existing != null) continue;

    await noteRepo.createNote(
      Note(
        id: seed.id,
        location: seed.location,
        menu: seed.menu,
        levelAcidity: seed.acidity,
        levelBody: seed.body,
        levelBitterness: seed.bitterness,
        comment: seed.comment,
        score: seed.score,
        drankAt: now.subtract(Duration(days: seed.daysAgo)),
      ),
    );
  }

  for (final seed in detailSeeds) {
    final existing = await detailRepo.getDetailByNoteId(seed.noteId);
    if (existing != null) continue;

    await detailRepo.createDetail(
      Detail(
        id: seed.id,
        noteId: seed.noteId,
        originLocation: seed.origin,
        variety: seed.variety,
        process: seed.process,
        processText: seed.process.displayName,
        roastingPoint: seed.roasting,
        roastingPointText: seed.roasting.displayName,
        method: seed.method,
        methodText: seed.method.displayName,
        tastingNotes: seed.tasting,
      ),
    );
  }
}
