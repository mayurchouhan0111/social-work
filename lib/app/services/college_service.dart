import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/college_model.dart';

class CollegeService {
  static const String collegeBaseUrl = 'https://colleges-api-india.fly.dev';
  static const String cowinStatesUrl =
      'https://cdn-api.co-vin.in/api/v2/admin/location/states';
  static const String cowinDistrictsUrl =
      'https://cdn-api.co-vin.in/api/v2/admin/location/districts';

  /// GET all states from CoWIN API
  Future<List<Map<String, dynamic>>> getStates() async {
    final response = await http.get(
      Uri.parse(cowinStatesUrl),
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['states'] ?? []);
    } else {
      throw Exception('Failed to load states');
    }
  }

  /// GET districts for a given state ID from CoWIN API
  Future<List<Map<String, dynamic>>> getDistricts(int stateId) async {
    final response = await http.get(
      Uri.parse('$cowinDistrictsUrl/$stateId'),
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['districts'] ?? []);
    } else {
      throw Exception('Failed to load districts');
    }
  }

  /// POST: Get colleges by state
  Future<List<CollegeModel>> getCollegesByState(String state,
      {int offset = 0}) async {
    final response = await http.post(
      Uri.parse('$collegeBaseUrl/colleges/state'),
      headers: {
        'State': state,
        'Offset': offset.toString(),
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List)
          .map((college) => CollegeModel.fromList(college))
          .toList();
    } else {
      throw Exception('Failed to load colleges by state');
    }
  }

  /// POST: Get colleges by district
  Future<List<CollegeModel>> getCollegesByDistrict(String district,
      {int offset = 0}) async {
    final response = await http.post(
      Uri.parse('$collegeBaseUrl/colleges/district'),
      headers: {
        'District': district,
        'Offset': offset.toString(),
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List)
          .map((college) => CollegeModel.fromList(college))
          .toList();
    } else {
      throw Exception('Failed to load colleges by district');
    }
  }

  /// POST: Search colleges by name
  Future<List<CollegeModel>> searchColleges(String keyword,
      {int offset = 0}) async {
    final response = await http.post(
      Uri.parse('$collegeBaseUrl/colleges/search'),
      headers: {
        'College': keyword,
        'Offset': offset.toString(),
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List)
          .map((college) => CollegeModel.fromList(college))
          .toList();
    } else {
      throw Exception('Failed to search colleges');
    }
  }

  /// POST: Get total number of colleges
  Future<int> getTotalColleges() async {
    final response = await http.post(
      Uri.parse('$collegeBaseUrl/colleges/total'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    } else {
      throw Exception('Failed to get total colleges count');
    }
  }
}
