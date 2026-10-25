// ARTICLES FOR THE "LEARN" TAB
//
// This is the file where you write your own texts.
// Each article has:
//   emoji    — the picture on the card
//   color    — card color (0xFF + a color code)
//   minutes  — how long it takes to read
//   title    — the name in English ('en') and Russian ('ru')
//   body     — the text. Put an empty line (\n\n) between paragraphs.
//              A line that starts with "# " becomes a small heading.
//
// The texts below are short examples. Replace them with yours.
// To add a new article, copy one block from "Article(" to "),"
// and change the text.

class Article {
  const Article({
    required this.id,
    required this.emoji,
    required this.color,
    required this.minutes,
    required this.title,
    required this.body,
  });

  final String id;
  final String emoji;
  final int color;
  final int minutes;
  final Map<String, String> title;
  final Map<String, String> body;

  String titleIn(String lang) => title[lang] ?? title['en'] ?? '';
  String bodyIn(String lang) => body[lang] ?? body['en'] ?? '';
}

const articles = <Article>[
  Article(
    id: 'body',
    emoji: '🌱',
    color: 0xFFFF8A3D,
    minutes: 3,
    title: {
      'en': 'Your body is changing',
      'ru': 'Твоё тело меняется',
    },
    body: {
      'en': 'Puberty is the time when your body grows from a child\'s body to an adult\'s body. It usually starts between 8 and 14 years old.\n\n'
          'Everyone starts at a different time. If your friends change earlier or later than you, it is normal.\n\n'
          '# Why does it happen?\n\n'
          'Your body starts to make hormones. Hormones are messengers that tell your body to grow and change.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Пубертат — это время, когда тело растёт и из детского становится взрослым. Обычно он начинается в 8–14 лет.\n\n'
          'У всех он начинается в разное время. Если друзья меняются раньше или позже тебя, это нормально.\n\n'
          '# Почему это происходит?\n\n'
          'Организм начинает вырабатывать гормоны. Гормоны — это «посыльные», которые говорят телу расти и меняться.\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
  Article(
    id: 'sleep',
    emoji: '😴',
    color: 0xFF5AA9E6,
    minutes: 2,
    title: {
      'en': 'Why teens need more sleep',
      'ru': 'Почему подросткам нужно больше сна',
    },
    body: {
      'en': 'Teens need 8–10 hours of sleep every night. Sleep helps your body grow and your brain remember what you learned.\n\n'
          'In the teen years, your body clock moves later. That is why it is hard to fall asleep early.\n\n'
          '# Simple tips\n\n'
          'Put your phone away 1 hour before bed. Go to bed at the same time every day.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Подросткам нужно 8–10 часов сна каждую ночь. Сон помогает телу расти, а мозгу — запоминать то, что ты выучил(а).\n\n'
          'В подростковом возрасте внутренние часы сдвигаются позже. Поэтому трудно уснуть рано.\n\n'
          '# Простые советы\n\n'
          'Убирай телефон за час до сна. Ложись в одно и то же время каждый день.\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
  Article(
    id: 'emotions',
    emoji: '🎭',
    color: 0xFF9B7FE0,
    minutes: 2,
    title: {
      'en': 'Mood swings are normal',
      'ru': 'Перепады настроения — это нормально',
    },
    body: {
      'en': 'Sometimes you feel happy, and an hour later you feel sad or angry. This is very common for teens.\n\n'
          'Hormones, sleep, school and friends can all change your mood.\n\n'
          '# What can help\n\n'
          'Notice how you feel and give the feeling a name. Use the mood check-in on the Today tab.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Иногда ты радуешься, а через час грустишь или злишься. Для подростков это очень частая ситуация.\n\n'
          'На настроение влияют гормоны, сон, учёба и друзья.\n\n'
          '# Что может помочь\n\n'
          'Замечай, что ты чувствуешь, и называй это чувство. Отмечай настроение во вкладке «Сегодня».\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
  Article(
    id: 'stress',
    emoji: '🌊',
    color: 0xFF6CBF4B,
    minutes: 2,
    title: {
      'en': 'What is stress?',
      'ru': 'Что такое стресс?',
    },
    body: {
      'en': 'Stress is how your body reacts to something hard, like a test or an argument.\n\n'
          'A little stress can help you focus. Too much stress for a long time is not good for you.\n\n'
          '# What can help\n\n'
          'Slow breathing, a short walk, or talking to someone you trust. Try the exercises in the Relax tab.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Стресс — это реакция организма на что-то трудное, например контрольную или ссору.\n\n'
          'Немного стресса помогает собраться. Но сильный стресс долгое время вредит.\n\n'
          '# Что может помочь\n\n'
          'Медленное дыхание, короткая прогулка или разговор с человеком, которому доверяешь. Попробуй упражнения во вкладке «Отдых».\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
  Article(
    id: 'food',
    emoji: '🥗',
    color: 0xFFF28DA8,
    minutes: 2,
    title: {
      'en': 'Food and sport',
      'ru': 'Еда и спорт',
    },
    body: {
      'en': 'Your body grows fast, so it needs good food and movement.\n\n'
          'Try to eat fruit and vegetables every day and drink enough water.\n\n'
          '# Move more\n\n'
          'Teens need about 60 minutes of activity a day. Walking, dancing and playing games all count.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Тело быстро растёт, поэтому ему нужны хорошая еда и движение.\n\n'
          'Старайся каждый день есть фрукты и овощи и пить достаточно воды.\n\n'
          '# Больше двигайся\n\n'
          'Подросткам нужно около 60 минут активности в день. Прогулки, танцы и игры тоже считаются.\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
  Article(
    id: 'focus',
    emoji: '🧠',
    color: 0xFFFFB340,
    minutes: 2,
    title: {
      'en': 'Focus and school',
      'ru': 'Концентрация и учёба',
    },
    body: {
      'en': 'It is hard to focus when you are tired, hungry or stressed.\n\n'
          'Good sleep, short breaks and fewer notifications help your brain work better.\n\n'
          '# Try this\n\n'
          'Study for 25 minutes, then take a 5-minute break. Put your phone in another room.\n\n'
          '(Example text. Write your own text here.)',
      'ru': 'Трудно сосредоточиться, когда ты устал(а), голоден(на) или нервничаешь.\n\n'
          'Хороший сон, короткие перерывы и меньше уведомлений помогают мозгу работать лучше.\n\n'
          '# Попробуй так\n\n'
          'Занимайся 25 минут, потом отдыхай 5 минут. Положи телефон в другой комнате.\n\n'
          '(Пример текста. Напиши здесь свой.)',
    },
  ),
];
