import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/question.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.questions,
    required this.title,
    this.category,
    this.sub,
    this.daily = false,
  });

  final List<Question> questions;
  final String title;
  final String? category;
  final String? sub;
  final bool daily;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int totalTime = 15;

  late final List<List<int>> _orders;
  int _idx = 0;
  int _timeLeft = totalTime;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _best = 0;
  int _coins = 0;
  int _xp = 0;
  int? _selected;
  bool _answered = false;
  bool _timedOut = false;
  String? _hint;
  final Set<int> _removed = {};
  final Set<String> _cats = {};
  Timer? _timer;

  Question get _q => widget.questions[_idx];

  @override
  void initState() {
    super.initState();
    _orders = widget.questions.map((q) {
      final l = List<int>.generate(q.options.length, (i) => i);
      l.shuffle();
      return l;
    }).toList();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ───────────── المؤقت ─────────────
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = totalTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered) return;
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) _onTimeout();
    });
  }

  void _onTimeout() {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _timedOut = true;
      _wrong++;
      _streak = 0;
      _cats.add(_q.category);
    });
    HapticFeedback.vibrate();
  }

  // ───────────── الإجابة ─────────────
  void _select(int d) {
    if (_answered || _removed.contains(d)) return;
    _timer?.cancel();
    final bool isCorrect = _orders[_idx][d] == _q.correct;
    setState(() {
      _selected = d;
      _answered = true;
      _cats.add(_q.category);
      if (isCorrect) {
        _correct++;
        _streak++;
        if (_streak > _best) _best = _streak;
        _coins += 20 + _timeLeft * 2;
        _xp += 50;
      } else {
        _wrong++;
        _streak = 0;
      }
    });
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _next() {
    if (_idx + 1 >= widget.questions.length) {
      _finish();
      return;
    }
    setState(() {
      _idx++;
      _selected = null;
      _answered = false;
      _timedOut = false;
      _hint = null;
      _removed.clear();
    });
    _startTimer();
  }

  void _finish() {
    _timer?.cancel();
    final app = AppScope.read(context);
    final res = app.completeRound(
      correct: _correct,
      wrong: _wrong,
      total: widget.questions.length,
      bestStreak: _best,
      coins: _coins,
      xp: _xp,
      categoriesSeen: _cats,
      daily: widget.daily,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        // The result is another Navigator route, so it also needs AppScope.
        builder: (_) => AppScope(
          state: app,
          child: ResultScreen(
            result: res,
            title: widget.title,
            category: widget.category,
            sub: widget.sub,
          ),
        ),
      ),
    );
  }

  // ───────────── المساعدات ─────────────
  String _hintText(Question q) {
    var a = q.options[q.correct].trim();
    if (a.startsWith('ال') && a.length > 3) a = a.substring(2);
    final first = a.isEmpty ? '' : a.substring(0, 1);
    return 'تلميح: الإجابة تبدأ بحرف "$first"';
  }

  void _useHint() {
    if (_answered || _hint != null) return;
    final app = AppScope.read(context);
    if (!app.useHelper('hint')) {
      showSnack(context, 'مفيش تلميحات متبقية، اشتري من المتجر');
      return;
    }
    setState(() {
      _hint = _hintText(_q);
    });
  }

  void _useSkip() {
    if (_answered) return;
    final app = AppScope.read(context);
    if (!app.useHelper('skip')) {
      showSnack(context, 'مفيش تخطّي متبقي، اشتري من المتجر');
      return;
    }
    _timer?.cancel();
    _next();
  }

  void _useDelete() {
    if (_answered) return;
    final wrongs = <int>[];
    for (var d = 0; d < _orders[_idx].length; d++) {
      if (_orders[_idx][d] != _q.correct && !_removed.contains(d)) wrongs.add(d);
    }
    if (wrongs.length < 2) return;
    final app = AppScope.read(context);
    if (!app.useHelper('delete')) {
      showSnack(context, 'مفيش حذف متبقي، اشتري من المتجر');
      return;
    }
    wrongs.shuffle();
    setState(() {
      _removed.addAll(wrongs.take(2));
    });
  }

  Future<void> _confirmExit() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card2,
        title: Text('الخروج من الجولة؟', style: tsx(18, w: FontWeight.w900)),
        content: Text('هتخسر تقدمك في الجولة الحالية.', style: tsx(14, color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('كمّل', style: tsx(15, w: FontWeight.w900, color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('اخرج', style: tsx(15, w: FontWeight.w900, color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  // ───────────── الواجهة ─────────────
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final q = _q;
    final order = _orders[_idx];
    final int correctDisplay = order.indexOf(q.correct);
    final int total = widget.questions.length;
    final bool low = _timeLeft <= 5;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _confirmExit,
                    icon: const Icon(Icons.close_rounded, color: AppColors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.red.o(0.1),
                    ),
                  ),
                  Expanded(
                    child: Text(widget.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tsx(15, w: FontWeight.w900)),
                  ),
                  StatChip(icon: Icons.monetization_on_rounded, label: '$_coins'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('السؤال ${_idx + 1}/$total', style: tsx(13, color: AppColors.text2)),
                  const Spacer(),
                  const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 4),
                  Text('$_correct', style: tsx(15, w: FontWeight.w900, color: AppColors.accent)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (low ? AppColors.red : AppColors.accent).o(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded, size: 16, color: low ? AppColors.red : AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$_timeLeft ث',
                            style: tsx(13, w: FontWeight.w900, color: low ? AppColors.red : AppColors.accent)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_idx + (_answered ? 1 : 0)) / total,
                  minHeight: 6,
                  backgroundColor: AppColors.card2,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _timeLeft / totalTime,
                  minHeight: 4,
                  backgroundColor: AppColors.card2,
                  color: low ? AppColors.red : AppColors.green,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: cardDecoration(radius: 22, border: AppColors.accent.o(0.35)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Badge(q.category),
                              const SizedBox(width: 6),
                              _Badge(q.sub),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(q.text, style: tsx(18, w: FontWeight.w800, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var d = 0; d < order.length; d++)
                      _OptionTile(
                        text: q.options[order[d]],
                        removed: _removed.contains(d),
                        state: _answered
                            ? (d == correctDisplay
                                ? _OptState.correct
                                : (d == _selected ? _OptState.wrong : _OptState.dim))
                            : _OptState.normal,
                        onTap: () => _select(d),
                      ),
                    if (_hint != null && !_answered)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: cardDecoration(radius: 16, color: AppColors.accent.o(0.08)),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_hint!, style: tsx(14, w: FontWeight.w800, color: AppColors.accent))),
                          ],
                        ),
                      ),
                    if (_answered)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: cardDecoration(radius: 16, color: AppColors.card2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _timedOut
                                      ? Icons.timer_off_rounded
                                      : (_selected != null && _orders[_idx][_selected!] == q.correct
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded),
                                  color: _timedOut
                                      ? AppColors.accent
                                      : (_selected != null && _orders[_idx][_selected!] == q.correct
                                          ? AppColors.green
                                          : AppColors.red),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _timedOut
                                      ? 'انتهى الوقت'
                                      : (_selected != null && _orders[_idx][_selected!] == q.correct
                                          ? 'إجابة صحيحة'
                                          : 'إجابة خاطئة'),
                                  style: tsx(15, w: FontWeight.w900),
                                ),
                              ],
                            ),
                            if (q.explanation.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(q.explanation, style: tsx(13, color: AppColors.text2, height: 1.6)),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (!_answered)
                Row(
                  children: [
                    Expanded(
                      child: _HelperButton(
                        icon: Icons.lightbulb_rounded,
                        label: 'تلميح',
                        count: app.data.hints,
                        onTap: _useHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HelperButton(
                        icon: Icons.content_cut_rounded,
                        label: 'حذف إجابتين',
                        count: app.data.deletes,
                        onTap: _useDelete,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HelperButton(
                        icon: Icons.skip_next_rounded,
                        label: 'تخطّي',
                        count: app.data.skips,
                        onTap: _useSkip,
                      ),
                    ),
                  ],
                )
              else
                GoldButton(
                  label: _idx + 1 >= total ? 'إنهاء الجولة' : 'السؤال التالي',
                  icon: _idx + 1 >= total ? Icons.flag_rounded : Icons.arrow_back_rounded,
                  onTap: _next,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.o(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: tsx(11, w: FontWeight.w800, color: AppColors.text2)),
    );
  }
}

enum _OptState { normal, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.removed,
    required this.state,
    required this.onTap,
  });
  final String text;
  final bool removed;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.card;
    Color border = Colors.white.o(0.08);
    Color fg = Colors.white;
    switch (state) {
      case _OptState.correct:
        bg = AppColors.green.o(0.16);
        border = AppColors.green;
        fg = AppColors.green;
        break;
      case _OptState.wrong:
        bg = AppColors.red.o(0.16);
        border = AppColors.red;
        fg = AppColors.red;
        break;
      case _OptState.dim:
        fg = Colors.white.o(0.4);
        break;
      case _OptState.normal:
        break;
    }
    return Opacity(
      opacity: removed ? 0.2 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: removed ? null : onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Text(text, textAlign: TextAlign.center, style: tsx(16, w: FontWeight.w800, color: fg)),
        ),
      ),
    );
  }
}

class _HelperButton extends StatelessWidget {
  const _HelperButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool empty = count <= 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (empty ? AppColors.red : AppColors.accent).o(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: empty ? AppColors.text2 : AppColors.accent, size: 22),
            const SizedBox(height: 2),
            Text(label, style: tsx(11, w: FontWeight.w800, color: AppColors.text2)),
            Text('$count', style: tsx(13, w: FontWeight.w900, color: empty ? AppColors.red : AppColors.accent)),
          ],
        ),
      ),
    );
  }
}
