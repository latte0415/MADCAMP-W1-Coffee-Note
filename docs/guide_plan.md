# 센서리 가이드 기능 구현

## 기능 설명
흔히 스페셜티라 일컫는 커피에 대한 정보를 입력하면, 그 커피에 대한 감각적 정보를 제공하여 더 잘 즐길 수 있게 해준다.

## 가이드 탭 동작
- 사용자가 자연어 형태로 커피에 대한 정보 입력 (ex: 브라질 워시드 게이샤 등)
- Open AI API를 통해서, 해당 커피에 대한 tasting note 5개 출력 + 후술할 추가될 DB column에 매핑
- 추가하기 버튼을 누르면 해당 정보가 그대로 creation_note에 이식

## 추후 고려사항
- 시간이 된다면, 사용자 데이터 전체를 넘겨서 사용자 취향에 대해서 분석하는 기능

## 기존 DB 스키마 (테이블명: notes)
id: UUID, PK
location: text (현재는 카페 이름, 추후 새로운 column 추가해서 API 연결할 수도 있음)
menu: text
level_acidity: int (1~10)
level_body: int (1~10)
level_bitterness: int (1~10)
comment: text (한줄평 느낌. 텍스트 수 제한 필요)
image: img
score: int (1~5)
drank_at: (유저가 마신 날짜. 시간은 X)
created_at
updated_at

## 데이터 구조 개선
- 상세한 커피 정보에 대해서는 아래의 정보 포함할 예정
1. 생산지(국가/지역)
2. 로스팅 포인트
3. 품종
4. 추출 방식(에스프레소/필터/콜드브루 등)
### User Defined Type 정의 (ENUM)
1. process_type: WASHED, NATURAL, PULPED_NATURAL, HONEY, ETC
2. roasting_point_type: LIGHT, MEDIUM, MEDIUM_DARK, DARK, ETC
3. method_type: ESPRESSO, FILTER, COLD_BREW, ETC
### 스키마 설계 (테이블명: coffee_details)
- id: uuid, pk
- note_id: FK(notes.id), NOT NULL
- origin_country: TEXT
- origin_region: TEXT
- variety: TEXT
- process: process_type(User defined type)
- process_text: TEXT
- roasting_point: roasting_point_type(User defined type)
- roasting_point_text: TEXT
- method: method_type(User defined type)
- method_text: TEXT
* enum은 있는테 text는 null이면 안된다는 제약 조건 필요