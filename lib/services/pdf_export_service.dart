import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import '../models/sale.dart';
import '../models/expense.dart';

class PdfExportService {
  static Future<File> generateDailyReport(
    DateTime date,
    List<Sale> sales,
    List<Expense> expenses,
    String businessName,
  ) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 20);
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    
    // Header
    graphics.drawString(
      'Daily Business Report',
      headerFont,
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    graphics.drawString(
      'Business: $businessName',
      titleFont,
      bounds: Rect.fromLTWH(0, 60, page.getClientSize().width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    graphics.drawString(
      'Date: ${_formatDate(date)}',
      normalFont,
      bounds: Rect.fromLTWH(0, 100, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    double yPosition = 140;
    
    // Sales Summary
    graphics.drawString(
      'SALES SUMMARY',
      titleFont,
      bounds: Rect.fromLTWH(50, yPosition, page.getClientSize().width - 100, 25),
    );
    
    yPosition += 30;
    
    final double totalSales = sales.fold(0, (sum, sale) => sum + sale.amount);
    graphics.drawString(
      'Total Sales: \$${totalSales.toStringAsFixed(2)}',
      normalFont,
      bounds: Rect.fromLTWH(50, yPosition, page.getClientSize().width - 100, 20),
    );
    
    yPosition += 25;
    
    // Sales Details
    for (var sale in sales) {
      graphics.drawString(
        '${_formatTime(sale.date)} - \$${sale.amount.toStringAsFixed(2)} (${sale.paymentMode})',
        normalFont,
        bounds: Rect.fromLTWH(70, yPosition, page.getClientSize().width - 140, 20),
      );
      yPosition += 20;
    }
    
    yPosition += 10;
    
    // Expenses Summary
    graphics.drawString(
      'EXPENSES SUMMARY',
      titleFont,
      bounds: Rect.fromLTWH(50, yPosition, page.getClientSize().width - 100, 25),
    );
    
    yPosition += 30;
    
    final double totalExpenses = expenses.fold(0, (sum, expense) => sum + expense.amount);
    graphics.drawString(
      'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
      normalFont,
      bounds: Rect.fromLTWH(50, yPosition, page.getClientSize().width - 100, 20),
    );
    
    yPosition += 25;
    
    // Expenses Details
    for (var expense in expenses) {
      graphics.drawString(
        '${_formatTime(expense.date)} - \$${expense.amount.toStringAsFixed(2)} (${expense.category})',
        normalFont,
        bounds: Rect.fromLTWH(70, yPosition, page.getClientSize().width - 140, 20),
      );
      yPosition += 20;
    }
    
    yPosition += 20;
    
    // Net Profit
    final double netProfit = totalSales - totalExpenses;
    graphics.drawString(
      'NET PROFIT: \$${netProfit.toStringAsFixed(2)}',
      titleFont,
      bounds: Rect.fromLTWH(50, yPosition, page.getClientSize().width - 100, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    // Save the document
    final List<int> bytes = await document.save();
    document.dispose();
    
    // Get external storage directory
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/daily_report_${_formatDateForFile(date)}.pdf');
    
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  static String _formatDateForFile(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}
