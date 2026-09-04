import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:platform_text_recognition/platform_text_recognition.dart';
import 'package:printing/printing.dart';

void main() {
  runApp(const PdfMakerApp());
}

class PdfMakerApp extends StatelessWidget {
  const PdfMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFF7F4EE);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D8064)),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: Color(0xFF1C2521),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE4E5DF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _createDocument(BuildContext context) async {
    final type = await showModalBottomSheet<DocumentType>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => const DocumentTypeSheet(),
    );
    if (!context.mounted || type == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DocumentSetupPage(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maker',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Fikirden kağıda.',
              style: theme.textTheme.displaySmall?.copyWith(
                color: const Color(0xFF1C2521),
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fotoğrafını çek, içeriğini düzenle, hazırla ve paylaş.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF59645F),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFF1D8064),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFB9E6D3),
                      size: 28,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Yeni bir belge\nhazırlamaya başla',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _createDocument(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Belge oluştur'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB9E6D3),
                        foregroundColor: const Color(0xFF17352B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Belgelerim',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Tümünü gör')),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F3ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1D8064),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Henüz belgen yok',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'İlk sınavını veya ders föyünü burada oluşturabilirsin.',
                      textAlign: TextAlign.center,
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
}

enum DocumentType { exam, handout }

class DocumentTypeSheet extends StatelessWidget {
  const DocumentTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ne hazırlıyorsun?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _TypeOption(
            type: DocumentType.exam,
            onTap: () => Navigator.pop(context, DocumentType.exam),
          ),
          const SizedBox(height: 12),
          _TypeOption(
            type: DocumentType.handout,
            onTap: () => Navigator.pop(context, DocumentType.handout),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({required this.type, required this.onTap});

  final DocumentType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExam = type == DocumentType.exam;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E5DF)),
      ),
      leading: Icon(
        isExam ? Icons.fact_check_outlined : Icons.menu_book_outlined,
        size: 30,
        color: const Color(0xFF1D8064),
      ),
      title: Text(
        isExam ? 'Sınav' : 'Ders föyü',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        isExam
            ? 'Soruları sırala ve puanlandır'
            : 'Konu anlatımı ve görselleri düzenle',
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}

class DocumentSetupPage extends StatefulWidget {
  const DocumentSetupPage({required this.type, super.key});

  final DocumentType type;

  @override
  State<DocumentSetupPage> createState() => _DocumentSetupPageState();
}

class _DocumentSetupPageState extends State<DocumentSetupPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExam = widget.type == DocumentType.exam;
    return Scaffold(
      appBar: AppBar(title: Text(isExam ? 'Yeni sınav' : 'Yeni ders föyü')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isExam ? 'Belge bilgileri' : 'Föy bilgileri',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: isExam ? 'Sınav başlığı' : 'Föy başlığı',
              hintText: 'Örn. 8. sınıf matematik',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: isExam ? 'Ders ve sınıf' : 'Konu',
              hintText: isExam ? 'Örn. Matematik - 8/A' : 'Örn. Üçgenler',
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ContentCapturePage(
                    type: widget.type,
                    title: _titleController.text.trim().isEmpty
                        ? (isExam ? 'Yeni sınav' : 'Yeni ders föyü')
                        : _titleController.text.trim(),
                    subtitle: _subtitleController.text.trim(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('İçerik eklemeye geç'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kamera veya galeriden sayfa ekleyerek başlayabilirsin.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ContentCapturePage extends StatefulWidget {
  const ContentCapturePage({
    required this.type,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final DocumentType type;
  final String title;
  final String subtitle;

  @override
  State<ContentCapturePage> createState() => _ContentCapturePageState();
}

class _ContentCapturePageState extends State<ContentCapturePage> {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();
  final List<XFile> _pages = [];
  final Map<int, String> _ocrText = {};
  final Map<int, XFile> _figures = {};
  int? _recognizingPage;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickPage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 90);
    if (!mounted || image == null) return;
    final cropped = await _cropper.cropImage(
      sourcePath: image.path,
      compressQuality: 92,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Sayfayı kırp',
          toolbarColor: const Color(0xFF1D8064),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF1D8064),
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Sayfayı kırp'),
      ],
    );
    if (!mounted || cropped == null) return;
    setState(() => _pages.add(XFile(cropped.path)));
  }

  Future<void> _recognizePage(int index) async {
    setState(() => _recognizingPage = index);
    try {
      final text = await PlatformTextRecognizer.instance.recognizeText(
        _pages[index].path,
        script: TextRecognitionScript.latin,
        languages: const ['tr-TR'],
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OcrEditorPage(
            pageNumber: index + 1,
            imagePath: _pages[index].path,
            initialText: text,
            onSave: (value) => _ocrText[index] = value,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _recognizingPage = null);
    }
  }

  Future<void> _cropFigure(int index) async {
    final cropped = await _cropper.cropImage(
      sourcePath: _pages[index].path,
      compressQuality: 92,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Şekli kırp',
          toolbarColor: const Color(0xFF1D8064),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF1D8064),
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Şekli kırp'),
      ],
    );
    if (!mounted || cropped == null) return;
    setState(() => _figures[index] = XFile(cropped.path));
  }

  @override
  Widget build(BuildContext context) {
    final isExam = widget.type == DocumentType.exam;
    return Scaffold(
      appBar: AppBar(
        title: Text(isExam ? 'Sınav içeriği' : 'Föy içeriği'),
        actions: [
          if (_pages.isNotEmpty)
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DocumentPreviewPage(
                    type: widget.type,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    pages: _pages,
                    ocrText: _ocrText,
                    figures: _figures,
                  ),
                ),
              ),
              tooltip: 'Belgeyi önizle',
              icon: const Icon(Icons.preview_outlined),
            ),
        ],
      ),
      body: _pages.isEmpty
          ? _EmptyCaptureState(
              onCamera: () => _pickPage(ImageSource.camera),
              onGallery: () => _pickPage(ImageSource.gallery),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  'Sayfalar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_pages.length} sayfa eklendi. Sıralama ve OCR adımı sırada.',
                ),
                const SizedBox(height: 18),
                ..._pages.asMap().entries.map(
                  (entry) => Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.file(
                          File(entry.value.path),
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            child: Text('${entry.key + 1}'),
                          ),
                          title: Text('Sayfa ${entry.key + 1}'),
                          subtitle: _ocrText.containsKey(entry.key)
                              ? Text(
                                  _figures.containsKey(entry.key)
                                      ? 'Metin ve şekil hazır'
                                      : 'OCR metni düzenlendi',
                                )
                              : null,
                          trailing: IconButton(
                            onPressed: () =>
                                setState(() => _pages.removeAt(entry.key)),
                            tooltip: 'Sayfayı kaldır',
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _recognizingPage == entry.key
                                      ? null
                                      : () => _recognizePage(entry.key),
                                  icon: _recognizingPage == entry.key
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.text_fields_rounded),
                                  label: Text(
                                    _recognizingPage == entry.key
                                        ? 'Metin çıkarılıyor'
                                        : 'Metni çıkar',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _cropFigure(entry.key),
                                tooltip: 'Şekli kırp',
                                icon: const Icon(Icons.crop_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickPage(ImageSource.gallery),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Galeriden sayfa ekle'),
                ),
              ],
            ),
    );
  }
}

