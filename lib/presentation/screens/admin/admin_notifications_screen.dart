import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/notification_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/semester_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _categoryFilter;

  static const Map<String, String> _categoryLabels = {
    "GENERAL": "عام",
    "MEMORIZATION": "تسميع",
    "TEST": "اختبار",
    "ATTENDANCE": "حضور",
    "SUCCESS": "نجاح",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.refreshNotifications();
      await provider.refreshPersons(silent: true);
      await provider.refreshHalqas(silent: true);
      await provider.refreshAcademicData(silent: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filteredNotifications(
    List<NotificationModel> notifications,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return notifications.where((item) {
      final matchesCategory =
          _categoryFilter == null || item.category == _categoryFilter;

      if (!matchesCategory) return false;
      if (query.isEmpty) return true;

      return item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          (item.student?.fullName.toLowerCase().contains(query) ?? false) ||
          item.id.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final notifications = _filteredNotifications(provider.notifications);

    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        provider.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة إشعارات النظام"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutationLoading
            ? null
            : () => _showNotificationSheet(context),
        icon: const Icon(Icons.add_alert),
        label: const Text("إرسال إشعار"),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshNotifications(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _buildFilters(),
            const SizedBox(height: 12),
            _buildSummary(provider),
            const SizedBox(height: 12),
            if (provider.isNotificationsLoading && provider.notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (notifications.isEmpty)
              _buildEmptyState()
            else
              ...notifications.map((item) => _buildNotificationCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: "بحث في الإشعارات",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          value: _categoryFilter,
          decoration: const InputDecoration(
            labelText: "فلترة حسب النوع",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text("كل الأنواع"),
            ),
            ..._categoryLabels.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _categoryFilter = value);
          },
        ),
      ],
    );
  }

  Widget _buildSummary(AdminProvider provider) {
    final unreadCount =
        provider.notifications.where((item) => !item.isRead).length;

    return Row(
      children: [
        Expanded(
          child: _metricTile(
            "الإجمالي",
            provider.notifications.length.toString(),
            Icons.notifications,
            Colors.indigo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricTile(
            "غير مقروء",
            unreadCount.toString(),
            Icons.mark_email_unread,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final color = _categoryColor(item.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(_categoryIcon(item.category), color: color),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.message),
              const SizedBox(height: 6),
              Text(
                "${_categoryLabels[item.category] ?? item.category} | ${item.student?.fullName ?? 'إشعار عام'} | ${item.createdAt}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                item.isRead ? "مقروء" : "غير مقروء",
                style: TextStyle(
                  fontSize: 12,
                  color: item.isRead ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              if (!_hasValidNotificationId(item)) return;
              _showNotificationSheet(context, notification: item);
            } else if (value == "delete") {
              if (!_hasValidNotificationId(item)) return;
              _confirmDelete(item);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "edit",
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text("تعديل"),
              ),
            ),
            PopupMenuItem(
              value: "delete",
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text("حذف"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Text(
          "لا توجد إشعارات مطابقة.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showNotificationSheet(
    BuildContext context, {
    NotificationModel? notification,
  }) {
    if (notification != null && !_hasValidNotificationId(notification)) {
      return;
    }

    final provider = context.read<AdminProvider>();
    final isEdit = notification != null;
    final formKey = GlobalKey<FormState>();

    String title = notification?.title ?? "";
    String message = notification?.message ?? "";
    String category = notification?.category.isNotEmpty == true
        ? notification!.category
        : "GENERAL";
    String recipientMode = "student";
    PersonModel? selectedStudent = notification?.student;
    HalqaModel? selectedHalqa;
    SemesterModel? selectedSemester;
    if (notification?.semester != null) {
      final semesterId = notification!.semester!.id;
      for (final semester in provider.semesters) {
        if (semester.id == semesterId) {
          selectedSemester = semester;
          break;
        }
      }
    }
    String sourceObjectId = notification?.sourceObjectId?.toString() ?? "";
    bool isRead = notification?.isRead ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 18,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? "تعديل إشعار" : "إرسال إشعار جديد",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: "عنوان الإشعار",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.trim().isEmpty
                            ? "العنوان مطلوب"
                            : null,
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: message,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "نص الإشعار",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.trim().isEmpty ? "النص مطلوب" : null,
                        onSaved: (value) => message = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: "نوع الإشعار",
                          border: OutlineInputBorder(),
                        ),
                        items: _categoryLabels.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => category = value);
                          }
                        },
                      ),
                      if (!isEdit) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: recipientMode,
                          decoration: const InputDecoration(
                            labelText: "نطاق الإرسال",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "student",
                              child: Text("طالب محدد"),
                            ),
                            DropdownMenuItem(
                              value: "halqa",
                              child: Text("طلاب حلقة"),
                            ),
                            DropdownMenuItem(
                              value: "all",
                              child: Text("كل الطلاب"),
                            ),
                            DropdownMenuItem(
                              value: "system",
                              child: Text("إشعار عام بدون طالب"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() {
                                recipientMode = value;
                                selectedStudent = null;
                                selectedHalqa = null;
                              });
                            }
                          },
                        ),
                        if (recipientMode == "student") ...[
                          const SizedBox(height: 12),
                          _studentDropdown(
                            provider.students,
                            selectedStudent,
                            (value) => setSheetState(
                              () => selectedStudent = value,
                            ),
                          ),
                        ],
                        if (recipientMode == "halqa") ...[
                          const SizedBox(height: 12),
                          _halqaDropdown(
                            provider.halqas,
                            selectedHalqa,
                            (value) => setSheetState(
                              () => selectedHalqa = value,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SemesterModel?>(
                        value: selectedSemester,
                        decoration: const InputDecoration(
                          labelText: "الفصل الدراسي المرتبط (اختياري)",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<SemesterModel?>(
                            value: null,
                            child: Text("بدون فصل"),
                          ),
                          ...provider.semesters.map(
                            (semester) => DropdownMenuItem<SemesterModel?>(
                              value: semester,
                              child: Text(semester.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() => selectedSemester = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: sourceObjectId,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "معرف السجل المرتبط (اختياري)",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => sourceObjectId = value!.trim(),
                      ),
                      if (isEdit)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isRead,
                          title: const Text("تعليم الإشعار كمقروء"),
                          onChanged: (value) {
                            setSheetState(() => isRead = value ?? false);
                          },
                        ),
                      const SizedBox(height: 16),
                      Consumer<AdminProvider>(
                        builder: (context, liveProvider, _) {
                          return ElevatedButton.icon(
                            onPressed: liveProvider.isMutationLoading
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    formKey.currentState!.save();

                                    final payload = _buildPayload(
                                      title: title,
                                      message: message,
                                      category: category,
                                      semester: selectedSemester,
                                      sourceObjectId: sourceObjectId,
                                      isRead: isEdit ? isRead : null,
                                    );

                                    bool success;
                                    int targetCount = 1;
                                    if (isEdit) {
                                      success = await liveProvider
                                          .updateNotification(
                                        notification!.id,
                                        payload,
                                      );
                                    } else {
                                      final entries = _buildSendEntries(
                                        payload,
                                        recipientMode,
                                        selectedStudent,
                                        selectedHalqa,
                                        liveProvider.students,
                                      );

                                      if (entries.isEmpty) {
                                        _showSnack(
                                          "لم يتم تحديد أي مستلم صالح.",
                                          Colors.orange,
                                        );
                                        return;
                                      }

                                      targetCount = entries.length;
                                      final savedCount = await liveProvider
                                          .sendNotificationsBatch(entries);
                                      success = savedCount == targetCount;
                                    }

                                    if (!mounted) return;
                                    if (success) {
                                      Navigator.pop(context);
                                      _showSnack(
                                        isEdit
                                            ? "تم تعديل الإشعار بنجاح."
                                            : "تم إرسال الإشعار إلى $targetCount مستلم.",
                                        Colors.green,
                                      );
                                    }
                                  },
                            icon: liveProvider.isMutationLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(isEdit ? Icons.save : Icons.send),
                            label: Text(isEdit ? "حفظ التعديل" : "إرسال"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _studentDropdown(
    List<PersonModel> students,
    PersonModel? selectedStudent,
    ValueChanged<PersonModel?> onChanged,
  ) {
    return DropdownButtonFormField<PersonModel>(
      value: selectedStudent,
      decoration: const InputDecoration(
        labelText: "اختر الطالب",
        border: OutlineInputBorder(),
      ),
      items: students
          .map(
            (student) => DropdownMenuItem(
              value: student,
              child: Text(student.fullName),
            ),
          )
          .toList(),
      validator: (value) => value == null ? "اختر طالباً" : null,
      onChanged: onChanged,
    );
  }

  Widget _halqaDropdown(
    List<HalqaModel> halqas,
    HalqaModel? selectedHalqa,
    ValueChanged<HalqaModel?> onChanged,
  ) {
    return DropdownButtonFormField<HalqaModel>(
      value: selectedHalqa,
      decoration: const InputDecoration(
        labelText: "اختر الحلقة",
        border: OutlineInputBorder(),
      ),
      items: halqas
          .map(
            (halqa) => DropdownMenuItem(
              value: halqa,
              child: Text("${halqa.name} (${halqa.students.length})"),
            ),
          )
          .toList(),
      validator: (value) => value == null ? "اختر حلقة" : null,
      onChanged: onChanged,
    );
  }

  Map<String, dynamic> _buildPayload({
    required String title,
    required String message,
    required String category,
    required SemesterModel? semester,
    required String sourceObjectId,
    bool? isRead,
  }) {
    final payload = <String, dynamic>{
      "title": title,
      "message": message,
      "category": category,
    };

    if (semester != null) payload["semester"] = semester.id;

    final parsedSourceId = int.tryParse(sourceObjectId);
    if (parsedSourceId != null) {
      payload["source_object_id"] = parsedSourceId;
    }

    if (isRead != null) payload["is_read"] = isRead;

    return payload;
  }

  List<Map<String, dynamic>> _buildSendEntries(
    Map<String, dynamic> basePayload,
    String recipientMode,
    PersonModel? selectedStudent,
    HalqaModel? selectedHalqa,
    List<PersonModel> allStudents,
  ) {
    if (recipientMode == "system") {
      return [Map<String, dynamic>.from(basePayload)];
    }

    List<PersonModel> recipients = [];
    if (recipientMode == "student" && selectedStudent != null) {
      recipients = [selectedStudent];
    } else if (recipientMode == "halqa" && selectedHalqa != null) {
      recipients = selectedHalqa.students;
    } else if (recipientMode == "all") {
      recipients = allStudents;
    }

    return recipients.map((student) {
      return {
        ...basePayload,
        "student": student.id,
      };
    }).toList();
  }

  void _confirmDelete(NotificationModel notification) {
    if (!_hasValidNotificationId(notification)) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف الإشعار"),
        content: Text("هل تريد حذف الإشعار: ${notification.title}؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await context
                  .read<AdminProvider>()
                  .deleteNotification(notification.id);
              if (!mounted) return;
              Navigator.pop(context);
              if (success) {
                _showSnack("تم حذف الإشعار.", Colors.green);
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  bool _hasValidNotificationId(NotificationModel notification) {
    if (notification.id > 0) return true;

    _showSnack(
      "لا يمكن تعديل أو حذف هذا الإشعار لأن الـ API لم يرجع معرف id صالحاً. أضف id إلى NotificationSerializer.",
      Colors.orange,
    );
    return false;
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "MEMORIZATION":
        return Icons.menu_book;
      case "TEST":
        return Icons.fact_check;
      case "ATTENDANCE":
        return Icons.co_present;
      case "SUCCESS":
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "MEMORIZATION":
        return Colors.green;
      case "TEST":
        return Colors.purple;
      case "ATTENDANCE":
        return Colors.orange;
      case "SUCCESS":
        return Colors.blue;
      default:
        return Colors.indigo;
    }
  }
}
