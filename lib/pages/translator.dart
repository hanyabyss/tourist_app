// ignore_for_file: sort_child_properties_last
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2A44),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final List<Language> _languages = const [
    Language(
        name: 'English', code: 'en', flagUrl: 'https://flagcdn.com/w20/us.png'),
    Language(
        name: 'Spanish', code: 'es', flagUrl: 'https://flagcdn.com/w20/es.png'),
    Language(
        name: 'French', code: 'fr', flagUrl: 'https://flagcdn.com/w20/fr.png'),
    Language(
        name: 'German', code: 'de', flagUrl: 'https://flagcdn.com/w20/de.png'),
    Language(
        name: 'Arabic', code: 'ar', flagUrl: 'https://flagcdn.com/w20/sa.png'),
    Language(
        name: 'Chinese', code: 'zh', flagUrl: 'https://flagcdn.com/w20/cn.png'),
    Language(
        name: 'Japanese',
        code: 'ja',
        flagUrl: 'https://flagcdn.com/w20/jp.png'),
  ];

  String _selectedLanguageFrom = 'English';
  String _selectedLanguageTo = 'Arabic';
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedLanguageFrom;
      _selectedLanguageFrom = _selectedLanguageTo;
      _selectedLanguageTo = temp;
    });
  }

  Future<void> _translateText() async {
    if (_inputController.text.isEmpty) return;

    try {
      final fromLang = _languages
          .firstWhere((lang) => lang.name == _selectedLanguageFrom)
          .code;
      final toLang = _languages
          .firstWhere((lang) => lang.name == _selectedLanguageTo)
          .code;

      final response = await http.post(
        Uri.parse('https://translation-api-wrre.onrender.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _inputController.text,
          'source': fromLang == 'auto' ? 'auto' : fromLang,
          'target': toLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _outputText = data['translated_text'];
        });
      } else {
        setState(() {
          _outputText = 'Translation failed';
        });
      }
    } catch (e) {
      setState(() {
        _outputText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
        leading: const Icon(Icons.menu),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 16),
            _buildInputField(),
            const SizedBox(height: 16),
            _buildOutputField(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageDropdown(
            value: _selectedLanguageFrom,
            onChanged: (value) =>
                setState(() => _selectedLanguageFrom = value!),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
          ),
          _buildLanguageDropdown(
            value: _selectedLanguageTo,
            onChanged: (value) => setState(() => _selectedLanguageTo = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: _languages.map((language) {
        return DropdownMenuItem<String>(
          value: language.name,
          child: Row(
            children: [
              Image.network(
                language.flagUrl,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 20),
              ),
              const SizedBox(width: 8),
              Text(language.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      underline: const SizedBox(),
    );
  }

  Widget _buildInputField() {
    return TranslationCard(
      language: _selectedLanguageFrom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguageFrom,
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            focusNode: _focusNode,
            maxLines: 3,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type text to translate...',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed:
                    _inputController.text.isEmpty ? null : _translateText,
                child: const Text('Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputField() {
    return TranslationCard(
      language: _selectedLanguageTo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguageTo,
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              _outputText.isEmpty
                  ? 'Translation will appear here'
                  : _outputText,
              style: TextStyle(
                color: _outputText.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_outputText.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {}, // TODO: Implement copy
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () {}, // TODO: Implement share
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.star_border, color: Colors.blue),
                  onPressed: () {}, // TODO: Implement favorite
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'FAQ',
        ),
      ],
      currentIndex: 0,
    );
  }
}

class TranslationCard extends StatelessWidget {
  final String language;
  final Widget child;

  const TranslationCard({
    super.key,
    required this.language,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBFA),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Language {
  final String name;
  final String code;
  final String flagUrl;

  const Language({
    required this.name,
    required this.code,
    required this.flagUrl,
  });
}
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
// مكتبة المشاركة

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2A44),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final List<Language> _languages = const [
    Language(
        name: 'English', code: 'en', flagUrl: 'https://flagcdn.com/w20/us.png'),
    Language(
        name: 'Spanish', code: 'es', flagUrl: 'https://flagcdn.com/w20/es.png'),
    Language(
        name: 'French', code: 'fr', flagUrl: 'https://flagcdn.com/w20/fr.png'),
    Language(
        name: 'German', code: 'de', flagUrl: 'https://flagcdn.com/w20/de.png'),
    Language(
        name: 'Arabic', code: 'ar', flagUrl: 'https://flagcdn.com/w20/sa.png'),
    Language(
        name: 'Chinese', code: 'zh', flagUrl: 'https://flagcdn.com/w20/cn.png'),
    Language(
        name: 'Japanese',
        code: 'ja',
        flagUrl: 'https://flagcdn.com/w20/jp.png'),
  ];

  String _selectedLanguageFrom = 'English';
  String _selectedLanguageTo = 'Arabic';
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedLanguageFrom;
      _selectedLanguageFrom = _selectedLanguageTo;
      _selectedLanguageTo = temp;
    });
  }

  Future<void> _translateText() async {
    if (_inputController.text.isEmpty) return;

    try {
      final fromLang = _languages
          .firstWhere((lang) => lang.name == _selectedLanguageFrom)
          .code;
      final toLang = _languages
          .firstWhere((lang) => lang.name == _selectedLanguageTo)
          .code;

      final response = await http.post(
        Uri.parse('https://translation-api-wrre.onrender.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _inputController.text,
          'source': fromLang == 'auto' ? 'auto' : fromLang,
          'target': toLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _outputText = data['translated_text'];
        });
      } else {
        setState(() {
          _outputText = 'Translation failed';
        });
      }
    } catch (e) {
      setState(() {
        _outputText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Translator',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // لتجنب overflow عند ظهور الكيبورد
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildLanguageSelector(),
              const SizedBox(height: 16),
              _buildInputField(),
              const SizedBox(height: 16),
              _buildOutputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageDropdown(
            value: _selectedLanguageFrom,
            onChanged: (value) =>
                setState(() => _selectedLanguageFrom = value!),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
          ),
          _buildLanguageDropdown(
            value: _selectedLanguageTo,
            onChanged: (value) => setState(() => _selectedLanguageTo = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: _languages.map((language) {
        return DropdownMenuItem<String>(
          value: language.name,
          child: Row(
            children: [
              Image.network(
                language.flagUrl,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 20),
              ),
              const SizedBox(width: 8),
              Text(language.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      underline: const SizedBox(),
    );
  }

  Widget _buildInputField() {
    return TranslationCard(
      language: _selectedLanguageFrom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguageFrom,
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            focusNode: _focusNode,
            maxLines: 3,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type text to translate...',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed:
                    _inputController.text.isEmpty ? null : _translateText,
                child: const Text('Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputField() {
    return TranslationCard(
      language: _selectedLanguageTo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguageTo,
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            child: Text(
              _outputText.isEmpty
                  ? 'Translation will appear here'
                  : _outputText,
              style: TextStyle(
                color: _outputText.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_outputText.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _outputText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () {
                    Share.share(_outputText);
                  },
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class TranslationCard extends StatelessWidget {
  final String language;
  final Widget child;

  const TranslationCard({
    super.key,
    required this.language,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBFA),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Language {
  final String name;
  final String code;
  final String flagUrl;

  const Language({
    required this.name,
    required this.code,
    required this.flagUrl,
  });
}
