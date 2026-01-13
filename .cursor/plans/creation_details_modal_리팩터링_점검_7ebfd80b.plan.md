---
name: Creation/Details Modal 리팩터링 점검
overview: Creation과 Details modal을 Riverpod 리팩터링에 맞게 점검하고, gallery/library controller refresh 트리거 문제를 해결합니다.
todos: []
---

# Creation/Details Modal 리팩터링 점검 계획

## 현재 상태 분석

### 1. 라이브러리, 갤러리 페이지 Riverpod 리팩터링 변동사항

#### Library 페이지

- `LibraryController` (AsyncNotifier)로 상태 관리
- `libraryControllerProvider.refresh()` 메서드로 데이터 갱신
- `main_page.dart`에서 creation modal 후 library만 refresh (76번 라인)

#### Gallery 페이지  

- `GalleryController` (AsyncNotifier)로 상태 관리
- `galleryControllerProvider.refresh()` 메서드로 데이터 갱신
- details modal에서 `result == true`일 때 `onRefresh()` 호출 (139번 라인)

### 2. Modal과 Controller 연동 현황

#### Creation Modal (`NoteCreatePopup`)

- 위치: `lib/shared/presentation/modals/creation_modal.dart`
- 사용 위치:
- `main_page.dart`: FloatingActionButton에서 호출, library만 refresh
- `ai_guide_page.dart`: prefillData와 함께 호출, refresh 없음
- 현재 문제: Gallery controller refresh가 없음

#### Details Modal (`NoteDetailsModal`)

- 위치: `lib/shared/presentation/modals/details_modal.dart`
- 사용 위치:
- `library_page.dart`: `buildNoteCard` 내부, `controller.refresh()` 콜백 전달
- `gallery_page.dart`: `onRefresh()` 콜백 전달
- 현재 동작: `Navigator.pop(context, true)`로 성공 시 true 반환, `.then()`에서 refresh

### 3. 발견된 문제점

#### 문제 1: Gallery Controller Refresh 누락

- Creation modal에서 노트 생성 시 gallery controller가 refresh되지 않음
- 이미지가 있는 노트를 추가해도 갤러리에 반영 안 됨
- `main_page.dart` 76번 라인에서 library만 refresh

#### 문제 2: Modal과 Controller 직접 연동 없음

- Modal이 Service를 직접 호출 (NoteService.instance)
- Controller와의 의존성 없음 (현재는 콜백 패턴)

## 리팩터링 방향성 검토

### 방향성 1: 콜백 패턴 유지 (현재 방식)

- **장점**: Modal이 Controller에 의존하지 않음, 재사용성 높음
- **단점**: 호출하는 곳에서 refresh 로직 관리 필요

### 방향성 2: Modal에서 Controller 직접 호출

- **장점**: Modal 내부에서 자동 refresh, 호출 코드 단순화
- **단점**: Modal이 Riverpod에 의존, 테스트 복잡도 증가

### 방향성 3: Hybrid (권장)

- Creation modal: 여러 controller refresh 필요 → 콜백 또는 ProviderScope에서 직접 호출
- Details modal: 현재 콜백 패턴 유지 (이미 잘 작동함)

## 수정 사항

### 1. Creation Modal - Gallery Controller Refresh 추가

- `main_page.dart`에서 creation modal 후 library와 gallery 모두 refresh
- 또는 creation modal에서 ProviderScope를 통해 직접 refresh

### 2. Details Modal - 현재 패턴 유지

- 콜백 패턴이 잘 작동하므로 변경 불필요
- Library와 Gallery 모두 `.then((result) => refresh())` 패턴 사용 중

### 3. 추가 개선 (선택사항)

- Creation modal에서도 Riverpod ProviderScope 접근 가능하도록 ConsumerWidget으로 변경 고려
- 또는 콜백 패턴 유지하면서 모든 필요한 controller refresh

## 구현 계획

### 우선순위 1: 에러 수정 (필수)

- `main_page.dart`에서 creation modal 후 gallery controller도 refresh 추가
- 이미지가 있는 노트 생성 시 갤러리에도 반영되도록 수정

### 우선순위 2: 코드 일관성 (선택)

- Creation modal도 ConsumerWidget으로 변경하여 controller 직접 접근
- 또는 콜백 패턴 일관성 유지

### 우선순위 3: 구조 개선 (선택)

- Modal에서 Service 직접 호출 → Controller를 통한 간접 호출로 변경 고려
- 하지만 이는 큰 구조 변경이므로 단계적으로 진행