import 'package:flutter/material.dart';
import 'dart:math';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  final Color primaryGreen = const Color(0xFF0F8241);
  final Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Detect if the screen is narrower than 850px (Mobile/Tablet view)
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 30),
          _buildStatCards(isMobile),
          const SizedBox(height: 30),
          _buildChartsSection(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    // Replaced Row with Wrap so the dropdown and button drop down on small screens
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 15,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports and Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Comprehensive statistics and insights', style: TextStyle(color: Colors.black54)),
          ],
        ),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'SY 2024-2025',
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                  onChanged: (val) {},
                  items: ['SY 2024-2025'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, color: Colors.white, size: 18),
              label: const Text('Export Report', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCards(bool isMobile) {
    // On mobile, create a 2x2 grid using Columns and Rows. On desktop, 1 row of 4.
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('Total Students', '32')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Enrollments', '7')),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _statCard('Documents', '123')),
              const SizedBox(width: 15),
              Expanded(child: _statCard('Completion Rates', '95.5%')),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _statCard('Total Students', '32')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Enrollments', '7')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Documents', '123')),
          const SizedBox(width: 20),
          Expanded(child: _statCard('Completion Rates', '95.5%')),
        ],
      );
    }
  }

  Widget _statCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isMobile) {
    // Stack charts vertically on mobile, side-by-side on desktop
    if (isMobile) {
      return Column(
        children: [
          _buildBarChartCard(),
          const SizedBox(height: 20),
          _buildPieChartCard(),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildBarChartCard()),
          const SizedBox(width: 20),
          Expanded(child: _buildPieChartCard()),
        ],
      );
    }
  }

  // NATIVE BAR CHART MOCKUP
  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Students by Grade Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          // Added a horizontal scroll view so bars don't squish on tiny phones
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 250,
              width: 500, // Enforce a minimum width so bars stay proportional
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _barItem('215', 'Grade 7', 215, Colors.red.shade400),
                  _barItem('198', 'Grade 8', 198, Colors.deepOrange.shade400),
                  _barItem('187', 'Grade 9', 187, Colors.orange.shade400),
                  _barItem('176', 'Grade 10', 176, Colors.amber.shade400),
                  _barItem('234', 'Grade 11', 234, Colors.lightGreen.shade400),
                  _barItem('237', 'Grade 12', 237, Colors.green.shade500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barItem(String value, String label, double heightVal, Color color) {
    double renderedHeight = heightVal * 0.8; 
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 5),
        Container(width: 40, height: renderedHeight, color: color),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  // NATIVE PIE CHART MOCKUP
  Widget _buildPieChartCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Rejected: 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 40), child: Text('Pending: 37', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 20),
          SizedBox(
            height: 220, width: 220,
            child: CustomPaint(painter: SimplePieChartPainter()),
          ),
          const SizedBox(height: 20),
          const Text('Verified: 519', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class SimplePieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final Paint paintRed = Paint()..color = Colors.red.shade500..style = PaintingStyle.fill;
    canvas.drawArc(rect, -pi / 2, 5.5, true, paintRed);
    
    final Paint paintOrange = Paint()..color = Colors.orange.shade500..style = PaintingStyle.fill;
    canvas.drawArc(rect, -pi / 2 + 5.5, 0.7, true, paintOrange);
    
    final Paint borderPaint = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawArc(rect, -pi / 2, 5.5, true, borderPaint);
    canvas.drawArc(rect, -pi / 2 + 5.5, 0.7, true, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}