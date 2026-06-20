import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart'; // حزمة التقاط الشاشة المعتمدة
import 'package:quran_center_app/services/api/GeneralApi.dart';

class LeaderboardTestScreen extends StatefulWidget {
  const LeaderboardTestScreen({super.key});

  @override
  State<LeaderboardTestScreen> createState() => _LeaderboardTestScreenState();
}

class _LeaderboardTestScreenState extends State<LeaderboardTestScreen> {
  final GeneralApi _api = GeneralApi();
  
  // متحكم التقاط محتوى اللوحة بدقة هندسية
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // فلاتر التحكم الافتراضية
  String _selectedPeriod = 'weekly';  // daily, weekly, monthly, semester
  String _selectedMetric = 'pages';   // pages, points, excellent, very_good
  String _selectedScope = 'global';    // global, my_halqa

  bool _isLoading = false;
  bool _isSharing = false; // مؤشر حماية أثناء توليد ملف المشاركة
  String? _errorMessage;
  List<dynamic> _leaderboardList = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.getLeaderboard(
        period: _selectedPeriod,
        metric: _selectedMetric,
        scope: _selectedScope,
      );

      if (mounted) {
        setState(() {
          _leaderboardList = data['leaderboard'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "فشل في جلب بيانات لوحة الصدارة. تأكد من اتصال السيرفر.";
          _isLoading = false;
        });
      }
    }
  }

 
// 🎯 التابع المسؤول عن التقاط الشاشة وتحويلها إلى ملف ومشاركتها فوراً
  // محدث ومستمتل بالكامل ليتوافق مع بنية كائن ShareParams في الإصدارات الحديثة
  Future<void> _handleShare() async {
    if (_leaderboardList.isEmpty) return;
    
    setState(() => _isSharing = true);

    try {
      // 1. التقاط الـ Widget وتحويله إلى بايتات
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        // 2. حفظ الصورة في مسار مؤقت آمن
        final directory = await getTemporaryDirectory();
        final String imagePath = '${directory.path}/leaderboard_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // 3. 🚀 الإصلاح الهندسي الحرج:
        // نقوم بإنشاء كائن ShareParams وتمرير النص والملفات بداخل حقوله المخصصة
        await SharePlus.instance.share(
          ShareParams(
            text: '🏆 لوحة الصدارة والالتزام - مركز القرآن الكريم 🏆\nالمعيار: $_selectedMetric | الفترة: $_selectedPeriod',
            files: [XFile(imagePath)],
          ),
        );
        if (await imageFile.exists()) {
    await imageFile.delete();
  }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء إعداد ملف المشاركة، يرجى إعادة المحاولة.', style: TextStyle(fontFamily: "Cairo")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        title: const Text(
          "لوحة الصدارة والالتزام",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر المشاركة الذكي المحمي بمؤشر تحميل
          _isSharing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'مشاركة اللوحة',
                  onPressed: _leaderboardList.isEmpty ? null : _handleShare,
                ),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط تصفية الخيارات العلوية
          _buildFilterSection(),
          
          // 2. عرض المحتوى بناءً على حالة الـ API وتغليفه بمتحكم الالتقاط
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _leaderboardList.isEmpty
                        ? _buildEmptyWidget()
                        : Screenshot(
                            controller: _screenshotController,
                            child: _buildLeaderboardContent(),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade800,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip("الأكثر تسميعاً", "pages", _selectedMetric, (val) => setState(() => _selectedMetric = val)),
                _buildChip("النقاط التراكمية", "points", _selectedMetric, (val) => setState(() => _selectedMetric = val)),
                _buildChip("تقدير ممتاز ✨", "excellent", _selectedMetric, (val) => setState(() => _selectedMetric = val)),
                _buildChip("تقدير جيد جداً ⭐", "very_good", _selectedMetric, (val) => setState(() => _selectedMetric = val)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTextButton("يومي", "daily"),
              _buildTextButton("أسبوعي", "weekly"),
              _buildTextButton("شهري", "monthly"),
              _buildTextButton("الفصل الحالي", "semester"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, String currentSelected, Function(String) onSelected) {
    final isSelected = value == currentSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontFamily: "Cairo", fontSize: 12, color: isSelected ? Colors.teal.shade900 : Colors.white)),
        selected: isSelected,
        selectedColor: Colors.amber.shade400,
        backgroundColor: Colors.teal.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {
          onSelected(value);
          _fetchLeaderboardData();
        },
      ),
    );
  }

  Widget _buildTextButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _fetchLeaderboardData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.amber.shade300 : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    final topStudents = _leaderboardList.take(3).toList();
    final remainingStudents = _leaderboardList.skip(3).toList();

    return RefreshIndicator(
      onRefresh: _fetchLeaderboardData,
      child: Container(
        color: const Color(0xfff7f9fa), // تثبيت اللون لضمان جودة خلفية لقطة الشاشة
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (topStudents.isNotEmpty) _buildPodium(topStudents),
            const SizedBox(height: 16),
            if (remainingStudents.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remainingStudents.length,
                itemBuilder: (context, index) {
                  final student = remainingStudents[index];
                  return _buildStudentListCard(student);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<dynamic> top3) {
    final hasRank1 = top3.isNotEmpty;
    final hasRank2 = top3.length > 1;
    final hasRank3 = top3.length > 2;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasRank2) _buildPodiumPillar(top3[1], 2, 115, Colors.grey.shade400),
          const SizedBox(width: 8),
          if (hasRank1) _buildPodiumPillar(top3[0], 1, 150, Colors.amber.shade600),
          const SizedBox(width: 8),
          if (hasRank3) _buildPodiumPillar(top3[2], 3, 95, Colors.brown.shade400),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar(dynamic student, int rank, double height, Color color) {
    String fullName = student['full_name'] ?? '';
    String initial = fullName.isNotEmpty ? fullName.split(' ').first : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1) const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
        Container(
          width: 100, // زيادة العرض قليلاً لزيادة مساحة استيعاب النص
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  initial.isNotEmpty ? initial.substring(0, 1) : '',
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(height: 6),
              
              // 🚀 التحديث الهندسي الحرج: منع الـ Overflow للأسماء الطويلة نهائياً
              SizedBox(
                height: 18,
                child: FittedBox(
                  fit: BoxFit.scaleDown, // تصغير حجم الخط آلياً عند زيادة الحروف
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      fullName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${student['score']}",
                style: TextStyle(fontFamily: "Cairo", fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 85,
          height: height - 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              "$rank",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentListCard(dynamic student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
          child: Center(
            child: Text(
              "${student['rank']}",
              style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: Colors.teal.shade800),
            ),
          ),
        ),
        title: Text(
          student['full_name'] ?? '',
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          "رقم ولي الأمر: ${student['parent_phone'] ?? ''}",
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: "Cairo", fontSize: 11, color: Colors.grey.shade500),
        ),
        trailing: Text(
          "${student['score']}",
          style: TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage ?? "", textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Cairo", fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchLeaderboardData,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة", style: TextStyle(fontFamily: "Cairo")),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text("لا توجد سجلات تملأ لوحة الصدارة لهذه الفترة حالياً.", style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}