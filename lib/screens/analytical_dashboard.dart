import 'package:flutter/material.dart';
import '../widgets/donut_chart.dart';
import '../widgets/info_card.dart';
import '../widgets/custom_appbar.dart';
import '../models/policy_model.dart';
import 'dashboard_screen.dart';

class AnalyticsDashboard extends StatelessWidget {
  final String customerName;
  final String customerId;

  const AnalyticsDashboard({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch policies from the model
    final policies = PolicyData.getSamplePolicies();

    // Calculate Summary Values
    final totalPolicies = policies.length;
    final totalProtection = policies
        .where((p) => p.status != PolicyStatus.expired)
        .fold(0.0, (sum, p) => sum + p.sumInsured);
    
    final expiringSoon = policies
        .where((p) => p.status == PolicyStatus.due)
        .length;

    // Calculate Chart Percentages
    // Assuming "percent" in DonutChart is the percentage of policies in that category
    // but the labels like "Secure" suggest it might be a health score or coverage level.
    // However, given the prompt "data in the dashboard page is not as per the data in the home page",
    // I will map these to the categories found in the home page.
    
    double getCategoryPercent(PolicyCategory category) {
      if (policies.isEmpty) return 0;
      final count = policies.where((p) => p.category == category).length;
      return (count / totalPolicies) * 100;
    }

    final lifePercent = getCategoryPercent(PolicyCategory.life);
    final healthPercent = getCategoryPercent(PolicyCategory.health);
    // Note: Other categories might exist, but we match the UI's 3 donuts
    // For "Vehicle Insurance", we check if there are any other categories or specifically motor
    final vehiclePercent = policies
        .where((p) => p.category == PolicyCategory.others || p.name.toLowerCase().contains('motor'))
        .length / totalPolicies * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF3),

      /// SAME APPBAR AS WELCOME PAGE
      appBar: CustomAppBar(
        customerName: customerName,
        customerId: customerId,
        onLogoTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(customerId: customerId),
            ),
            (route) => false,
          );
        },
      ),

      /// ================= BODY =================
      body: LayoutBuilder(
        builder: (context, constraints) {

          final width = constraints.maxWidth;
          final isMobile = width < 600;

          double donutSpacing;

          if (width > 1300) {
            donutSpacing = 80;
          } else if (width > 900) {
            donutSpacing = 60;
          } else {
            donutSpacing = 30;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 40,
              vertical: isMobile ? 16 : 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                const Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= DONUT SECTION =================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: isMobile ? 10 : 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(isMobile ? 12 : 20),
                    boxShadow: isMobile
                        ? []
                        : const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            )
                          ],
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: donutSpacing,
                    runSpacing: 40,
                    children: [
                      DonutChart(
                        title: "Life Insurance",
                        percent: lifePercent.toInt(),
                        label: lifePercent > 50 ? "Secure" : "Low",
                      ),
                      DonutChart(
                        title: "Health Insurance",
                        percent: healthPercent.toInt(),
                        label: healthPercent > 50 ? "Covered" : "Fair",
                      ),
                      DonutChart(
                        title: "Vehicle Insurance",
                        percent: vehiclePercent.toInt(),
                        label: vehiclePercent > 20 ? "Protected" : "Verify",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// ================= INFO CARDS (OVERFLOW PROOF) =================
                LayoutBuilder(
                  builder: (context, constraints) {

                    final width = constraints.maxWidth;
                    double cardWidth;

                    if (width > 1300) {
                      cardWidth = (width / 4) - 24;
                    }
                    else if (width > 900) {
                      cardWidth = (width / 2) - 20;
                    }
                    else {
                      cardWidth = width;
                    }

                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [

                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.description_outlined,
                            color: const Color(0xFF2E49B8),
                            title: "Policies Linked",
                            value: "$totalPolicies",
                            subtitle: "$expiringSoon expiring soon",
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.shield_outlined,
                            color: const Color(0xFF2E49B8),
                            title: "Total Protection",
                            value: "₹ ${_formatAmount(totalProtection)}",
                            subtitle: "sum of all insurance",
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: const InfoCard(
                            icon: Icons.warning_amber_outlined,
                            color: Color(0xFF2E49B8),
                            title: "Coverage Gap",
                            value: "₹ 50.0 L",
                            subtitle:
                                "to reach recommended levels",
                          ),
                        ),

                        SizedBox(
                          width: cardWidth,
                          child: InfoCard(
                            icon: Icons.bar_chart,
                            color: const Color(0xFF2E49B8),
                            title: "Risk Status",
                            value: expiringSoon > 0 ? "HIGH" : "LOW",
                            subtitle: "see insights",
                          ),
                        ),
                      ],
                    );
                  },
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  /// Amount Formatter (consistent with Home page)
  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
