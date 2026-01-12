import 'package:dio/dio.dart';
import '../models/enums/process_type.dart';
import '../models/enums/roasting_point_type.dart';
import '../models/enums/method_type.dart';

/// 백엔드 API와 통신하는 서비스 클래스
class APIService {
  static final APIService instance = APIService._init();

  APIService._init();

  // Base URL
  static const String baseUrl = 'https://madcamp-w1-coffee-note-backend-production.up.railway.app';

  // Dio 인스턴스
  late final Dio _dio;

  /// Dio 인스턴스 초기화
  Dio get dio {
    if (!_isInitialized) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      _isInitialized = true;
    }
    return _dio;
  }

  bool _isInitialized = false;

  /// 일반 채팅 API 호출
  /// 
  /// [message] 사용자가 입력한 메시지
  /// 
  /// Returns AI 응답 메시지
  /// 
  /// Throws [Exception] 네트워크 오류 또는 서버 오류 발생 시
  Future<String> chat(String message) async {
    try {
      final response = await dio.post(
        '/chat',
        data: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['message'] as String? ?? '';
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('연결 시간이 초과되었습니다. 네트워크를 확인해주세요.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorMessage = e.response!.data?['detail'] as String? ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류 ($statusCode): $errorMessage');
      } else {
        throw Exception('알 수 없는 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('요청 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 채팅 매핑 API 호출 (커피 정보 추출)
  /// 
  /// [message] 커피 정보가 포함된 사용자 메시지
  /// 
  /// Returns 구조화된 커피 정보를 담은 Map
  /// 
  /// Throws [Exception] 네트워크 오류 또는 서버 오류 발생 시
  Future<Map<String, dynamic>> chatForMapping(String message) async {
    try {
      final response = await dio.post(
        '/chat-for-mapping',
        data: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return _parseMappingResponse(data);
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('연결 시간이 초과되었습니다. 네트워크를 확인해주세요.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorMessage = e.response!.data?['detail'] as String? ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류 ($statusCode): $errorMessage');
      } else {
        throw Exception('알 수 없는 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('요청 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// API 응답을 Detail 모델 구조에 맞게 파싱
  Map<String, dynamic> _parseMappingResponse(Map<String, dynamic> data) {
    return {
      'originLocation': data['location'] as String?,
      'variety': data['variety'] as String?,
      'process': _parseEnum(data['process'], ProcessType.fromDbValue),
      'processText': data['process_text'] as String?,
      'roastingPoint': _parseEnum(data['roasting_point'], RoastingPointType.fromDbValue),
      'roastingPointText': data['roasting_point_text'] as String?,
      'method': _parseEnum(data['method'], MethodType.fromDbValue),
      'methodText': data['method_text'] as String?,
      'tastingNotes': _parseTastingNotes(data['tasting_notes']),
    };
  }

  /// Enum 값을 파싱하는 헬퍼 함수
  T? _parseEnum<T>(dynamic value, T Function(String) parser) {
    if (value == null || value is! String) return null;
    try {
      return parser(value);
    } catch (e) {
      return null;
    }
  }

  /// Tasting notes를 파싱하는 헬퍼 함수
  List<String> _parseTastingNotes(dynamic value) {
    if (value is List) {
      return value.cast<String>();
    }
    return <String>[];
  }
}
