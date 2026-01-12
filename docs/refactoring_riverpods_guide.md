## Library 리팩터링 가이드 (Riverpod 기준)

### 목표
- 화면 전체 깜빡임 제거(기존 데이터 유지 + 부분 로딩)
- 검색 과호출 방지(UI 디바운스)
- 필터 UX 일관화(숨기면 초기화)
- 도메인 가공은 Service에서 일괄 처리
- UI는 select 최소 구독, 이벤트는 read(notifier) 호출
- ref.listen은 build에서만 등록

### 책임 분리
- Service: 검색/정렬/필터(유사도 포함) 결과 생성
- Controller(AsyncNotifier): 쿼리 상태 유지, 호출 타이밍/로딩/에러 관리
- UI: 입력 이벤트 전달, 상태 렌더링(로직 최소화)

### Controller 패턴
- `LibraryViewData`에 `isRefreshing` 추가 → 기존 데이터 유지한 채 부분 로딩 표시.
- 모든 업데이트/refresh는 `_runQuery(nextQuery)` 사용.
- `_runQuery` 템플릿:
  1) 이전 데이터가 있으면 `isRefreshing=true`로 `AsyncValue.data` 세팅
  2) `AsyncValue.guard`로 서비스 호출
  3) 성공 시 data, 실패 시 error(필요 시 에러 배너 전략으로 확장 가능)
- `toggleFilterVisibility`, `updateSort`, `updateSearch`, `updateFilterValues`, `clearFilters` 등은 모두 `_runQuery` 호출만 담당.

### Service 패턴
- 검색/정렬/필터 분기와 가공은 Service 단일 진입점에서 처리.
- Controller는 쿼리 DTO를 만들어 Service에 전달만 한다.

### 필터 정책
- 필터를 닫을 때는 값 초기화, 열 때는 값 유지.
- 슬라이더 값 업데이트는 onChangeEnd + 디바운스(200ms). 토글/초기화 시 디바운스 취소.

### 검색 디바운스(UI)
- TextField onChanged → 250ms Timer 디바운스 → notifier.updateSearch 호출.
- 검색어가 빈 문자열이면 검색 해제.

### 로딩/에러 UX
- 초기 로딩만 전체 스피너.
- 이후 재조회는 `isRefreshing` 플래그로 상단에 작은 인디케이터만 표시하고 리스트는 유지.
- 에러는 현재 AsyncValue.error 전환(데이터 사라짐). 필요 시 “데이터 유지 + 에러 배너” 패턴으로 확장 가능.

### UI 구독 원칙
- watch(select): UI에 필요한 조각만 (searchQuery, sortOption, filterState, notes, isRefreshing 등).
- read(notifier): 이벤트 핸들러에서만.
- ref.listen: build에서 1회 등록해 필터 상태 변화 시 로컬 슬라이더 값 동기화.

### 체크리스트
- [x] Controller에서 update마다 `AsyncValue.loading()` 제거, `_runQuery`로 부분 로딩 처리
- [x] `isRefreshing` 플래그 도입 및 상단 로딩 인디케이터 표시
- [x] 검색 UI 디바운스 적용
- [x] 필터 숨기면 초기화, 슬라이더 onChangeEnd+디바운스, 토글/초기화 시 디바운스 취소
- [x] Service 단일 진입점에서 가공
- [x] UI select 최소 구독, notifier read 호출
- [ ] 에러 시 데이터 유지+배너 전략 필요 시 추가
