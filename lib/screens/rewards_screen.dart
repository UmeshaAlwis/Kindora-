import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Leader's Official Brand Colors
    const Color primaryBlue = Color(0xFF0C0C79);
    const Color primaryOrange = Color(0xFFFF751F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Blue Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: const BoxDecoration(
                color: primaryBlue, // Updated
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.trophy, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'Level 3 Helper',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '150 Points',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Badges',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A40),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FIX: Removed 'const' from children list to prevent compilation error
                  Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        FlippingBadge(label: 'First Gift', icon: LucideIcons.gift, color: Colors.orange, desc: 'First donation award!'),
                        FlippingBadge(label: 'Eco Warrior', icon: LucideIcons.leaf, color: Colors.green, desc: 'Saved the planet!'),
                        FlippingBadge(label: 'Top 10%', icon: LucideIcons.medal, color: Colors.blue, desc: 'Top monthly donor!'),
                        FlippingBadge(label: 'Village Hero', icon: LucideIcons.home, color: Colors.purple, desc: 'Helped 5+ villages!'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text('Progress to Level 4', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 15),
                  LinearPercentIndicator(
                    animation: true,
                    lineHeight: 18.0,
                    percent: 0.75,
                    center: const Text("75%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    barRadius: const Radius.circular(10),
                    progressColor: primaryOrange, // Updated
                    backgroundColor: Colors.grey[100],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlippingBadge extends StatefulWidget {
  final String label; final IconData icon; final Color color; final String desc;
  const FlippingBadge({super.key, required this.label, required this.icon, required this.color, required this.desc});
  @override State<FlippingBadge> createState() => _FlippingBadgeState();
}

class _FlippingBadgeState extends State<FlippingBadge> {
  bool _showFront = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFront = !_showFront),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(_showFront),
          width: MediaQuery.of(context).size.width * 0.4,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: _showFront ? _buildFront() : _buildBack(),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: widget.color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(widget.icon, color: widget.color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(widget.label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(widget.desc, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }
}