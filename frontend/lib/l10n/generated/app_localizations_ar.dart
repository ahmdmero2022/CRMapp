// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get create => 'إنشاء';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get none => 'بلا';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get appTitle => 'تطبيق إدارة العملاء';

  @override
  String get authTagline => 'تتبّع العملاء المحتملين، وأدر خط أنابيب مبيعاتك، وأغلق المزيد من الصفقات — كل ذلك في مكان واحد.';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navContacts => 'جهات الاتصال';

  @override
  String get navCompanies => 'الشركات';

  @override
  String get navLeads => 'العملاء المحتملون';

  @override
  String get navDeals => 'الصفقات';

  @override
  String get navTasks => 'المهام';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get navGroupOverview => 'نظرة عامة';

  @override
  String get navGroupSales => 'المبيعات';

  @override
  String get navGroupPeople => 'الأشخاص';

  @override
  String get navGroupWork => 'العمل';

  @override
  String get breadcrumbDetails => 'التفاصيل';

  @override
  String get sidebarCollapse => 'طي الشريط الجانبي';

  @override
  String get sidebarExpand => 'توسيع الشريط الجانبي';

  @override
  String get quickCreateTooltip => 'إنشاء سريع';

  @override
  String get quickCreateLead => 'عميل محتمل جديد';

  @override
  String get quickCreateCompany => 'شركة جديدة';

  @override
  String get quickCreateContact => 'جهة اتصال جديدة';

  @override
  String get quickCreateDeal => 'صفقة جديدة';

  @override
  String get quickCreateTask => 'مهمة جديدة';

  @override
  String get dealCreatedMessage => 'تم إنشاء الصفقة';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptySubtitle => 'أنت على اطلاع بكل شيء.';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول لإدارة خط أنابيب مبيعاتك وجهات اتصالك وصفقاتك.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordTooShort => '6 أحرف على الأقل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get createOneLink => 'أنشئ حسابًا';

  @override
  String get registerTitle => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'جهّز مساحة عملك في ثوانٍ معدودة.';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get alreadyHaveAccountPrompt => 'لديك حساب بالفعل؟';

  @override
  String get signInLink => 'تسجيل الدخول';

  @override
  String get settingsAppearanceSection => 'المظهر';

  @override
  String get themeTitle => 'السمة';

  @override
  String get themeSubtitle => 'اختر طريقة عرض التطبيق على هذا الجهاز.';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get languageSubtitle => 'اختر لغتك المفضلة.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsSecuritySection => 'الأمان';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String changePasswordSubtitleEmail(String email) {
    return 'تحديث كلمة المرور لحساب $email.';
  }

  @override
  String get changePasswordSubtitleGeneric => 'تحديث كلمة المرور لحسابك.';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get currentPasswordRequired => 'أدخل كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get updatePasswordButton => 'تحديث كلمة المرور';

  @override
  String get passwordUpdatedMessage => 'تم تحديث كلمة المرور';

  @override
  String get companiesTitle => 'الشركات';

  @override
  String get companiesSubtitle => 'المؤسسات التي تتعامل معها.';

  @override
  String get addCompany => 'إضافة شركة';

  @override
  String get editCompany => 'تعديل الشركة';

  @override
  String get searchCompaniesHint => 'ابحث في الشركات...';

  @override
  String get noCompaniesFound => 'لا توجد شركات';

  @override
  String get deleteCompanyTitle => 'حذف الشركة';

  @override
  String deleteCompanyMessage(String name) {
    return 'هل تريد حذف $name؟';
  }

  @override
  String get companyCreatedMessage => 'تم إنشاء الشركة';

  @override
  String get companyUpdatedMessage => 'تم تحديث الشركة';

  @override
  String get companyDeletedMessage => 'تم حذف الشركة';

  @override
  String get companyInfoTitle => 'بيانات الشركة';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String contactsWithCount(int count) {
    return 'جهات الاتصال ($count)';
  }

  @override
  String get noContactsYet => 'لا توجد جهات اتصال بعد.';

  @override
  String dealsWithCount(int count) {
    return 'الصفقات ($count)';
  }

  @override
  String get noDealsYetPlain => 'لا توجد صفقات بعد.';

  @override
  String get companyNameLabel => 'اسم الشركة';

  @override
  String get companyLabel => 'الشركة';

  @override
  String get industryLabel => 'القطاع';

  @override
  String get websiteLabel => 'الموقع الإلكتروني';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get addressLabel => 'العنوان';

  @override
  String contactsCountShort(int count) {
    return '$count جهة اتصال';
  }

  @override
  String dealsCountShort(int count) {
    return '$count صفقة';
  }

  @override
  String get contactsTitle => 'جهات الاتصال';

  @override
  String get contactsSubtitle => 'كل من تتعامل معهم في عملك.';

  @override
  String get addContact => 'إضافة جهة اتصال';

  @override
  String get editContact => 'تعديل جهة الاتصال';

  @override
  String get searchContactsHint => 'ابحث بالاسم أو البريد الإلكتروني...';

  @override
  String get noContactsFoundTitle => 'لا توجد جهات اتصال';

  @override
  String get noContactsFoundSubtitle => 'جرّب تعديل بحثك أو أضف جهة اتصال جديدة.';

  @override
  String get deleteContactTitle => 'حذف جهة الاتصال';

  @override
  String deleteContactMessage(String name) {
    return 'هل تريد حذف $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get contactCreatedMessage => 'تم إنشاء جهة الاتصال';

  @override
  String get contactUpdatedMessage => 'تم تحديث جهة الاتصال';

  @override
  String get contactDeletedMessage => 'تم حذف جهة الاتصال';

  @override
  String get contactInfoTitle => 'بيانات جهة الاتصال';

  @override
  String get firstNameLabel => 'الاسم الأول';

  @override
  String get lastNameLabel => 'اسم العائلة';

  @override
  String get jobTitleLabel => 'المسمى الوظيفي';

  @override
  String get dealsLabel => 'الصفقات';

  @override
  String get noDealsLinkedMessage => 'لا توجد صفقات مرتبطة بجهة الاتصال هذه بعد.';

  @override
  String get tasksLabel => 'المهام';

  @override
  String get addTaskLink => 'إضافة مهمة';

  @override
  String get noTasksYetMessage => 'لا توجد مهام بعد.';

  @override
  String get activityTimelineTitle => 'سجل النشاط';

  @override
  String get addNoteHint => 'أضف ملاحظة...';

  @override
  String get postButton => 'نشر';

  @override
  String get noActivityYetMessage => 'لا يوجد نشاط بعد.';

  @override
  String get someoneFallback => 'شخص ما';

  @override
  String get overviewTitle => 'نظرة عامة';

  @override
  String get overviewSubtitle => 'إليك ما يحدث في عملك اليوم.';

  @override
  String get statContacts => 'جهات الاتصال';

  @override
  String get statCompanies => 'الشركات';

  @override
  String get statOpenDeals => 'الصفقات المفتوحة';

  @override
  String pipelineValueSubtitle(String value) {
    return '$value في خط الأنابيب';
  }

  @override
  String get statWonRevenue => 'الإيرادات المكتسبة';

  @override
  String get statTotalLeads => 'إجمالي العملاء المحتملين';

  @override
  String get statTasksDueToday => 'مهام مستحقة اليوم';

  @override
  String get statOverdueTasks => 'مهام متأخرة';

  @override
  String get statConversionRate => 'معدل تحويل العملاء المحتملين';

  @override
  String get deltaVsLastMonth => 'مقارنة بالشهر الماضي';

  @override
  String get pipelineByStageTitle => 'خط الأنابيب حسب المرحلة';

  @override
  String get leadsByStatusTitle => 'العملاء المحتملون حسب الحالة';

  @override
  String get revenueTrendTitle => 'اتجاه الإيرادات';

  @override
  String get teamPerformanceTitle => 'أداء الفريق';

  @override
  String get teamPerformanceColumnMember => 'عضو الفريق';

  @override
  String get teamPerformanceColumnOpenDeals => 'مفتوحة';

  @override
  String get teamPerformanceColumnWonDeals => 'مكتسبة';

  @override
  String get teamPerformanceColumnWonValue => 'قيمة الصفقات المكتسبة';

  @override
  String get collapseSection => 'طي القسم';

  @override
  String get expandSection => 'توسيع القسم';

  @override
  String get recentActivityTitle => 'النشاط الأخير';

  @override
  String get upcomingTasksTitle => 'المهام القادمة';

  @override
  String get viewAllLink => 'عرض الكل';

  @override
  String get noDealsYetTitle => 'لا توجد صفقات بعد';

  @override
  String get noDealsYetSubtitle => 'ستظهر الصفقات هنا بمجرد إنشائها.';

  @override
  String get noRevenueYetTitle => 'لا توجد إيرادات بعد';

  @override
  String get noRevenueYetSubtitle => 'ستظهر الصفقات المكتسبة هنا بمجرد إغلاقها.';

  @override
  String get noLeadsYetTitle => 'لا يوجد عملاء محتملون بعد';

  @override
  String get noActivityYetTitle => 'لا يوجد نشاط بعد';

  @override
  String get allCaughtUpTitle => 'لا شيء معلّق!';

  @override
  String get justNowLabel => 'الآن';

  @override
  String minutesAgoLabel(int count) {
    return 'قبل $count د';
  }

  @override
  String hoursAgoLabel(int count) {
    return 'قبل $count س';
  }

  @override
  String daysAgoLabel(int count) {
    return 'قبل $count ي';
  }

  @override
  String get dealsPipelineTitle => 'خط أنابيب الصفقات';

  @override
  String get dealsPipelineSubtitle => 'اسحب البطاقات بين المراحل لتحديث التقدّم.';

  @override
  String get addDeal => 'إضافة صفقة';

  @override
  String get editDeal => 'تعديل الصفقة';

  @override
  String get dealTitleLabel => 'عنوان الصفقة';

  @override
  String get valueDollarLabel => 'القيمة (\$)';

  @override
  String get primaryContactLabel => 'جهة الاتصال الرئيسية';

  @override
  String get setExpectedCloseDate => 'تحديد تاريخ الإغلاق المتوقع';

  @override
  String closesOnLabel(String date) {
    return 'الإغلاق في $date';
  }

  @override
  String probabilityWithPercent(int percent) {
    return 'الاحتمالية: $percent%';
  }

  @override
  String get noDealsShort => 'لا توجد صفقات';

  @override
  String get deleteDealTitle => 'حذف الصفقة';

  @override
  String deleteDealMessage(String title) {
    return 'هل تريد حذف \"$title\"؟';
  }

  @override
  String get valueChipLabel => 'القيمة';

  @override
  String get probabilityChipLabel => 'الاحتمالية';

  @override
  String get statusChipLabel => 'الحالة';

  @override
  String get contactChipLabel => 'جهة الاتصال';

  @override
  String get expectedCloseChipLabel => 'الإغلاق المتوقع';

  @override
  String get activityLabel => 'النشاط';

  @override
  String get dealStatusOpen => 'مفتوحة';

  @override
  String get dealStatusWon => 'مكسوبة';

  @override
  String get dealStatusLost => 'خاسرة';

  @override
  String probabilityPercentSuffix(int percent) {
    return 'احتمالية $percent%';
  }

  @override
  String get leadsTitle => 'العملاء المحتملون';

  @override
  String get leadsSubtitle => 'عملاء محتملون بانتظار التأهيل.';

  @override
  String get noLeadsFoundTitle => 'لا يوجد عملاء محتملون';

  @override
  String get addLead => 'إضافة عميل محتمل';

  @override
  String get editLead => 'تعديل العميل المحتمل';

  @override
  String get allFilterLabel => 'الكل';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get sourceLabel => 'المصدر';

  @override
  String get sourceHint => 'مثال: الموقع الإلكتروني، إحالة';

  @override
  String get estimatedValueLabel => 'القيمة التقديرية (\$)';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get deleteLeadTitle => 'حذف العميل المحتمل';

  @override
  String deleteLeadMessage(String name) {
    return 'هل تريد حذف $name؟';
  }

  @override
  String get convertLeadTitle => 'تحويل العميل المحتمل';

  @override
  String convertLeadMessage(String name) {
    return 'هل تريد تحويل \"$name\" إلى جهة اتصال وصفقة جديدة في خط الأنابيب؟';
  }

  @override
  String get convertActionLabel => 'تحويل';

  @override
  String get leadConvertedMessage => 'تم تحويل العميل المحتمل إلى جهة اتصال وصفقة';

  @override
  String viaSourceLabel(String source) {
    return 'عبر $source';
  }

  @override
  String get leadCreatedMessage => 'تم إنشاء العميل المحتمل';

  @override
  String get leadUpdatedMessage => 'تم تحديث العميل المحتمل';

  @override
  String get leadStatusNew => 'جديد';

  @override
  String get leadStatusContacted => 'تم التواصل';

  @override
  String get leadStatusQualified => 'مؤهّل';

  @override
  String get leadStatusUnqualified => 'غير مؤهّل';

  @override
  String get leadStatusConverted => 'محوّل';

  @override
  String get tasksTitle => 'المهام';

  @override
  String get tasksSubtitle => 'تابع مهامك ومتابعاتك أولًا بأول.';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get pendingFilterLabel => 'قيد الانتظار';

  @override
  String get completedFilterLabel => 'مكتملة';

  @override
  String get noTasksFoundTitle => 'لا توجد مهام';

  @override
  String get deleteTaskTitle => 'حذف المهمة';

  @override
  String deleteTaskMessage(String title) {
    return 'هل تريد حذف \"$title\"؟';
  }

  @override
  String get taskCreatedMessage => 'تم إنشاء المهمة';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get setDueDate => 'تحديد تاريخ الاستحقاق';

  @override
  String get priorityLabel => 'الأولوية';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get searchTooltip => 'بحث';

  @override
  String get searchHint => 'ابحث في جهات الاتصال والشركات والعملاء المحتملين والصفقات والمهام...';

  @override
  String get searchEmptyTitle => 'ابحث في نظام إدارة العملاء';

  @override
  String get searchEmptySubtitle => 'اعثر على جهات الاتصال والشركات والعملاء المحتملين والصفقات والمهام في مكان واحد.';

  @override
  String get searchNoResultsTitle => 'لا توجد نتائج';

  @override
  String get searchNoResultsSubtitle => 'جرّب كلمة بحث مختلفة.';

  @override
  String get searchLeadsHint => 'ابحث في العملاء المحتملين...';

  @override
  String get searchTasksHint => 'ابحث في المهام...';

  @override
  String get sortByLabel => 'ترتيب حسب';

  @override
  String get sortDirectionTooltip => 'تبديل اتجاه الترتيب';

  @override
  String pageIndicatorLabel(int page, int totalPages) {
    return 'صفحة $page من $totalPages';
  }

  @override
  String get previousPageTooltip => 'الصفحة السابقة';

  @override
  String get nextPageTooltip => 'الصفحة التالية';

  @override
  String get createdAtLabel => 'تاريخ الإنشاء';

  @override
  String get listViewLabel => 'قائمة';

  @override
  String get boardViewLabel => 'لوحة';

  @override
  String get calendarViewLabel => 'التقويم';

  @override
  String get todayLabel => 'اليوم';

  @override
  String moreTasksLabel(int count) {
    return '+$count أخرى';
  }
}
