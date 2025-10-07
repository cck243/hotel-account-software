import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../providers/expense_provider.dart';
import '../services/pdf_export_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Business Reports'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Selector
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: ['Daily', 'Weekly', 'Monthly'].map((period) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(period),
                              selected: _selectedPeriod == period,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Financial Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSummaryRow('Total Sales', salesProvider.monthlySales, Colors.green),
                    _buildSummaryRow('Total Expenses', expenseProvider.monthlyExpenses, Colors.red),
                    _buildSummaryRow(
                      'Net Profit', 
                      salesProvider.monthlySales - expenseProvider.monthlyExpenses, 
                      Colors.blue
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Expense Categories Chart
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Expense Categories (This Month)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: charts.BarChart(
                        _createExpenseChartData(expenseProvider.topExpenseCategories),
                        animate: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14)),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<charts.Series<MapEntry<String, double>, String>> _createExpenseChartData(
      Map<String, double> expenseData) {
    final data = expenseData.entries.toList();

    return [
      charts.Series<MapEntry<String, double>, String>(
        id: 'Expenses',
        domainFn: (entry, _) => entry.key,
        measureFn: (entry, _) => entry.value,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        labelAccessorFn: (entry, _) => '\$${entry.value.toStringAsFixed(0)}',
      )
    ];
  }

  void _exportReport(BuildContext context) async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    try {
      final file = await PdfExportService.generateDailyReport(
        DateTime.now(),
        salesProvider.sales,
        expenseProvider.expenses,
        'My Business', // Replace with actual business name
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported successfully!')),
      );
      
      // You can add functionality to open the file or share it
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting report: $e')),
      );
    }
  }
}
