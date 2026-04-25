import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  PdfService._();

  // ─── Fonts ────────────────────────────────────────────────
  static pw.Font? _regular;
  static pw.Font? _medium;
  static pw.Font? _bold;

  // ─── Colors ───────────────────────────────────────────────
  static const _navy = PdfColor.fromInt(0xFF1B2A4A);
  static const _gold = PdfColor.fromInt(0xFFC9A84C);
  static const _success = PdfColor.fromInt(0xFF4CAF50);
  static const _error = PdfColor.fromInt(0xFFEF4444);
  static const _pending = PdfColor.fromInt(0xFFF59E0B);
  static const _grey = PdfColor.fromInt(0xFF6B7280);
  static const _lightGrey = PdfColor.fromInt(0xFFF5F4F0);
  static const _divider = PdfColor.fromInt(0xFFEEEEEE);

  // ─── Fonts ────────────────────────────────────────────────
  static Future<void> _loadFonts() async {
    if (_regular != null) return; // محمّل مسبقاً

    final regular = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');

    _regular = pw.Font.ttf(regular);
    _bold = pw.Font.ttf(bold);
  }

  // ═══════════════════════════════════════════════════════════
  // Generate Daily Report PDF
  // ═══════════════════════════════════════════════════════════
  static Future<void> generateDailyReport({
    required DateTime fromDate,
    required DateTime toDate,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> incomingTransfers,
    required List<Map<String, dynamic>> outgoingTransfers,
    required String storeName,
  }) async {
    // ✅ حمّل الخط أولاً
    await _loadFonts();

    final pdf = pw.Document();

    // ✅ Theme عام للـ PDF
    final theme = pw.ThemeData.withFont(
      base: _regular!,
      bold: _bold!,
      italic: _regular!,
      boldItalic: _bold!,
    );

    // حساب الإجماليات
    final totalPayments = payments.fold(
      0.0,
      (sum, p) => sum + (p['amount'] as num).toDouble(),
    );
    final totalIncoming = incomingTransfers
        .where((t) => t['status'] == 'received')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
    final totalPending = incomingTransfers
        .where((t) => t['status'] == 'pending')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
    final totalOutgoing = outgoingTransfers.fold(
      0.0,
      (sum, o) => sum + (o['amount'] as num).toDouble(),
    );
    final netTotal = totalPayments + totalIncoming - totalOutgoing;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: theme, // ✅ مرر الـ theme هون
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(storeName, fromDate, toDate),
          pw.SizedBox(height: 20),
          _buildSummaryRow(
            totalPayments: totalPayments,
            totalIncoming: totalIncoming,
            totalOutgoing: totalOutgoing,
            totalPending: totalPending,
            netTotal: netTotal,
          ),
          pw.SizedBox(height: 24),
          if (payments.isNotEmpty) ...[
            _buildSectionTitle('المدفوعات', Icons.payment),
            pw.SizedBox(height: 8),
            _buildPaymentsTable(payments),
            pw.SizedBox(height: 20),
          ],
          if (incomingTransfers.isNotEmpty) ...[
            _buildSectionTitle('الحوالات الواردة', Icons.arrow_downward),
            pw.SizedBox(height: 8),
            _buildIncomingTable(incomingTransfers),
            pw.SizedBox(height: 20),
          ],
          if (outgoingTransfers.isNotEmpty) ...[
            _buildSectionTitle(
              'المصروفات والحوالات الصادرة',
              Icons.arrow_upward,
            ),
            pw.SizedBox(height: 8),
            _buildOutgoingTable(outgoingTransfers),
            pw.SizedBox(height: 20),
          ],
          _buildFooter(netTotal),
        ],
      ),
    );

    await _saveAndOpen(pdf, fromDate, toDate);
  }

  // ─── Header ───────────────────────────────────────────────
  static pw.Widget _buildHeader(String storeName, DateTime from, DateTime to) {
    final isSingleDay = _isSameDay(from, to);
    final dateLabel = isSingleDay
        ? _formatDate(from)
        : '${_formatDate(from)} — ${_formatDate(to)}';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                dateLabel,
                style: pw.TextStyle(
                  font: _bold,
                  color: PdfColors.white,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'تقرير يومي',
                style: pw.TextStyle(font: _bold, color: _gold, fontSize: 13),
              ),
            ],
          ),
          pw.Text(
            storeName,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary Row ──────────────────────────────────────────
  static pw.Widget _buildSummaryRow({
    required double totalPayments,
    required double totalIncoming,
    required double totalOutgoing,
    required double totalPending,
    required double netTotal,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            _summaryCard('المدفوعات', totalPayments, _gold),
            pw.SizedBox(width: 8),
            _summaryCard('الواردة', totalIncoming, _success),
            pw.SizedBox(width: 8),
            _summaryCard('الصادرة', totalOutgoing, _error),
            pw.SizedBox(width: 8),
            _summaryCard('معلقة', totalPending, _pending),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: pw.BoxDecoration(
            color: netTotal >= 0
                ? PdfColor.fromInt(0xFFE8F5E9)
                : PdfColor.fromInt(0xFFFFEBEE),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(
              color: netTotal >= 0 ? _success : _error,
              width: 0.5,
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${netTotal >= 0 ? '+' : ''}${netTotal.toStringAsFixed(2)} ₪',
                style: pw.TextStyle(
                  font: _bold,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: netTotal >= 0 ? _success : _error,
                ),
              ),
              pw.Text(
                'الصافي الكلي',
                style: pw.TextStyle(
                  font: _bold,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryCard(String label, double amount, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _lightGrey,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(font: _regular, fontSize: 9, color: _grey),
            ), // ✅
            pw.SizedBox(height: 4),
            pw.Text(
              '${amount.toStringAsFixed(2)} ₪',
              style: pw.TextStyle(
                font: _bold, // ✅
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Title ────────────────────────────────────────
  static pw.Widget _buildSectionTitle(String title, IconData icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: _bold,
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Payments Table ───────────────────────────────────────
  static pw.Widget _buildPaymentsTable(List<Map<String, dynamic>> payments) {
    return pw.Table(
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _lightGrey),
          children: [
            _tableHeader('الوقت'),
            _tableHeader('الحساب'),
            _tableHeader('المبلغ'),
            _tableHeader('الزبون'),
          ],
        ),
        // Rows
        ...payments.map(
          (p) => pw.TableRow(
            children: [
              _tableCell(_formatTime(p['createdAt'])),
              _tableCell(p['accountName'] ?? ''),
              _tableCell(
                '${(p['amount'] as num).toStringAsFixed(2)} ₪',
                color: _gold,
                bold: true,
              ),
              _tableCell(p['customerName'] ?? ''),
            ],
          ),
        ),
        // Total Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFBEB)),
          children: [
            _tableCell(''),
            _tableCell('الإجمالي', bold: true, color: _navy),
            _tableCell(
              '${payments.fold(0.0, (s, p) => s + (p['amount'] as num).toDouble()).toStringAsFixed(2)} ₪',
              bold: true,
              color: _gold,
            ),
            _tableCell(''),
          ],
        ),
      ],
    );
  }

  // ─── Incoming Transfers Table ─────────────────────────────
  static pw.Widget _buildIncomingTable(List<Map<String, dynamic>> transfers) {
    return pw.Table(
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _lightGrey),
          children: [
            _tableHeader('الحساب'),
            _tableHeader('المرجع'),
            _tableHeader('المبلغ'),
            _tableHeader('المُحوِّل'),
            _tableHeader('الحالة'),
          ],
        ),
        // Rows
        ...transfers.map((t) {
          final isReceived = t['status'] == 'received';
          return pw.TableRow(
            children: [
              _tableCell(t['accountName'] ?? ''),
              _tableCell(t['referenceNumber'] ?? ''),
              _tableCell(
                '${(t['amount'] as num).toStringAsFixed(2)} ₪',
                color: _success,
                bold: true,
              ),
              _tableCell(t['senderName'] ?? ''),
              _statusCell(isReceived),
            ],
          );
        }),
      ],
    );
  }

  // ─── Outgoing Transfers Table ─────────────────────────────
  static pw.Widget _buildOutgoingTable(List<Map<String, dynamic>> outgoing) {
    return pw.Table(
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _lightGrey),
          children: [
            _tableHeader('الحساب'),
            _tableHeader('التصنيف'),
            _tableHeader('المبلغ'),
            _tableHeader('المستلم'),
          ],
        ),
        // Rows
        ...outgoing.map(
          (o) => pw.TableRow(
            children: [
              _tableCell(o['accountName'] ?? ''),
              _tableCell(_categoryLabel(o['category'] ?? '')),
              _tableCell(
                '${(o['amount'] as num).toStringAsFixed(2)} ₪',
                color: _error,
                bold: true,
              ),
              _tableCell(o['recipientName'] ?? ''),
            ],
          ),
        ),
        // Total
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFEBEE)),
          children: [
            _tableCell(''),
            _tableCell('الإجمالي', bold: true, color: _navy),
            _tableCell(
              '${outgoing.fold(0.0, (s, o) => s + (o['amount'] as num).toDouble()).toStringAsFixed(2)} ₪',
              bold: true,
              color: _error,
            ),
            _tableCell(''),
          ],
        ),
      ],
    );
  }

  // ─── Footer ───────────────────────────────────────────────
  static pw.Widget _buildFooter(double netTotal) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _divider, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'تم الإنشاء: ${DateFormat('dd/MM/yyyy – hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9, color: _grey),
          ),
          pw.Text(
            'مكتبة ومطبعة دار المقداد',
            style: pw.TextStyle(
              font: _medium,
              fontSize: 9,
              color: _navy,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Table Helpers ────────────────────────────────────────
  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: _bold, // ✅
          fontSize: 10,
          color: _navy,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    PdfColor? color,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: bold ? _bold : _regular, // ✅
          fontSize: 9,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _statusCell(bool isReceived) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          color: isReceived
              ? PdfColor.fromInt(0xFFE8F5E9)
              : PdfColor.fromInt(0xFFFFF8E1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          isReceived ? 'واصلة' : 'معلقة',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: _medium,
            fontSize: 8,
            color: isReceived ? _success : _pending,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── Utils ────────────────────────────────────────────────
  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }

  static String _categoryLabel(String category) {
    switch (category) {
      case 'supplies':
        return 'مستلزمات';
      case 'bills':
        return 'فواتير';
      case 'salaries':
        return 'رواتب';
      default:
        return 'أخرى';
    }
  }

  // ─── Save & Open ──────────────────────────────────────────
  static Future<void> _saveAndOpen(
    pw.Document pdf,
    DateTime from,
    DateTime to,
  ) async {
    final bytes = await pdf.save();

    // Request permission
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final fileName = _isSameDay(from, to)
        ? 'report_${DateFormat('dd-MM-yyyy').format(from)}.pdf'
        : 'report_${DateFormat('dd-MM-yyyy').format(from)}_to_${DateFormat('dd-MM-yyyy').format(to)}.pdf';

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Open file
    await OpenFile.open(file.path);
  }
}
