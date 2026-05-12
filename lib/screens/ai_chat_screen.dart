import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  static const _bg = Color(0xFF12121D);
  static const _surface = Color(0xFF1E1E2C);
  static const _surface2 = Color(0xFF2A2A3D);
  static const _purple = Color(0xFF8A2BE2);

  // ✅ Supabase тохиргоо
  static const _supabaseUrl = 'https://msxuvfrttvcjrzwabnyk.supabase.co';
  static const _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zeHV2ZnJ0dHZjanJ6d2FibnlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMTk1NDIsImV4cCI6MjA4ODY5NTU0Mn0.B7T1uNvpfCfG-dpQusBYwqBdNmusKzY7_YOBWZZOjlo';

  final _suggestions = [
    '💰 Сарын төсөв хэрхэн гаргах вэ?',
    '📈 Зээлийн оноо сайжруулах арга?',
    '🏠 Орон сууц зээлд хэрхэн бэлтгэх?',
    '💳 1 жилд хичнээн хуримтлаж болох вэ?',
    '📊 Зарлага бууруулах 5 арга зам',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Сайн байна уу! Би таны **Санхүү AI** туслах 🤖\n\n'
          'Зээл, хуримтлал, санхүүгийн төлөвлөгөө болон бусад '
          'санхүүгийн асуудлаар туслахад бэлэн. Юу асуумаар байна вэ?',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _msgCtrl.text).trim();
    if (text.isEmpty || _loading) return;
    _msgCtrl.clear();

    setState(() {
      _messages
          .add(_ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _loading = true;
    });
    _scrollToBottom();

    try {
      // Мэндчилгээний мессежийг алгасаж, сүүлийн түүхийг дамжуулна
      final history = _messages
          .skip(1)
          .map((m) =>
              {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      // ✅ Supabase Edge Function руу илгээх
      final res = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/ai-chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode({'messages': history}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        // ✅ Edge Function { reply: "..." } буцаадаг
        final reply = data['reply'] as String;
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(
              text: reply,
              isUser: false,
              time: DateTime.now(),
            ));
          });
        }
      } else {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        _addError(
            'Алдаа (${res.statusCode}): ${data['error'] ?? 'Дахин оролдоно уу.'}');
      }
    } catch (e) {
      _addError('Интернэт холболт шалгана уу.');
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _addError(String msg) {
    if (mounted) {
      setState(() {
        _messages.add(
          _ChatMessage(
              text: msg, isUser: false, time: DateTime.now(), isError: true),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_messages.length == 1) _buildSuggestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Санхүү AI',
                style: TextStyle(
                  color: Color.fromARGB(255, 252, 248, 248),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Онлайн',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20),
          tooltip: 'Дахин эхлэх',
          onPressed: () => setState(() {
            _messages.clear();
            _messages.add(_ChatMessage(
              text: 'Сайн байна уу! Би таны **Санхүү AI** туслах 🤖\n\n'
                  'Зээл, хуримтлал, санхүүгийн төлөвлөгөө болон бусад '
                  'санхүүгийн асуудлаар туслахад бэлэн. Юу асуумаар байна вэ?',
              isUser: false,
              time: DateTime.now(),
            ));
          }),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length) return _buildTypingIndicator();
        return _buildBubble(_messages[i]);
      },
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Хуулагдлаа'),
                    duration: Duration(seconds: 1),
                    backgroundColor: _surface2,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  gradient: msg.isUser
                      ? const LinearGradient(
                          colors: [_purple, Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: msg.isUser
                      ? null
                      : msg.isError
                          ? const Color(0xFF3D1515)
                          : _surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                  ),
                  border: msg.isError
                      ? Border.all(color: Colors.red.withOpacity(0.3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: msg.isUser
                          ? _purple.withOpacity(0.25)
                          : Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormattedText(msg.text, msg.isUser),
                    const SizedBox(height: 4),
                    Text(
                      '${msg.time.hour.toString().padLeft(2, '0')}:'
                      '${msg.time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: msg.isUser
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, bool isUser) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.normal,
          color: isUser ? Colors.white : Colors.white.withOpacity(0.92),
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _TypingDot(delay: i * 200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _send(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _purple.withOpacity(0.3)),
            ),
            child: Text(
              _suggestions[i],
              style: const TextStyle(
                  color: Color.fromARGB(179, 241, 239, 239), fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: _surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _purple.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(
                    color: Color.fromARGB(255, 15, 15, 15), fontSize: 14),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Асуулт бичнэ үү...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// TYPING DOTS ANIMATION
// =============================================
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          color: Color(0xFF8A2BE2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// =============================================
// CHAT MESSAGE MODEL
// =============================================
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}
