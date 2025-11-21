import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'دليلك الدراسي';

  // Major data
  static const List<Map<String, dynamic>> majors = [
    {
      'name': 'الهندسة المدنية',
      'image': 'assets/images/Civil Engineering.jpg',
      'description':
          'الهندسة المدنية هي أحد فروع الهندسة التي تتخصص في تصميم وتنفيذ المنشآت والبنى التحتية مثل الطرق والجسور والمباني والسدود والمطارات والموانئ. يدرس الطالب في هذا التخصص كيفية استخدام المواد الهندسية بشكل فعال وآمن لإنشاء مشاريع عمرانية مستدامة.',
      'requirements':
          'دراسة الرياضيات والفيزياء بشكل متقدم، والقدرة على التحليل والتصميم، والمهارات التقنية في استخدام البرمجيات الهندسية.',
      'careers':
          'مهندس مدني، مهندس إنشاءات، مهندس طرق وجسور، مهندس بيئة، مستشار هندسي، إدارة المشاريع الهندسية.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/1/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A%D8%A9.pdf',
    },
    {
      'name': 'الهندسة الميكانيكية',
      'image': 'assets/images/Mechanical Engineering.jpg',
      'description':
          'الهندسة الميكانيكية هي أحد أوسع فروع الهندسة التي تتناول تصميم وتطوير وتصنيع النظم الميكانيكية والآلات. تشمل مجالات الدراسة الديناميكا والديناميكا الحرارية ومواد الهندسة والتصميم الميكانيكي والروبوتات.',
      'requirements':
          'مهارات رياضية وفيزيائية قوية، التفكير التحليلي، القدرة على تصميم النظم المعقدة، معرفة ببرامج التصميم الميكانيكي.',
      'careers':
          'مهندس ميكانيكي، مهندس تصنيع، مهندس صيانة، مهندس روافع، مهندس أنظمة الطاقة، مهندس سيارات.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/5/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D9%8A%D9%83%D8%A7%D9%86%D9%8A%D9%83%D9%8A%D8%A9.pdf',
    },
    {
      'name': 'الهندسة الكهربائية',
      'image': 'assets/images/Electrical Engineering.jpg',
      'description':
          'الهندسة الكهربائية تهتم بدراسة وتطبيق الكهرباء والإلكترونيات والكهرومغناطيسية. تشمل مجالات الدراسة نظم الطاقة الكهربائية، الإلكترونيات، الاتصالات، نظم التحكم والسيبرناطيقا.',
      'requirements':
          'قدرة عالية في الرياضيات والفيزياء، فهم عميق للمبادئ الكهربائية، مهارات البرمجة، إتقان برامج المحاكاة والتصميم.',
      'careers':
          'مهندس كهربائي، مهندس أنظمة الطاقة، مهندس إلكترونيات، مهندس اتصالات، مهندس تحكم، مهندس أمن المعلومات.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/3/Electrical%20Courses%20%20Syllabus.pdf',
    },
    {
      'name': 'الهندسة الصناعية',
      'image': 'assets/images/Industrial Engineering.jpg',
      'description':
          'الهندسة الصناعية تركز على تحسين النظم المعقدة والعمليات والمنظمات. تعمل على تطوير النظم المتكاملة من الناس والمواد والمعلومات والمعدات والطاقة.',
      'requirements':
          'مهارات تحليلية قوية، فهم عمليات الإنتاج، القدرة على تحسين النظم، مهارات إدارة المشاريع، إتقان أدوات التحليل الإحصائي.',
      'careers':
          'مهندس صناعي، مهندس جودة، مهندس عمليات، مهندس سلسلة التوريد، محلل نظم، مستشار إداري.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/2/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D8%B5%D9%86%D8%A7%D8%B9%D9%8A%D8%A9.pdf',
    },
    {
      'name': 'هندسة التعدين',
      'image': 'assets/images/Mining Engineering.jpg',
      'description':
          'هندسة التعدين تهتم بالبحث والتطوير في مجال استخراج المعادن والمعالجة. تشمل دراسة مواقع المناجم، استخراج المعادن، معالجة الخامات، السلامة في المناجم، وإدارة الموارد الطبيعية.',
      'requirements':
          'معرفة بعلوم الأرض والجيولوجيا، فهم عمليات الاستخراج، السلامة المهنية، إدارة المخاطر، مهارات بيئية.',
      'careers':
          'مهندس تعدين، مهندس جيولوجيا، مهندس صيانة مناجم، أخصائي سلامة، مهندس بيئة تعدينية، مدير موارد طبيعية.',
      'planLink': 'https://uob.edu.sa/ar/content.php?id=26',
    },
    {
      'name': 'هندسة الطاقة ',
      'image': 'assets/images/Renewable Energy Engineering.jpg',
      'description':
          'هندسة الطاقة المتجددة تختص بتصميم وتطوير أنظمة الطاقة النظيفة مثل الطاقة الشمسية وطاقة الرياح والطاقة المائية والحيوية. تركز على الاستدامة وتقليل الاعتماد على الوقود الأحفوري.',
      'requirements':
          'خلفية قوية في الفيزياء والكيمياء، فهم أنظمة الطاقة، مهارات تصميم النظم الكهربائية، الوعي البيئي.',
      'careers':
          'مهندس طاقة متجددة، مهندس أنظمة شمسية، مهندس توربينات رياح، مستشار طاقة، مهندس استدامة، باحث في الطاقة النظيفة.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/4/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D8%B7%D8%A7%D9%82%D8%A9%20%D8%A7%D9%84%D9%85%D8%AA%D8%AC%D8%AF%D8%AF%D8%A9.pdf',
    },
    {
      'name': 'الهندسة المعمارية',
      'image': 'assets/images/Architectural Engineering.jpg',
      'description':
          'الهندسة المعمارية تجمع بين الفن والهندسة لتصميم المباني والمنشآت. تتناول التصميم الإنشائي والتخطيط المعماري والاستدامة والتكامل البيئي للمباني.',
      'requirements':
          'مهارات تصميمية وإبداعية، فهم المعايير الإنشائية، إتقان برامج التصميم المعماري، الوعي الجمالي والبيئي.',
      'careers':
          'مهندس معماري، مهندس إنشاءات، مصمم مباني مستدامة، مستشار هندسي معماري، مخطط حضري، مدير مشاريع عمرانية.',
      'planLink':
          'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/6/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D8%B9%D9%85%D8%A7%D8%B1%D9%8A%D8%A9.pdf',
    },
  ];

  // Quiz questions
  static const List<Map<String, dynamic>> quizQuestions = [
    {
      'question': 'ما هي المواد الدراسية التي تفضل العمل عليها؟',
      'options': [
        'الرياضيات والتحليل',
        'الفيزياء والالكترونيات',
        'التصميم والإبداع',
        'الإدارة والتخطيط',
      ],
    },
    {
      'question': 'ماذا تفضل في العمل؟',
      'options': [
        'تصميم مباني وهياكل',
        'صنع الآلات والأنظمة',
        'برمجة وتحليل البيانات',
        'تحسين العمليات',
      ],
    },
    {
      'question': 'ما هو اهتمامك الأساسي؟',
      'options': [
        'الاستدامة والبيئة',
        'التصنيع والإنتاج',
        'التقنيات الحديثة',
        'الإدارة والتنظيم',
      ],
    },
    {
      'question': 'كيف تتعامل مع التحديات؟',
      'options': [
        'حل المشكلات المعقدة',
        'الابتكار والتطوير',
        'التخطيط المسبق',
        'العمل الجماعي',
      ],
    },
    {
      'question': 'ما نوع المشاريع التي تجذبك؟',
      'options': [
        'مشاريع كبيرة وضخمة',
        'أنظمة مبتكرة',
        'تطوير مستمر',
        'تحسين الكفاءة',
      ],
    },
    {
      'question': 'ما هي نقاط قوتك؟',
      'options': [
        'التحليل الدقيق',
        'الإبداع والابتكار',
        'التفكير الاستراتيجي',
        'التنظيم والإدارة',
      ],
    },
    {
      'question': 'ما هو مجالك المفضل للعمل؟',
      'options': [
        'تشييد المباني',
        'صناعة الآلات',
        'الطاقة والكهرباء',
        'تحسين النظم',
      ],
    },
    {
      'question': 'كيف تفضل العمل؟',
      'options': [
        'في فريق كبير',
        'بشكل مستقل',
        'مع أجهزة الحاسوب',
        'مع البيانات والأرقام',
      ],
    },
    {
      'question': 'ما هو هدفك المهني؟',
      'options': [
        'بناء البنية التحتية',
        'صناعة المستقبل',
        'تطوير التقنيات',
        'تحسين الإنتاجية',
      ],
    },
    {
      'question': 'ما الذي يهمك في التخصص؟',
      'options': [
        'التطبيق العملي',
        'الابتكار التقني',
        'التطوير المستمر',
        'الكفاءة الاقتصادية',
      ],
    },
    {
      'question': 'ما هو نوع البيئة التي تفضلها؟',
      'options': [
        'المواقع الإنشائية',
        'المختبرات التكنولوجية',
        'الأماكن المكتبية',
        'مناطق الإنتاج',
      ],
    },
    {
      'question': 'ما هي مهارتك الأساسية؟',
      'options': [
        'الرسم والتخطيط',
        'البرمجة والحوسبة',
        'التحليل الهندسي',
        'إدارة العمليات',
      ],
    },
    {
      'question': 'ما هي اهتماماتك الجانبية؟',
      'options': [
        'التصميم والفن',
        'العلوم والتكنولوجيا',
        'الرياضيات والإحصائيات',
        'الإدارة والقيادة',
      ],
    },
    {
      'question': 'كيف ترى مستقبل الهندسة؟',
      'options': [
        'بناء مدن ذكية',
        'تقنيات مستقبلية',
        'طاقة نظيفة',
        'نظم متطورة',
      ],
    },
    {
      'question': 'ما هو حلمك في المهنة؟',
      'options': [
        'بناء مشاريع ضخمة',
        'ابتكار تقنيات جديدة',
        'تطوير أنظمة حديثة',
        'قيادة فرق العمل',
      ],
    },
  ];

  // Theme
  static ThemeData getTheme() {
    return ThemeData(
      // fontFamily: 'Cairo', // Uncomment when font files are added
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF004AAD),
        secondary: Color(0xFFB3E5FC),
        surface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004AAD),
        ),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 18),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004AAD),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
