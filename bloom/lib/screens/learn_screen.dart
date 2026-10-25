import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/articles.dart';
import '../widgets/common.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.colors;
    final lang = context.app.lang;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(s.t('learn_title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: c.text)),
          const SizedBox(height: 4),
          Text(s.t('learn_sub'), style: TextStyle(fontSize: 15, color: c.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          for (final a in articles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ArticleScreen(article: a)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(a.color).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(a.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titleIn(lang),
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.f('read_min', {'n': a.minutes}),
                            style: TextStyle(fontSize: 13, color: Color(a.color), fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.muted, size: 30),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.app.lang;
    final color = Color(article.color);
    final parts = article.bodyIn(lang).split('\n\n');

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(article.emoji, style: const TextStyle(fontSize: 70)),
            ),
            const SizedBox(height: 20),
            Text(
              article.titleIn(lang),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c.text, height: 1.2),
            ),
            const SizedBox(height: 16),
            for (final p in parts)
              if (p.trim().startsWith('# '))
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: Text(
                    p.trim().substring(2),
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    p.trim(),
                    style: TextStyle(fontSize: 17, color: c.text, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
