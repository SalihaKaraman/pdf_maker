import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:platform_text_recognition/platform_text_recognition.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _draftsKey = 'maker_drafts';

Future<void> saveDraft({
  required String title,
  required String subtitle,
  required DocumentType type,
  required Iterable<String> questions,
}) async {
  final preferences = await SharedPreferences.getInstance();
  final drafts = preferences.getStringList(_draftsKey) ?? <String>[];
  final draft = jsonEncode({
    'title': title,
    'subtitle': subtitle,
    'type': type.name,
    'questions': questions.toList(),
    'savedAt': DateTime.now().toIso8601String(),
  });
  drafts.removeWhere((item) => jsonDecode(item)['title'] == title);
  drafts.insert(0, draft);
  await preferences.setStringList(_draftsKey, drafts.take(10).toList());
}

String formatMathForOutput(String value) {
  const superscripts = {
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
  };
  var result = value.replaceAllMapped(
    RegExp(r'\^([0-9]+)'),
    (match) =>
        match.group(1)!.split('').map((char) => superscripts[char]).join(),
  );
  result = result.replaceAllMapped(
    RegExp(r'log_([0-9]+)'),
    (match) =>
        'log${match.group(1)!.split('').map((char) => superscripts[char]).join()}',
  );
  return result.replaceAll('sqrt(', '√(');
}

void main() => runApp(const PdfMakerApp());

class PdfMakerApp extends StatelessWidget {
  const PdfMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFF3F3F0);
    const ink = Color(0xFF1C1C1A);
    const muted = Color(0xFF68655F);
    const accent = Color(0xFFB5472B);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: accent),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          elevation: 0,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
          fontFamily: 'Georgia',
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFDDD8CF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8F6F1),
          labelStyle: TextStyle(color: muted, fontFamily: 'sans-serif'),
          hintStyle: TextStyle(color: muted, fontFamily: 'sans-serif'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFDDD8CF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFDDD8CF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ink,
            side: const BorderSide(color: Color(0xFFDDD8CF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

enum DocumentType { exam, handout }

enum PageStyle { exam, book }

enum ImagePosition { above, left, right }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_draftsKey) ?? <String>[];
    if (!mounted) return;
    setState(() {
      _drafts = stored
          .map((item) => jsonDecode(item))
          .whereType<Map<String, dynamic>>()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Tema ayarları',
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            'Soru & Konu PDF Hazırlayıcı',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fotoğraf çek / galeriden seç → düzenle → PDF indir',
            style: TextStyle(
              color: Color(0xFF68655F),
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Öğe Ekle',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final type = await showModalBottomSheet<DocumentType>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => const DocumentTypeSheet(),
                      );
                      if (!context.mounted || type == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentSetupPage(type: type),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Belge oluştur'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sınav veya konu anlatımı seçerek soru ve görselleri tek tek ekleyebilirsin.',
                    style: TextStyle(
                      color: Color(0xFF68655F),
                      fontFamily: 'sans-serif',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Öğeler / Taslaklar',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (_drafts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: Text(
                    'Henüz belgen yok',
                    style: TextStyle(
                      color: Color(0xFF68655F),
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ),
            )
          else
            ..._drafts.map(
              (draft) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFFB5472B),
                  ),
                  title: Text(draft['title'] as String? ?? 'Adsız belge'),
                  subtitle: Text(
                    '${(draft['questions'] as List<dynamic>? ?? []).length} soru taslağı',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocumentTypeSheet extends StatelessWidget {
  const DocumentTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ne hazırlıyorsun?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFDDD8CF)),
            ),
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Sınav'),
            subtitle: const Text('Soruları tek tek ekle ve düzenle'),
            onTap: () => Navigator.pop(context, DocumentType.exam),
          ),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFDDD8CF)),
            ),
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Ders föyü'),
            subtitle: const Text('Metin ve görselleri düzenle'),
            onTap: () => Navigator.pop(context, DocumentType.handout),
          ),
        ],
      ),
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
  final title = TextEditingController();
  final subtitle = TextEditingController();
  PageStyle pageStyle = PageStyle.exam;
  int columns = 1;
  bool showStudentFields = true;

  @override
  void dispose() {
    title.dispose();
    subtitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.type == DocumentType.exam;
    return Scaffold(
      appBar: AppBar(title: Text(exam ? 'Yeni sınav' : 'Yeni ders föyü')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            exam ? 'Öğe Ekle' : 'Konu Ekle',
            style: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: title,
            decoration: InputDecoration(
              labelText: exam ? 'Sınav başlığı' : 'Föy başlığı',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: subtitle,
            decoration: InputDecoration(
              labelText: exam ? 'Ders ve sınıf' : 'Konu',
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sayfa düzeni',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PageStyle>(
            initialValue: pageStyle,
            decoration: const InputDecoration(labelText: 'Format'),
            items: const [
              DropdownMenuItem(
                value: PageStyle.exam,
                child: Text('Sınav formatı'),
              ),
              DropdownMenuItem(
                value: PageStyle.book,
                child: Text('Kitap / konu formatı'),
              ),
            ],
            onChanged: (value) =>
                setState(() => pageStyle = value ?? PageStyle.exam),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: columns,
            decoration: const InputDecoration(labelText: 'Sütun sayısı'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 sütun')),
              DropdownMenuItem(value: 2, child: Text('2 sütun')),
            ],
            onChanged: (value) => setState(() => columns = value ?? 1),
          ),
          if (widget.type == DocumentType.exam)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ad Soyad / Sınıf / Tarih alanları'),
              value: showStudentFields,
              onChanged: (value) => setState(() => showStudentFields = value),
            ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContentCapturePage(
                  type: widget.type,
                  title: title.text.trim().isEmpty
                      ? (exam ? 'Yeni sınav' : 'Yeni ders föyü')
                      : title.text.trim(),
                  subtitle: subtitle.text.trim(),
                  pageStyle: pageStyle,
                  columns: columns,
                  showStudentFields: showStudentFields,
                ),
              ),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('İçerik eklemeye geç'),
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
    required this.pageStyle,
    required this.columns,
    required this.showStudentFields,
    super.key,
  });
  final DocumentType type;
  final String title;
  final String subtitle;
  final PageStyle pageStyle;
  final int columns;
  final bool showStudentFields;

  @override
  State<ContentCapturePage> createState() => _ContentCapturePageState();
}

