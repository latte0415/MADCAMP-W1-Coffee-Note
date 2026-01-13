# UI 디자인 시스템 및 스펙

이 문서는 Coffee Note 애플리케이션의 디자인 시스템과 화면별 상세 명세를 정의합니다.

## 1. 디자인 시스템

### 1.1 색상 팔레트 (AppColors)
- **Primary Dark**: `#2B1E1A` (주요 텍스트, 버튼 배경, 해시태그 배경)
- **Background**: `#FFFFFF` (전체 화면 및 카드 배경)
- **Border**: `rgba(90, 58, 46, 0.3)` (입력 필드 테두리, 구분선)

### 1.2 타이포그래피 (AppTextStyles)
- **Font Family**: `NanumSquareOTF` (나눔스퀘어)
- **Large Title**: 50px, Bold (Weight 700)
- **Body Text**: 30px, Regular (Weight 400)
- **Letter Spacing**: 0.1em 적용

### 1.3 레이아웃 가이드
- **Border Radius**: 큰 곡률(20px), 작은 곡률(10px)
- **화면 좌우 여백**: 49px (1080px 너비 기준)

---

## 2. 데이터 모델 및 UI 표현

### 2.1 Note (기본 정보)
UI 리스트 및 갤러리에서 표현되는 핵심 정보입니다.
- **location**: 카페 이름
- **menu**: 커피 메뉴명
- **score**: 별점 (1~5점)
- **levels**: 산미(Acidity), 바디(Body), 쓴맛(Bitterness) (1~10 수치)
- **image**: 사용자가 첨부한 사진 경로
- **comment**: 한줄평 (텍스트)
- **drankAt**: 기록된 날짜 (yyyy.MM.dd)

### 2.2 Detail (상세 정보)
노트 생성 시 "상세 정보 추가"를 통해 입력하거나 AI로 생성된 정보입니다.
- **originLocation**: 생산 국가/지역
- **variety**: 품종
- **process**: 가공 방식 (WASHED, NATURAL, HONEY 등)
- **roastingPoint**: 로스팅 정도 (LIGHT, MEDIUM, DARK 등)
- **method**: 추출 방식 (ESPRESSO, FILTER, COLD_BREW 등)
- **tastingNotes**: 테이스팅 노트 해시태그 (최대 5개)

---

## 3. 주요 화면 명세

### 3.1 Library Page (라이브러리)
- **상세 필터 (Spread/Fold)**:
  - 접힘(Fold): 검색 및 정렬(최신순, 별점순)만 표시
  - 펼침(Spread): 산미/바디/쓴맛 슬라이더를 통해 맛 유사도가 높은 노트 추천 (최대 5개)
- **노트 카드**: 
  - 상세 정보가 있는 경우 해시태그와 추가 정보가 포함된 확장형 카드로 표시

### 3.2 Gallery Page (갤러리)
- 사진이 있는 노트만 모아보는 2열 격자 화면입니다.
- 사진 클릭 시 반투명 레이어가 덮이며 기본 정보(메뉴, 카페, 날짜, 맛 수치)가 오버레이됩니다.

### 3.3 AI Guide Page (AI 가이드)
- **자연어 입력**: 사용자가 "에티오피아 워시드 예가체프 꽃향기"와 같이 입력하면 AI가 정보를 분석합니다.
- **센서리 가이드**: 해당 커피를 즐기는 방법에 대한 2~3줄의 가이드를 텍스트로 제공합니다.
- **이어서 기록하기**: AI가 분석한 정보를 자동으로 채워 생성 팝업(Creation Modal)을 엽니다.

### 3.4 Creation & Details Modal (팝업)
- **Creation**: 
  - 기본 정보를 입력하는 폼과 "상세 정보 추가" 토글이 포함됩니다.
  - "상세 정보" 영역에는 드롭다운과 텍스트 입력이 조합된 필드가 포함됩니다.
- **Details**: 
  - 저장된 내용을 확인하고 수정/삭제할 수 있는 화면입니다.

---

## 4. 상호작용 패턴
- **Depth 최소화**: 생성과 상세 보기는 새로운 페이지 이동 대신 팝업(Modal)으로 처리합니다.
- **Floating Action Button (FAB)**: 어떤 탭에서든 즉시 생성이 가능하도록 우측 하단에 상시 노출됩니다.
- **실시간 반응**: 검색어 입력이나 슬라이더 조절 시 별도의 확인 버튼 없이 리스트가 즉시 갱신됩니다.
