import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CRM App'**
  String get appTitle;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Track leads, manage your pipeline, and close more deals — all in one place.'**
  String get authTagline;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get navContacts;

  /// No description provided for @navCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get navCompanies;

  /// No description provided for @navLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get navLeads;

  /// No description provided for @navDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get navDeals;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your pipeline, contacts, and deals.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @createOneLink.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOneLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your workspace in a few seconds.'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how the CRM looks on this device.'**
  String get themeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language.'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecuritySection;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitleEmail.
  ///
  /// In en, this message translates to:
  /// **'Update the password for {email}.'**
  String changePasswordSubtitleEmail(String email);

  /// No description provided for @changePasswordSubtitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Update the password for your account.'**
  String get changePasswordSubtitleGeneric;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @updatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordButton;

  /// No description provided for @passwordUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdatedMessage;

  /// No description provided for @companiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companiesTitle;

  /// No description provided for @companiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organizations you work with.'**
  String get companiesSubtitle;

  /// No description provided for @addCompany.
  ///
  /// In en, this message translates to:
  /// **'Add Company'**
  String get addCompany;

  /// No description provided for @editCompany.
  ///
  /// In en, this message translates to:
  /// **'Edit Company'**
  String get editCompany;

  /// No description provided for @searchCompaniesHint.
  ///
  /// In en, this message translates to:
  /// **'Search companies...'**
  String get searchCompaniesHint;

  /// No description provided for @noCompaniesFound.
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No description provided for @deleteCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete company'**
  String get deleteCompanyTitle;

  /// No description provided for @deleteCompanyMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteCompanyMessage(String name);

  /// No description provided for @companyCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Company created'**
  String get companyCreatedMessage;

  /// No description provided for @companyUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Company updated'**
  String get companyUpdatedMessage;

  /// No description provided for @companyDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Company deleted'**
  String get companyDeletedMessage;

  /// No description provided for @companyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get companyInfoTitle;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @contactsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Contacts ({count})'**
  String contactsWithCount(int count);

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.'**
  String get noContactsYet;

  /// No description provided for @dealsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Deals ({count})'**
  String dealsWithCount(int count);

  /// No description provided for @noDealsYetPlain.
  ///
  /// In en, this message translates to:
  /// **'No deals yet.'**
  String get noDealsYetPlain;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @companyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// No description provided for @industryLabel.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industryLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @contactsCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts'**
  String contactsCountShort(int count);

  /// No description provided for @dealsCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count} deals'**
  String dealsCountShort(int count);

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone you do business with.'**
  String get contactsSubtitle;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @searchContactsHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts by name or email...'**
  String get searchContactsHint;

  /// No description provided for @noContactsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFoundTitle;

  /// No description provided for @noContactsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or add a new contact.'**
  String get noContactsFoundSubtitle;

  /// No description provided for @deleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get deleteContactTitle;

  /// No description provided for @deleteContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String deleteContactMessage(String name);

  /// No description provided for @contactCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Contact created'**
  String get contactCreatedMessage;

  /// No description provided for @contactUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Contact updated'**
  String get contactUpdatedMessage;

  /// No description provided for @contactDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeletedMessage;

  /// No description provided for @contactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfoTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleLabel;

  /// No description provided for @dealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsLabel;

  /// No description provided for @noDealsLinkedMessage.
  ///
  /// In en, this message translates to:
  /// **'No deals linked to this contact yet.'**
  String get noDealsLinkedMessage;

  /// No description provided for @tasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksLabel;

  /// No description provided for @addTaskLink.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTaskLink;

  /// No description provided for @noTasksYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get noTasksYetMessage;

  /// No description provided for @activityTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Timeline'**
  String get activityTimelineTitle;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNoteHint;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @noActivityYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get noActivityYetMessage;

  /// No description provided for @someoneFallback.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someoneFallback;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening with your business today.'**
  String get overviewSubtitle;

  /// No description provided for @statContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get statContacts;

  /// No description provided for @statCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get statCompanies;

  /// No description provided for @statOpenDeals.
  ///
  /// In en, this message translates to:
  /// **'Open Deals'**
  String get statOpenDeals;

  /// No description provided for @pipelineValueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{value} pipeline'**
  String pipelineValueSubtitle(String value);

  /// No description provided for @statWonRevenue.
  ///
  /// In en, this message translates to:
  /// **'Won Revenue'**
  String get statWonRevenue;

  /// No description provided for @statTotalLeads.
  ///
  /// In en, this message translates to:
  /// **'Total Leads'**
  String get statTotalLeads;

  /// No description provided for @statTasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks Due Today'**
  String get statTasksDueToday;

  /// No description provided for @statOverdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue Tasks'**
  String get statOverdueTasks;

  /// No description provided for @pipelineByStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Pipeline by Stage'**
  String get pipelineByStageTitle;

  /// No description provided for @leadsByStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Leads by Status'**
  String get leadsByStatusTitle;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @upcomingTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tasks'**
  String get upcomingTasksTitle;

  /// No description provided for @viewAllLink.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllLink;

  /// No description provided for @noDealsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No deals yet'**
  String get noDealsYetTitle;

  /// No description provided for @noDealsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deals will appear here once you create some.'**
  String get noDealsYetSubtitle;

  /// No description provided for @noLeadsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No leads yet'**
  String get noLeadsYetTitle;

  /// No description provided for @noActivityYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYetTitle;

  /// No description provided for @allCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUpTitle;

  /// No description provided for @justNowLabel.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNowLabel;

  /// No description provided for @minutesAgoLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgoLabel(int count);

  /// No description provided for @hoursAgoLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgoLabel(int count);

  /// No description provided for @daysAgoLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgoLabel(int count);

  /// No description provided for @dealsPipelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals Pipeline'**
  String get dealsPipelineTitle;

  /// No description provided for @dealsPipelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag cards between stages to update progress.'**
  String get dealsPipelineSubtitle;

  /// No description provided for @addDeal.
  ///
  /// In en, this message translates to:
  /// **'Add Deal'**
  String get addDeal;

  /// No description provided for @editDeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Deal'**
  String get editDeal;

  /// No description provided for @dealTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Deal title'**
  String get dealTitleLabel;

  /// No description provided for @valueDollarLabel.
  ///
  /// In en, this message translates to:
  /// **'Value (\$)'**
  String get valueDollarLabel;

  /// No description provided for @primaryContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary contact'**
  String get primaryContactLabel;

  /// No description provided for @setExpectedCloseDate.
  ///
  /// In en, this message translates to:
  /// **'Set expected close date'**
  String get setExpectedCloseDate;

  /// No description provided for @closesOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Closes {date}'**
  String closesOnLabel(String date);

  /// No description provided for @probabilityWithPercent.
  ///
  /// In en, this message translates to:
  /// **'Probability: {percent}%'**
  String probabilityWithPercent(int percent);

  /// No description provided for @noDealsShort.
  ///
  /// In en, this message translates to:
  /// **'No deals'**
  String get noDealsShort;

  /// No description provided for @deleteDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete deal'**
  String get deleteDealTitle;

  /// No description provided for @deleteDealMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteDealMessage(String title);

  /// No description provided for @valueChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueChipLabel;

  /// No description provided for @probabilityChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get probabilityChipLabel;

  /// No description provided for @statusChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusChipLabel;

  /// No description provided for @contactChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactChipLabel;

  /// No description provided for @expectedCloseChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected close'**
  String get expectedCloseChipLabel;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @dealStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dealStatusOpen;

  /// No description provided for @dealStatusWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get dealStatusWon;

  /// No description provided for @dealStatusLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get dealStatusLost;

  /// No description provided for @probabilityPercentSuffix.
  ///
  /// In en, this message translates to:
  /// **'{percent}% probability'**
  String probabilityPercentSuffix(int percent);

  /// No description provided for @leadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leadsTitle;

  /// No description provided for @leadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prospects waiting to be qualified.'**
  String get leadsSubtitle;

  /// No description provided for @noLeadsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No leads found'**
  String get noLeadsFoundTitle;

  /// No description provided for @addLead.
  ///
  /// In en, this message translates to:
  /// **'Add Lead'**
  String get addLead;

  /// No description provided for @editLead.
  ///
  /// In en, this message translates to:
  /// **'Edit Lead'**
  String get editLead;

  /// No description provided for @allFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilterLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @sourceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Website, Referral'**
  String get sourceHint;

  /// No description provided for @estimatedValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated value (\$)'**
  String get estimatedValueLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @deleteLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete lead'**
  String get deleteLeadTitle;

  /// No description provided for @deleteLeadMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteLeadMessage(String name);

  /// No description provided for @convertLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert lead'**
  String get convertLeadTitle;

  /// No description provided for @convertLeadMessage.
  ///
  /// In en, this message translates to:
  /// **'Convert \"{name}\" into a contact and a new deal in the pipeline?'**
  String convertLeadMessage(String name);

  /// No description provided for @convertActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertActionLabel;

  /// No description provided for @leadConvertedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lead converted to contact + deal'**
  String get leadConvertedMessage;

  /// No description provided for @viaSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'via {source}'**
  String viaSourceLabel(String source);

  /// No description provided for @leadCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lead created'**
  String get leadCreatedMessage;

  /// No description provided for @leadUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Lead updated'**
  String get leadUpdatedMessage;

  /// No description provided for @leadStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get leadStatusNew;

  /// No description provided for @leadStatusContacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get leadStatusContacted;

  /// No description provided for @leadStatusQualified.
  ///
  /// In en, this message translates to:
  /// **'Qualified'**
  String get leadStatusQualified;

  /// No description provided for @leadStatusUnqualified.
  ///
  /// In en, this message translates to:
  /// **'Unqualified'**
  String get leadStatusUnqualified;

  /// No description provided for @leadStatusConverted.
  ///
  /// In en, this message translates to:
  /// **'Converted'**
  String get leadStatusConverted;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your follow-ups.'**
  String get tasksSubtitle;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @pendingFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingFilterLabel;

  /// No description provided for @completedFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedFilterLabel;

  /// No description provided for @noTasksFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFoundTitle;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteTaskMessage(String title);

  /// No description provided for @taskCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get taskCreatedMessage;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @setDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set due date'**
  String get setDueDate;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts, companies, leads, deals, tasks...'**
  String get searchHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your CRM'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find contacts, companies, leads, deals, and tasks in one place.'**
  String get searchEmptySubtitle;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchLeadsHint.
  ///
  /// In en, this message translates to:
  /// **'Search leads...'**
  String get searchLeadsHint;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasksHint;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortByLabel;

  /// No description provided for @sortDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle sort direction'**
  String get sortDirectionTooltip;

  /// No description provided for @pageIndicatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {totalPages}'**
  String pageIndicatorLabel(int page, int totalPages);

  /// No description provided for @previousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPageTooltip;

  /// No description provided for @nextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPageTooltip;

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAtLabel;

  /// No description provided for @listViewLabel.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listViewLabel;

  /// No description provided for @boardViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardViewLabel;

  /// No description provided for @calendarViewLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarViewLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @moreTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreTasksLabel(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