class _ContentCapturePageState extends State<ContentCapturePage> {
  final picker = ImagePicker();
  final cropper = ImageCropper();
  final pages = <XFile>[];
  final texts = <int, String>{};
  final figures = <int, XFile>{};
  final itemTypes = <int, DocumentType>{};
  final imagePositions = <int, ImagePosition>{};
  final answerAreas = <int, bool>{};
  final pageBreaks = <int, bool>{};
  DocumentType nextItemType = DocumentType.exam;
  ImagePosition nextImagePosition = ImagePosition.above;
  bool nextAnswerArea = false;
  bool nextPageBreak = false;

  @override
  void initState() {
    super.initState();
    nextItemType = widget.type;
  }

  int? busy;

  Future<XFile?> crop(String path, String title) async {
    final result = await cropper.cropImage(
      sourcePath: path,
      compressQuality: 92,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF1D8064),
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: title),
      ],
    );
    return result == null ? null : XFile(result.path);
  }

  Future<void> addQuestion(ImageSource source) async {
    final image = await picker.pickImage(source: source, imageQuality: 90);
    if (!mounted || image == null) return;
    final result = await crop(image.path, 'Soruyu kırp');
    if (!mounted || result == null) return;
    setState(() {
      final index = pages.length;
      pages.add(result);
      itemTypes[index] = nextItemType;
      imagePositions[index] = nextImagePosition;
      answerAreas[index] = nextAnswerArea;
      pageBreaks[index] = nextPageBreak;
      nextAnswerArea = false;
      nextPageBreak = false;
    });
  }

  Future<void> extractText(int index) async {
    setState(() => busy = index);
    try {
      final text = await PlatformTextRecognizer.instance.recognizeText(
        pages[index].path,
        script: TextRecognitionScript.latin,
        languages: const ['tr-TR'],
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OcrEditorPage(
            pageNumber: index + 1,
            imagePath: pages[index].path,
            initialText: text,
            onSave: (value) => texts[index] = value,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  Future<void> addFigure(int index) async {
    final result = await crop(pages[index].path, 'Şekli seç');
    if (!mounted || result == null) return;
    setState(() => figures[index] = result);
  }

  Future<void> openPreview() async {
    await saveDraft(
      title: widget.title,
      subtitle: widget.subtitle,
      type: widget.type,
      questions: texts.values,
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentPreviewPage(
          type: widget.type,
          title: widget.title,
          subtitle: widget.subtitle,
          pages: pages,
          texts: texts,
          figures: figures,
          itemTypes: itemTypes,
          imagePositions: imagePositions,
          answerAreas: answerAreas,
          pageBreaks: pageBreaks,
          pageStyle: widget.pageStyle,
          columns: widget.columns,
          showStudentFields: widget.showStudentFields,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == DocumentType.exam ? 'Sınav içeriği' : 'Föy içeriği',
        ),
        actions: [
          if (pages.isNotEmpty)
            IconButton(
              onPressed: openPreview,
              icon: const Icon(Icons.preview_outlined),
            ),
        ],
      ),
      body: pages.isEmpty
          ? _EmptyCapture(
              onGallery: () => addQuestion(ImageSource.gallery),
              onCamera: () => addQuestion(ImageSource.camera),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ItemLayoutPanel(
                  itemType: nextItemType,
                  imagePosition: nextImagePosition,
                  answerArea: nextAnswerArea,
                  pageBreak: nextPageBreak,
                  onTypeChanged: (value) =>
                      setState(() => nextItemType = value),
                  onPositionChanged: (value) =>
                      setState(() => nextImagePosition = value),
                  onAnswerChanged: (value) =>
                      setState(() => nextAnswerArea = value),
                  onPageBreakChanged: (value) =>
                      setState(() => nextPageBreak = value),
                ),
                const SizedBox(height: 16),
                Text(
                  '${pages.length} soru eklendi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ...pages.asMap().entries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Image.file(
                          File(entry.value.path),
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                        ListTile(
                          title: Text('Soru ${entry.key + 1}'),
                          subtitle: Text(
                            texts.containsKey(entry.key)
                                ? 'Metin hazır'
                                : 'Metin bekliyor',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: busy == entry.key
                                      ? null
                                      : () => extractText(entry.key),
                                  icon: const Icon(Icons.text_fields),
                                  label: Text(
                                    busy == entry.key
                                        ? 'Çıkarılıyor'
                                        : 'Metni çıkar',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => addFigure(entry.key),
                                  icon: const Icon(Icons.crop),
                                  label: Text(
                                    figures.containsKey(entry.key)
                                        ? 'Şekli değiştir'
                                        : 'Şekli seç',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => addQuestion(ImageSource.gallery),
                  icon: const Icon(Icons.add),
                  label: const Text('Başka soru ekle'),
                ),
              ],
            ),
    );
  }
}

class _ItemLayoutPanel extends StatelessWidget {
  const _ItemLayoutPanel({
    required this.itemType,
    required this.imagePosition,
    required this.answerArea,
    required this.pageBreak,
    required this.onTypeChanged,
    required this.onPositionChanged,
    required this.onAnswerChanged,
    required this.onPageBreakChanged,
  });

  final DocumentType itemType;
  final ImagePosition imagePosition;
  final bool answerArea;
  final bool pageBreak;
  final ValueChanged<DocumentType> onTypeChanged;
  final ValueChanged<ImagePosition> onPositionChanged;
  final ValueChanged<bool> onAnswerChanged;
  final ValueChanged<bool> onPageBreakChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Yeni öğe düzeni',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<DocumentType>(
              initialValue: itemType,
              decoration: const InputDecoration(labelText: 'Tür'),
              items: const [
                DropdownMenuItem(value: DocumentType.exam, child: Text('Soru')),
                DropdownMenuItem(
                  value: DocumentType.handout,
                  child: Text('Konu anlatımı'),
                ),
              ],
              onChanged: (value) {
                if (value != null) onTypeChanged(value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ImagePosition>(
              initialValue: imagePosition,
              decoration: const InputDecoration(labelText: 'Görsel konumu'),
              items: const [
                DropdownMenuItem(
                  value: ImagePosition.above,
                  child: Text('Üstte'),
                ),
                DropdownMenuItem(
                  value: ImagePosition.left,
                  child: Text('Solda'),
                ),
                DropdownMenuItem(
                  value: ImagePosition.right,
                  child: Text('Sağda'),
                ),
              ],
              onChanged: (value) {
                if (value != null) onPositionChanged(value);
              },
            ),
            if (itemType == DocumentType.exam)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Boş cevap alanı ekle'),
                value: answerArea,
                onChanged: (value) => onAnswerChanged(value ?? false),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bu öğeden önce yeni sayfa başlat'),
              value: pageBreak,
              onChanged: (value) => onPageBreakChanged(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentPreviewPage extends StatefulWidget {
  const DocumentPreviewPage({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.pages,
    required this.texts,
    required this.figures,
    required this.itemTypes,
    required this.imagePositions,
    required this.answerAreas,
    required this.pageBreaks,
    required this.pageStyle,
    required this.columns,
    required this.showStudentFields,
    super.key,
  });
  final DocumentType type;
  final String title;
  final String subtitle;
  final List<XFile> pages;
  final Map<int, String> texts;
  final Map<int, XFile> figures;
  final Map<int, DocumentType> itemTypes;
  final Map<int, ImagePosition> imagePositions;
  final Map<int, bool> answerAreas;
  final Map<int, bool> pageBreaks;
  final PageStyle pageStyle;
  final int columns;
  final bool showStudentFields;

  @override
  State<DocumentPreviewPage> createState() => _DocumentPreviewPageState();
}

class _DocumentPreviewPageState extends State<DocumentPreviewPage> {
  final positions = <int, double>{};

  double positionFor(int index) => positions[index] ?? 0.0;

  void moveFigure(int index, DragUpdateDetails details) {
    setState(
      () => positions[index] = (positionFor(index) + details.delta.dy / 260)
          .clamp(-0.20, 0.75),
    );
  }

  Future<void> editQuestion(int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => OcrEditorPage(
          pageNumber: index + 1,
          imagePath: widget.pages[index].path,
          initialText: widget.texts[index] ?? '',
          onSave: (value) => widget.texts[index] = value,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> exportPdf() async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/ArialUnicode.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/ArialBold.ttf'),
    );
    final document = pw.Document();
    final groups = <List<int>>[];
    var current = <int>[];
    for (var index = 0; index < widget.pages.length; index++) {
      if (widget.pageBreaks[index] == true && current.isNotEmpty) {
        groups.add(current);
        current = <int>[];
      }
      current.add(index);
    }
    if (current.isNotEmpty) groups.add(current);

    pw.Widget item(int index) {
      final figure = widget.figures[index];
      final image = figure == null
          ? null
          : pw.MemoryImage(File(figure.path).readAsBytesSync());
      final text = pw.Text(
        formatMathForOutput(widget.texts[index] ?? ''),
        style: pw.TextStyle(font: regular, fontSize: 11),
      );
      final imageWidget = image == null
          ? null
          : pw.Image(image, width: 150, height: 105, fit: pw.BoxFit.contain);
      pw.Widget body;
      switch (widget.imagePositions[index] ?? ImagePosition.above) {
        case ImagePosition.left:
          body = imageWidget == null
              ? text
              : pw.Row(
                  children: [
                    imageWidget,
                    pw.SizedBox(width: 8),
                    pw.Expanded(child: text),
                  ],
                );
        case ImagePosition.right:
          body = imageWidget == null
              ? text
              : pw.Row(
                  children: [
                    pw.Expanded(child: text),
                    pw.SizedBox(width: 8),
                    imageWidget,
                  ],
                );
        case ImagePosition.above:
          body = pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [imageWidget ?? pw.SizedBox(), text],
          );
      }
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              widget.itemTypes[index] == DocumentType.handout
                  ? 'Konu ${index + 1}'
                  : 'Soru ${index + 1}',
              style: pw.TextStyle(font: bold, fontSize: 12),
            ),
            body,
            if (widget.answerAreas[index] == true) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                height: 18,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide()),
                ),
              ),
              pw.Container(
                height: 18,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide()),
                ),
              ),
            ],
          ],
        ),
      );
    }

    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final group = groups[groupIndex];
      final blocks = group.map(item).toList();
      final content = widget.columns == 2
          ? pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      for (var i = 0; i < blocks.length; i += 2) blocks[i],
                    ],
                  ),
                ),
                pw.SizedBox(width: 18),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      for (var i = 1; i < blocks.length; i += 2) blocks[i],
                    ],
                  ),
                ),
              ],
            )
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: blocks,
            );
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (groupIndex == 0) ...[
                pw.Text(
                  widget.title,
                  style: pw.TextStyle(font: bold, fontSize: 20),
                ),
                if (widget.subtitle.isNotEmpty)
                  pw.Text(widget.subtitle, style: pw.TextStyle(font: regular)),
                if (widget.pageStyle == PageStyle.exam &&
                    widget.showStudentFields)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Text(
                      'Ad Soyad: ____________________   Sınıf: ______   Tarih: ______',
                      style: pw.TextStyle(font: regular, fontSize: 10),
                    ),
                  ),
              ],
              content,
            ],
          ),
        ),
      );
    }
    await Printing.layoutPdf(onLayout: (_) => document.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sayfayı düzenle'),
        actions: [
          IconButton(
            onPressed: () => saveDraft(
              title: widget.title,
              subtitle: widget.subtitle,
              type: widget.type,
              questions: widget.texts.values,
            ),
            tooltip: 'Taslağı kaydet',
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          IconButton(
            onPressed: exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Her soru kendi alanında kalır. Şekli sürükleyerek metnin istediğin yerine taşı.',
          ),
          const SizedBox(height: 18),
          ...widget.pages.asMap().entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: Text(
                        'Soru ${entry.key + 1}\n${formatMathForOutput(widget.texts[entry.key] ?? '')}',
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        onPressed: () => editQuestion(entry.key),
                        tooltip: 'Soruyu düzenle',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ),
                    if (widget.figures[entry.key] != null)
                      Positioned(
                        left: 72,
                        top: 150 + positionFor(entry.key) * 220,
                        child: GestureDetector(
                          onPanUpdate: (details) =>
                              moveFigure(entry.key, details),
                          child: Image.file(
                            File(widget.figures[entry.key]!.path),
                            width: 170,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF olarak dışa aktar'),
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
  late final controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    widget.onSave(controller.text.trim());
    Navigator.pop(context);
  }

  void insertMath(String value) {
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : controller.text.length;
    final end = selection.isValid ? selection.end : start;
    final text = controller.text.replaceRange(start, end, value);
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soru ${widget.pageNumber} metni'),
        actions: [IconButton(onPressed: save, icon: const Icon(Icons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.file(File(widget.imagePath), height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            minLines: 8,
            maxLines: null,
            decoration: const InputDecoration(hintText: 'Metni düzenle'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Matematik ifadeleri',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => insertMath('x^2'),
                child: const Text('Üs  x²'),
              ),
              OutlinedButton(
                onPressed: () => insertMath('log_2(x)'),
                child: const Text('log'),
              ),
              OutlinedButton(
                onPressed: () => insertMath('√(x)'),
                child: const Text('√ kök'),
              ),
              OutlinedButton(
                onPressed: () => insertMath('(a)/(b)'),
                child: const Text('Kesir'),
              ),
              OutlinedButton(
                onPressed: () => insertMath('π'),
                child: const Text('π'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Şablonu metin içinde istediğin yere ekleyip düzenleyebilirsin: x^2, log_2(x), √(x).',
            style: TextStyle(fontSize: 12, color: Color(0xFF59645F)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Metni kaydet'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCapture extends StatelessWidget {
  const _EmptyCapture({required this.onGallery, required this.onCamera});
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.document_scanner_outlined,
              size: 60,
              color: Color(0xFF1D8064),
            ),
            const SizedBox(height: 18),
            const Text(
              'İlk sayfanı ekle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamerayla çek'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeriden seç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
