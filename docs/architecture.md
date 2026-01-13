# 아키텍처 가이드

이 문서는 Coffee Note 애플리케이션의 기술적 구조와 구현 원칙을 설명합니다.

## 1. 아키텍처 개요

Coffee Note는 **레이어드 아키텍처(Layered Architecture)**와 **기능 중심 폴더 구조(Feature-first folder structure)**를 결합하여 개발되었습니다.

### 1.1 계층 구조 (Layered Architecture)

애플리케이션은 다음과 같은 4개의 주요 계층으로 구성됩니다.

```
Pages (UI)
  ↓
Controllers (State Management - Riverpod Notifiers)
  ↓
Services (Business Logic)
  ↓
Repositories (Data Access - SQLite, File System)
  ↓
Models (Domain Models & Enums)
```

1.  **Pages (UI)**: Flutter 위젯으로 구성된 화면 계층입니다. 상태를 구독하여 화면을 렌더링하고 사용자 입력을 컨트롤러에 전달합니다.
2.  **Controllers**: Riverpod의 `AsyncNotifier` 또는 `Notifier`를 사용하여 화면의 상태를 관리합니다. 서비스 계층을 호출하여 데이터를 가져오고, 로딩/에러 상태를 관리합니다.
3.  **Services**: 순수 비즈니스 로직을 담당합니다. 검색, 필터링(유사도 계산), 이미지 처리, API 호출 등을 수행하며 여러 리포지토리를 조합할 수 있습니다.
4.  **Repositories**: 데이터 소스(SQLite DB, 외부 API, 파일 시스템)에 직접 접근하여 데이터를 CRUD 합니다.
5.  **Models**: 데이터의 구조를 정의하는 엔티티와 열거형(Enum)입니다.

### 1.2 기능 중심 구조 (Feature-first)

`lib/features/` 폴더 내에 각 기능별로 계층이 나뉘어 있습니다.
- `ai_guide/`: AI 센서리 가이드 및 자동 매핑 기능
- `gallery/`: 기록한 커피 사진 모아보기
- `library/`: 전체 커피 노트 목록, 검색, 맛 유사도 필터링

---

## 2. 상태 관리 (Riverpod)

애플리케이션은 **Riverpod 2.x**를 사용하여 의존성 주입(DI)과 상태 관리를 수행합니다.

### 2.1 상태 관리 패턴 (AsyncNotifier)

복잡한 화면(예: Library)은 `AsyncNotifier`와 `ViewData` 패턴을 사용합니다.

- **ViewData**: 화면에 필요한 모든 데이터(상태, 목록, 로딩 플래그, 에러 등)를 담는 불변(Immutable) 클래스입니다.
- **isRefreshing**: 기존 데이터를 유지하면서 배경에서 로딩할 때 사용되는 플래그입니다.

```dart
// 예시: LibraryController 패턴
class LibraryViewData {
  final LibraryState query; // 현재 검색/필터 상태
  final List<Note> notes;   // 결과 목록
  final bool isRefreshing;  // 배경 로딩 중 여부
  final Object? error;      // 발생한 에러
}
```

### 2.2 의존성 주입 (Dependency Injection)

`lib/backend/providers.dart`에서 모든 서비스와 리포지토리의 인스턴스를 관리합니다.

```dart
final noteServiceProvider = Provider<NoteService>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  final imageSvc = ref.watch(imageServiceProvider);
  return NoteService(noteRepository: repo, imageService: imageSvc);
});
```

---

## 3. 데이터 및 저장소

### 3.1 로컬 데이터베이스 (SQLite)
- `DatabaseManager`: 싱글톤 패턴으로 DB 연결 및 스키마 관리를 담당합니다.
- `notes` 테이블: 기본 커피 정보 저장
- `coffee_details` 테이블: 추가적인 상세 정보(원산지, 품종, 테이스팅 노트 등) 저장

### 3.2 이미지 시스템
- `ImageService`: 사용자 이미지를 앱 내부 전용 폴더에 복사/삭제하고 경로를 관리합니다.

---

## 4. 개발 유틸리티 (ADB)

개발 시 유용한 명령어를 정의합니다.

- 앱 삭제: `adb uninstall com.madcamp_w1.madcamp_w1_coffee_note`
- 앱 강제 종료: `adb shell am force-stop com.madcamp_w1.madcamp_w1_coffee_note`

---

## 5. 앞으로의 계획

1.  **에러 처리 표준화**: 전역 에러 핸들링 및 사용자 알림 시스템 보완
2.  **테스트 코드**: 서비스 및 컨트롤러 계층의 단위 테스트 추가
3.  **지도 연동**: 카페 위치 기반 지도 보기 기능 (선택 사항)