class DocumentPreviewPage extends StatelessWidget {
  const DocumentPreviewPage({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.pages,
    required this.ocrText,
    required this.figures,
    super.key,
  });

  final DocumentType type;
  final String title;
  final String subtitle;
  final List<XFile> pages;
  final Map<int, String> ocrText;
  final Map<int, XFile> figures;

  Future<void> _exportPdf() async {
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final document = pw.Document();
    for (final entry in pages.asMap().entries) {
      final figure = figures[entry.key];
      final figureImage = figure == null
          ? null
          : pw.MemoryImage(await File(figure.path).readAsBytes());
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 20)),
              if (subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(subtitle, style: pw.TextStyle(font: regularFont)),
              ],
              pw.SizedBox(height: 16),
              if (ocrText[entry.key]?.isNotEmpty == true) ...[
                pw.Text(
                  ocrText[entry.key]!,
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
                if (figureImage != null) pw.SizedBox(height: 16),
              ],
              if (figureImage != null)
                pw.Center(child: pw.Image(figureImage, fit: pw.BoxFit.contain)),
            ],
          ),
        ),
      );
    }
    await Printing.layoutPdf(onLayout: (_) => document.save());
  }

  @override
  Widget build(BuildContext context) {
    final isExam = type == DocumentType.exam;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belge önizleme'),
        actions: [
          IconButton(
            onPressed: _exportPdf,
            tooltip: 'PDF olarak dışa aktar',
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF59645F))),
          ],
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFE8F3ED),
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(isExam ? 'Sınav taslağı hazır' : 'Föy taslağı hazır'),
              subtitle: Text('${pages.length} sayfa içerik eklendi'),
            ),
          ),
          const SizedBox(height: 18),
          ...pages.asMap().entries.map(
            (entry) => Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ocrText[entry.key]?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(ocrText[entry.key]!),
                    ),
                  if (figures[entry.key] != null)
                    Image.file(
                      File(figures[entry.key]!.path),
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                ],
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF olarak dışa aktar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class OcrEditorPage extends StatefulWidget {
  const OcrEditorPage({
    required this.pageNumber,
    required this.imagePath,
    required this.initialText,
    required this.onSave,
    super.key,
  });

  final int pageNumber;
  final String imagePath;
  final String initialText;
  final ValueChanged<String> onSave;

  @override
  State<OcrEditorPage> createState() => _OcrEditorPageState();
}

class _OcrEditorPageState extends State<OcrEditorPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_controller.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sayfa ${widget.pageNumber} metni'),
        actions: [
          IconButton(
            onPressed: _save,
            tooltip: 'Metni kaydet',
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(widget.imagePath),
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'OCR metni',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 8,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Metin bulunamadıysa buraya kendin yazabilirsin.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Metni kaydet'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Formül, tablo veya şekiller bozulursa sayfayı görsel olarak kullanmaya devam edebilirsin.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyCaptureState extends StatelessWidget {
  const _EmptyCaptureState({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: Color(0xFF1D8064),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'İlk sayfanı ekle',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kitap veya çalışma kağıdını fotoğraflayabilir ya da galeriden seçebilirsin.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamerayla çek'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeriden seç'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
