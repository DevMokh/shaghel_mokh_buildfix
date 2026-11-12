import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subs;
  const CategoryInfo(this.name, this.icon, this.color, this.subs);
}

const List<CategoryInfo> categories = [
  CategoryInfo('إسلاميات', Icons.mosque, Color(0xFFF59E0B),
      ['قصص الأنبياء', 'القرآن الكريم', 'السيرة النبوية', 'الفقه الميسر']),
  CategoryInfo('تاريخ مصر', Icons.account_balance, Color(0xFFEF4444),
      ['الفراعنة', 'مصر الحديثة', 'آثار النوبة', 'ثورات مصر']),
  CategoryInfo('تقنية', Icons.code, Color(0xFF3B82F6),
      ['برمجة', 'ذكاء اصطناعي', 'أمن سيبراني', 'تاريخ الحواسيب']),
  CategoryInfo('علوم وفضاء', Icons.rocket_launch, Color(0xFF8B5CF6),
      ['الفضاء', 'جسم الإنسان', 'الكيمياء', 'الفيزياء الكمية']),
  CategoryInfo('جغرافيا', Icons.public, Color(0xFF10B981),
      ['عواصم', 'أعلام', 'عجائب الدنيا', 'تضاريس الأرض']),
  CategoryInfo('رياضة', Icons.sports_soccer, Color(0xFFF97316),
      ['كرة قدم', 'أساطير', 'الأولمبياد', 'كأس العالم']),
  CategoryInfo('ألغاز', Icons.extension, Color(0xFFEC4899),
      ['منطق', 'أحجيات', 'رياضيات', 'ذكاء بصري']),
  CategoryInfo('طعام', Icons.restaurant, Color(0xFF84CC16),
      ['أطباق عالمية', 'حلويات', 'توابل', 'فواكه نادرة']),
  CategoryInfo('أحياء القاهرة', Icons.location_city, Color(0xFF06B6D4),
      ['وسط البلد', 'المعادي والزمالك', 'الإسكندرية', 'مدن جديدة']),
  CategoryInfo('كلمات مصرية', Icons.chat_bubble, Color(0xFFA855F7),
      ['أمثال شعبية', 'كلمات قبطية', 'عامية قديمة', 'ألقاب ومسميات']),
  CategoryInfo('موسيقى وأغاني', Icons.music_note, Color(0xFFF43F5E),
      ['أغاني الزمن الجميل', 'فيروز وأم كلثوم', 'نجوم الـ 80s', 'مهرجانات']),
  CategoryInfo('سينما وتليفزيون', Icons.movie, Color(0xFFEAB308),
      ['أفلام الـ 90s', 'نجوم الشاشة', 'مسلسلات رمضان', 'كلاكيت زمان']),
];

const List<IconData> avatarIcons = [
  Icons.psychology,
  Icons.local_fire_department,
  Icons.star,
  Icons.workspace_premium,
  Icons.rocket_launch,
  Icons.diamond,
  Icons.bolt,
  Icons.shield,
  Icons.sports_esports,
  Icons.emoji_events,
  Icons.auto_awesome,
  Icons.pets,
];

const List<int> avatarIconCosts = [0, 0, 0, 0, 300, 300, 300, 300, 500, 500, 500, 500];

const List<Color> avatarColors = [
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF3B82F6),
  Color(0xFF22C55E),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFF97316),
  Color(0xFFE5E7EB),
];

const List<int> avatarColorCosts = [0, 0, 0, 0, 200, 200, 200, 200, 300];

String rankName(int level) {
  if (level >= 35) return 'أسطورة';
  if (level >= 20) return 'خبير';
  if (level >= 10) return 'محترف';
  if (level >= 5) return 'هاوي';
  return 'مبتدئ';
}

int xpNeeded(int level) => level * 1500;
