// class NoteCreatePopup extends StatefulWidget {
//   const NoteCreatePopup({super.key});
//
//   @override
//   State<NoteCreatePopup> createState() => _NoteCreatePopupState();
// }
//
// class _NoteCreatePopupState extends State<NoteCreatePopup> {
//   // 입력 데이터 저장을 위한 상태 변수
//   final TextEditingController _cafeController = TextEditingController();
//   final TextEditingController _menuController = TextEditingController();
//   final TextEditingController _commentController = TextEditingController();
//
//   double _acidity = 5;
//   double _body = 5;
//   double _bitterness = 5;
//   int _score = 3;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       // 키보드 높이만큼 하단에 여백을 줌
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 상단: 뒤로 가기 버튼 (액션바 형식)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("뒤로 가기", style: TextStyle(color: Colors.grey)),
//                   ),
//                   const Text("새 노트 작성", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   const SizedBox(width: 60), // 대칭을 위한 공간
//                 ],
//               ),
//               const Divider(),
//
//               // 텍스트 입력창 섹션
//               _buildTextField("카페 이름", _cafeController),
//               _buildTextField("메뉴명", _menuController),
//               _buildTextField("한줄평", _commentController),
//
//               const SizedBox(height: 20),
//
//               // 슬라이더 섹션 (산미, 바디, 쓰기)
//               _buildSlider("산미", _acidity, (v) => setState(() => _acidity = v)),
//               _buildSlider("바디", _body, (v) => setState(() => _body = v)),
//               _buildSlider("쓴맛", _bitterness, (v) => setState(() => _bitterness = v)),
//
//               const SizedBox(height: 20),
//
//               // 별점 섹션
//               const Text("점수", style: TextStyle(fontSize: 14, color: Colors.grey)),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(5, (index) => IconButton(
//                   onPressed: () => setState(() => _score = index + 1),
//                   icon: Icon(
//                     index < _score ? Icons.star : Icons.star_border,
//                     color: Colors.amber, size: 30,
//                   ),
//                 )),
//               ),
//
//               const SizedBox(height: 30),
//
//               // 생성하기 버튼
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _submitNote,
//                   child: const Text("생성하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 텍스트 필드 빌더
//   Widget _buildTextField(String label, TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 13)),
//     );
//   }
//
//   // 슬라이더 빌더 (1~10 int)
//   Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [Text(label), Text("${value.toInt()}")],
//         ),
//         Slider(
//           value: value, min: 1, max: 10, divisions: 9,
//           activeColor: Theme.of(context).primaryColor,
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }
//
//   // 생성 로직 호출
//   void _submitNote() async {
//     if (_cafeController.text.isEmpty || _menuController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("카페와 메뉴를 입력해주세요!")));
//       return;
//     }
//
//     final newNote = Note(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       location: _cafeController.text,
//       menu: _menuController.text,
//       comment: _commentController.text,
//       levelAcidity: _acidity.toInt(),
//       levelBody: _body.toInt(),
//       levelBitterness: _bitterness.toInt(),
//       score: _score,
//       drankAt: DateTime.now(),
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//
//     await NoteService.instance.createNote(newNote); // 생성 호출 [cite: 1-0-0]
//     if (mounted) Navigator.pop(context); // 팝업 해제 [cite: 1-0-0]
//   }
// }