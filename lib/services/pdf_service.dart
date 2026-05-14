import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/incident_model.dart';
import '../models/worker_model.dart';
import '../models/helmet_model.dart';

class PdfService {
  Future<void> exportReport({
    required List<Incident> incidents,
    required List<Worker> workers,
    required List<Helmet> helmets,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final openCount =
        incidents.where((i) => i.status.toLowerCase() == 'open').length;
    final inProgressCount =
        incidents.where((i) => i.status.toLowerCase() == 'in progress').length;
    final resolvedCount =
        incidents.where((i) => i.status.toLowerCase() == 'resolved').length;
    final onlineWorkers =
        workers.where((w) => w.status.toLowerCase() == 'online').length;
    final activeHelmets =
        helmets.where((h) => h.status.toLowerCase() == 'active').length;
    final lowBattery =
        helmets.where((h) => h.battery != null && h.battery! < 20).length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Smart Helmet Safety Report',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated: $dateStr',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'CONFIDENTIAL',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.teal700, thickness: 2),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Smart Helmet System — Confidential',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
                pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        build: (context) => [
          // --- Safety Overview ---
          pw.Text('Safety Overview',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _statBox('Workers Online', '$onlineWorkers / ${workers.length}',
                PdfColors.blue700),
            pw.SizedBox(width: 12),
            _statBox('Active Helmets', '$activeHelmets / ${helmets.length}',
                PdfColors.green700),
            pw.SizedBox(width: 12),
            _statBox('Low Battery', '$lowBattery helmets', PdfColors.orange700),
            pw.SizedBox(width: 12),
            _statBox(
                'Total Incidents', incidents.length.toString(), PdfColors.red700),
          ]),
          pw.SizedBox(height: 16),

          // --- Incident Breakdown ---
          pw.Text('Incident Breakdown',
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _statBox('Open', openCount.toString(), PdfColors.red700),
            pw.SizedBox(width: 12),
            _statBox('In Progress', inProgressCount.toString(),
                PdfColors.orange700),
            pw.SizedBox(width: 12),
            _statBox('Resolved', resolvedCount.toString(), PdfColors.green700),
          ]),
          pw.SizedBox(height: 20),

          // --- Incidents Table ---
          if (incidents.isNotEmpty) ...[
            pw.Text('Incident History',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Title', 'Worker', 'Status', 'Time'],
              data: incidents
                  .map((i) => [i.title, i.workerName, i.status, i.time])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.teal700),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
            pw.SizedBox(height: 20),
          ],

          // --- Worker Status Table ---
          if (workers.isNotEmpty) ...[
            pw.Text('Worker Status Summary',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'Name',
                'ID',
                'Status',
                'Heart Rate',
                'Oxygen',
                'Body Temp'
              ],
              data: workers
                  .map((w) => [
                        w.name,
                        w.id,
                        w.status,
                        w.heartRate != null ? '${w.heartRate} bpm' : 'N/A',
                        w.oxygenLevel != null ? '${w.oxygenLevel}%' : 'N/A',
                        w.bodyTemperature != null
                            ? '${w.bodyTemperature!.toStringAsFixed(1)}°C'
                            : 'N/A',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.teal700),
              cellStyle: const pw.TextStyle(fontSize: 10),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
            pw.SizedBox(height: 20),
          ],

          // --- Helmet Status Table ---
          if (helmets.isNotEmpty) ...[
            pw.Text('Helmet Status Summary',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'Helmet ID',
                'Status',
                'Battery',
                'Assigned To',
                'Helmet Temp',
              ],
              data: helmets
                  .map((h) => [
                        h.id,
                        h.status,
                        h.battery != null ? '${h.battery}%' : 'N/A',
                        h.workerName ?? 'Unassigned',
                        h.helmetTemperature != null
                            ? '${h.helmetTemperature!.toStringAsFixed(1)}°C'
                            : 'N/A',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.teal700),
              cellStyle: const pw.TextStyle(fontSize: 10),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'smart_helmet_report_${now.year}${now.month}${now.day}.pdf',
    );
  }

  pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
