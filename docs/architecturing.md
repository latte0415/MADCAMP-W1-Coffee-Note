# 아키텍처 전략

## 현재 아키텍처

### 레이어드 아키텍처 (Layered Architecture)

```
Pages (UI)
  ↓
Services (비즈니스 로직)
  ↓
Repositories (데이터 접근)
  ↓
Models (도메인 모델)
```

### 계층 구조

- **Models**: 도메인 엔티티 (`Note`)
- **Repositories**: 데이터 접근 계층 (Singleton 패턴, SQLite)
- **Services**: 비즈니스 로직 계층
- **Pages**: UI 계층 (Flutter Widgets)

### 데이터 저장소

- SQLite 로컬 데이터베이스 (`notes.db`)
- Repository 패턴으로 데이터 접근 추상화

## 앞으로의 계획

### 1. Service 레이어 완성
- 비즈니스 로직 구현 (현재 미완성)
- 추천 알고리즘 (유사도 계산)
- 검색/필터링 로직

### 2. 기능 확장
- 추천 기능: 유사도 기반 노트 매칭
- 검색 기능: 텍스트/필터 기반 검색
- 지도 API 연동 (선택적)

### 3. 아키텍처 개선
- 상태 관리 (Provider/Riverpod 등)
- 의존성 주입
- 에러 처리 표준화
