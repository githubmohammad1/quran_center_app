import 'package:flutter/material.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class StudentDashboardContent extends StatelessWidget {
  final String title;
  final String headerName;
  final dynamic progress;
  final PersonModel? profile;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onNotificationPressed;
  final VoidCallback onAttendancePressed;
  final VoidCallback onTestsPressed;
  final VoidCallback onProgressPressed;
  final VoidCallback onQrPressed;
  final Widget? drawer;

  const StudentDashboardContent({
    super.key,
    required this.title,
    required this.headerName,
    required this.progress,
    required this.profile,
    required this.isLoading,
    required this.onRefresh,
    required this.onNotificationPressed,
    required this.onAttendancePressed,
    required this.onTestsPressed,
    required this.onProgressPressed,
    required this.onQrPressed,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: onNotificationPressed,
          ),
        ],
      ),
      drawer: drawer,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(headerName),
              const SizedBox(height: 25),
              Text("التقدم الحالي", style: _headerStyle()),
              const SizedBox(height: 12),
              _buildStatsGrid(progress),
              const SizedBox(height: 30),
              Text("الخدمات والتقارير", style: _headerStyle()),
              const SizedBox(height: 12),
              _buildActionGrid(),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle() => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo");

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigo.shade400]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("مرحباً بك،", style: TextStyle(color: Colors.white70, fontFamily: "Cairo")),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard("Pages Memorized", "${progress?.totalPagesMemorized ?? 0}", Icons.menu_book, Colors.blue),
        _statCard("Total Points", "${progress?.points ?? 0}", Icons.stars, Colors.orange),
        _statCard("Parts Tested", "${progress?.totalPartsTested ?? 0}", Icons.fact_check, Colors.green),
        _statCard("Surahs Tested", "${progress?.totalSurahsTested ?? 0}", Icons.auto_stories, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "Cairo")),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: "Cairo")),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      children: [
        _actionItem("Attendance", Icons.calendar_month, onAttendancePressed),
        _actionItem("Tests", Icons.quiz, onTestsPressed),
        _actionItem("Progress", Icons.trending_up, onProgressPressed),
        _actionItem("Digital QR", Icons.qr_code, onQrPressed),
      ],
    );
  }

  Widget _actionItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.indigo.withOpacity(0.1),
            child: Icon(icon, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontFamily: "Cairo")),
        ],
      ),
    );
  }
}