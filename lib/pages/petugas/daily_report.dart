import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import '../../core/constants/app_colors.dart';

class ReportPage extends StatelessWidget {
  final List loans;
  final List returns;

  const ReportPage({super.key, required this.loans, required this.returns});

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Daily Loan & Return Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Date: ${DateTime.now().toLocal()}'),
              pw.SizedBox(height: 16),

              pw.Text('Loans Today', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              ...loans.map(
                (l) => pw.Text(
                  '- ${l['NamaAlat']} | Qty: ${l['BanyakBarang']} | Status: ${l['Status']}',
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Text('Returns Today', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              ...returns.map((r) {
                final pengembalian = r['pengembalian_barang'];
                return pw.Text(
                  '- ${pengembalian?['NamaAlat'] ?? '-'} | Qty: ${pengembalian?['BanyakBarang'] ?? '-'}',
                );
              }),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _downloadPdf(Uint8List bytes) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        'Daily_Report_${DateTime.now().toIso8601String()}.pdf',
      )
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // tinggi AppBar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Back button di tengah kiri
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Teks di tengah
                Center(
                  child: Text(
                    'Daily Loan & Return Report',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Download PDF di tengah kanan
                Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<Uint8List>(
                    future: _generatePdfBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return IconButton(
                          icon: Icon(Icons.download, color: AppColors.primary),
                          onPressed: () => _downloadPdf(snapshot.data!),
                          tooltip: 'Download PDF',
                        );
                      }
                      return Container(width: 48); // placeholder
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Loans Today Section
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loans Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...loans.map(
                      (l) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          title: Text(l['NamaAlat']),
                          subtitle: Text(
                            'Qty: ${l['BanyakBarang']} | Status: ${l['Status']}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Returns Today Section
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Returns Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...returns.map((r) {
                      final pengembalian = r['pengembalian_barang'];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          title: Text(r['NamaAlat']),
                          subtitle: Text(
                            'Qty: ${r['BanyakBarang']} | Status: ${r['Status']}',
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
