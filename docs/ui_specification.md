# 핵심 기능
- 커피 향/맛 노트테이킹: 이미지 + 텍스트 (+ 시간 남으면 지도 API)
- 노트 자체 스코어링 (개인화): 원하는 acidity, body, bitterness 레벨에 맞는 지난 리뷰 찾아줌 (유사도)

# DB 스키마
id: UUID, PK
location: text (현재는 카페 이름, 추후 새로운 column 추가해서 API 연결할 수도 있음)
menu: text
level_acidity: int (1~10)
level_body: int (1~10)
level_bitterness: int (1~10)
comment: text (한줄평 느낌. 텍스트 수 제한 필요)
image: img
score: int (1~5)
recorded_at: (유저가 기록한 날짜. 시간은 X)
created_at
updated_at


# IA
## 공통
- 하단 네비게이션 바(공통): LIST_NOTE (1-0-0), GALLERY (2-0-0), RECOMMENDATION (3-0-0)로 이동
- 추가하기 버튼(공통): CREATION_NOTE (1-1-0)로 이동

## LIST_NOTE (1-0-0)
1. 목적
- 현재까지 작성한 note 모아보기 → 정보적인 측면에서 볼 수 있는 리스트
- (시간 나면) 원하는 note 찾아보기 (검색 기능)
2. 구성 요소
- 정렬 버튼 (날짜순, score 순)
- note 컴포넌트 리스트
- note 컴포넌트: title, level 3개, score, recorded_at
- 하단 네비게이션 바(공통): LIST_NOTE (1-0-0), GALLERY (2-0-0), RECOMMENDATION (3-0-0)로 이동
- 추가하기 버튼(공통): CREATION_NOTE (1-1-0)로 이동
3. 액션
- 정렬 버튼 클릭 → 컴포넌트 리스트 정렬
- 컴포넌트 클릭 → DETAILS_NOTE (1-2-0)로 이동

## CREATION_NOTE (1-1-0)
1. 목적
- note 생성
- 팝업 형태로 구현하여 depth 낮추지 않음
2. 구성 요소
- 뒤로 가기 버튼
- 생성하기 버튼
- 입력창
- 카페 이름, 메뉴명, 한줄평: 텍스트 입력
- 레벨(산미, 바디, 쓰기): slider 컴포넌트 활용하여 1~10 int
- 점수: 별점 컴포넌트(?) 활용하여 1~5 int
3. 액션
- 뒤로 가기 버튼: 팝업 해제
- 생성하기 버튼: 생성 호출 이후, 팝업 해제
- 그외 입력창: 형태에 맞게 입력값 저장

## GALLERY (2-0-0)
1. 목적
- 작성한 note의 사진을 가시적으로 보기 위함 → 시각/경험적인 측면에서
2. 구성 요소
- 최상단 Best Note: 최근, 가장 높은 점수를 부여한 Note 노출
- Note contents: image / comment 가 노출되도록 갤러리 형식 구성
- 하단 네비게이션 바(공통): LIST_NOTE (1-0-0), GALLERY (2-0-0), RECOMMENDATION - (3-0-0)로 이동
- 추가하기 버튼(공통): CREATION_NOTE (1-1-0)로 이동
3. 액션
- 이미지 클릭 → DETAILS_NOTE (1-2-0)로 연결
- 스크롤 (콘텐츠는 최신순으로 정렬)

## DETAILS_NOTE (1-2-0)
1. 목적
- note 상세 보기
- 팝업 형태로 구현하여 depth 낮추지 않음
2. 구성 요소
- 뒤로 가기 버튼
- 카페 이름, 메뉴명, 날짜
- 한줄평
- 레벨(산미, 바디, 쓰기)
- 점수
- 사진
3. 액션
- 뒤로 가기 버튼 클릭 → 팝업 해제

## RECOMMENDATION (3-0-0)
1. 목적
- 탭 진입 마다 개인 취향을 선택 (or default?)
- 선택한 취향에 따라 작성한 노트 노출 (score 대로 정렬)
2. 구성 요소
- 개인 취향 선택 창 (총 3개 슬라이드 존재)
  - slider 요소를 사용하여 원하는 컴포넌트 값 조절
  - 선택한 컴포넌트 값에 따라 필터 → 하단에 노트 노출
- 선택한 취향에 따른 노트
  - 점수 순으로 정렬하여 상위 5개 노트 노출
  - note 컴포넌트: title, location, level 3개, score, recorded_at
- 하단 네비게이션 바(공통): LIST_NOTE (1-0-0), GALLERY (2-0-0), RECOMMENDATION (3-0-0)로 이동
- 추가하기 버튼(공통): CREATION_NOTE (1-1-0)로 이동
3. 액션
- 노트 클릭 → DETAILS_NOTE (1-2-0)로 연결
- 스크롤 (콘텐츠는 점수 순으로 정렬)