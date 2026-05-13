import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/halqa_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();

  List<PersonModel> students = [];
  List<PersonModel> teachers = [];
  List<HalqaModel> halqas = [];

  bool loading = false;
  String? error;

  Future<void> loadAll() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final results = await Future.wait([
        _repo.getStudents(),
        _repo.getTeachers(),
        _repo.getHalqas(),
      ]);

      students = results[0] as List<PersonModel>;
      teachers = results[1] as List<PersonModel>;
      halqas = results[2] as List<HalqaModel>;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createHalqa(Map<String, dynamic> data) async {
    try {
      error = null;
      notifyListeners();

      await _repo.createHalqa(data);
      await loadAll();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAttendance(Map<String, dynamic> data) async {
    try {
      error = null;
      notifyListeners();

      await _repo.addAttendance(data);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try {
      error = null;
      notifyListeners();

      await _repo.addMemorization(data);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTest(Map<String, dynamic> data) async {
    try {
      error = null;
      notifyListeners();

      await _repo.addTest(data);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
