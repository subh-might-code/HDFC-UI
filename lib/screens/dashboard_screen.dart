import 'package:flutter/material.dart';
import '../models/policy_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/policy_card.dart';

class DashboardScreen extends StatefulWidget {
  final String customerId;

  const DashboardScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PolicyCategory _selectedCategory = PolicyCategory.all;
  final List<Policy> _allPolicies = PolicyData.getSamplePolicies();

  List<Policy> get _filteredPolicies {
    List<Policy> filtered;

    if (_selectedCategory == PolicyCategory.all) {
      filtered = List.from(_allPolicies);
    } else {
      filtered = _allPolicies
          .where((policy) => policy.category == _selectedCategory)
          .toList();
    }

    filtered.sort((a, b) {
      int getPriority(PolicyStatus status) {
        switch (status) {
          case PolicyStatus.due:
            return 0;
          case PolicyStatus.active:
            return 1;
          case PolicyStatus.expired:
            return 2;
        }
      }

      return getPriority(a.status).compareTo(getPriority(b.status));
    });

    return filtered;
  }

  double get _totalAnnualPremium =>
      _allPolicies.fold(0, (sum, p) => sum + p.annualPremium);

  double get _totalCoverage =>
      _allPolicies.fold(0, (sum, p) => sum + p.sumInsured);

  @override
  Widget build(BuildContext context) {
    final filteredPolicies = _filteredPolicies;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return Scaffold(
          backgroundColor: AppTheme.backgroundGrey,

          appBar: CustomAppBar(
            customerName: 'Hrisheekesh Rabha',
            customerId: widget.customerId,
            onLogoTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      DashboardScreen(customerId: widget.customerId),
                ),
                (route) => false,
              );
            },
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// Welcome Text
                  Text(
                    'Welcome back, Hrisheekesh Rabha!',
                    style: isMobile
                        ? Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)
                        : Theme.of(context).textTheme.headlineLarge,
                  ),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// SUMMARY CARDS
                  _buildSummaryCards(constraints.maxWidth),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// CATEGORY FILTER
                  CategoryFilter(
                    maxWidth: constraints.maxWidth,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),

                  /// POLICY GRID (FIXED)
                  _buildPolicyGrid(constraints.maxWidth, filteredPolicies),

                  SizedBox(height: isMobile ? AppTheme.spacing16 : AppTheme.spacing24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ================= SUMMARY CARDS =================
  Widget _buildSummaryCards(double maxWidth) {
    final cards = [
      SummaryCard(
        icon: Icons.description_outlined,
        title: 'Total Policies',
        value: '${_allPolicies.length}',
      ),
      SummaryCard(
        icon: Icons.currency_rupee,
        title: 'Annual Premium',
        value: '₹ ${_formatAmount(_totalAnnualPremium)}',
        subtitle: 'Across all Policies',
      ),
      SummaryCard(
        icon: Icons.shield_outlined,
        title: 'Total Coverage',
        value: '₹ ${_formatAmount(_totalCoverage)}',
        subtitle: 'Sum assured amount',
      ),
    ];

    if (maxWidth < 650) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  child: card,
                ))
            .toList(),
      );
    } else {
      // Use Row with IntrinsicHeight to make all cards equal size
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cards.map((card) {
            return Expanded(
              child: card,
            );
          }).toList()
          .expand((widget) => [widget, const SizedBox(width: AppTheme.spacing16)])
          .toList()..removeLast(), // Interleave with spacing
        ),
      );
    }
  }

  /// ================= POLICY GRID (OVERFLOW FIXED) =================
  Widget _buildPolicyGrid(double maxWidth, List<Policy> filteredPolicies) {
    int crossAxisCount;
    double childAspectRatio;

    if (maxWidth > 1400) {
      crossAxisCount = 4;
      childAspectRatio = 2.0;
    } 
    else if (maxWidth > 1100) {
      crossAxisCount = 3;
      childAspectRatio = 1.9;
    } 
    else if (maxWidth > 750) {
      crossAxisCount = 2;
      childAspectRatio = 2.0;
    } 
    else {
      crossAxisCount = 1;
      childAspectRatio = 2.1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: filteredPolicies.length,
      itemBuilder: (context, index) {
        return PolicyCard(policy: filteredPolicies[index]);
      },
    );
  }

  /// Amount Formatter
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
