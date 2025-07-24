import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ko.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale);

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
  ];

  // Common
  String get appName;
  String get ok;
  String get cancel;
  String get confirm;
  String get delete;
  String get edit;
  String get save;
  String get close;
  String get back;
  String get next;
  String get previous;
  String get retry;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get info;

  // Authentication
  String get login;
  String get logout;
  String get signup;
  String get email;
  String get password;
  String get confirmPassword;
  String get phoneNumber;
  String get verificationCode;
  String get forgotPassword;
  String get resetPassword;
  String get loginWithKakao;
  String get loginWithGoogle;
  String get loginWithApple;
  String get agreeToTerms;
  String get termsOfService;
  String get privacyPolicy;

  // Profile
  String get profile;
  String get editProfile;
  String get name;
  String get age;
  String get location;
  String get occupation;
  String get bio;
  String get photos;
  String get addPhoto;
  String get removePhoto;
  String get profileVerification;
  String get verified;
  String get notVerified;

  // Home & Matching
  String get home;
  String get matching;
  String get filter;
  String get distance;
  String get region;
  String get popularity;
  String get vipFilter;
  String get like;
  String get pass;
  String get superChat;
  String get noMoreProfiles;
  String get todayRecommendations;

  // Likes
  String get likes;
  String get receivedLikes;
  String get sentLikes;
  String get superChats;
  String get matches;
  String get likeYou;
  String get youLike;

  // VIP
  String get vip;
  String get premium;
  String get todayVip;
  String get vipPlans;
  String get vipBenefits;
  String get unlimitedLikes;
  String get priorityDisplay;
  String get readReceipts;
  String get advancedFilters;

  // Chat
  String get chat;
  String get chats;
  String get messages;
  String get typeMessage;
  String get sendMessage;
  String get chatList;
  String get newMatch;
  String get online;
  String get offline;
  String get lastSeen;

  // Points
  String get points;
  String get pointShop;
  String get pointHistory;
  String get purchasePoints;
  String get currentPoints;
  String get freePoints;
  String get earnPoints;
  String get spendPoints;

  // Settings
  String get settings;
  String get notifications;
  String get notificationSettings;
  String get pushNotifications;
  String get likeNotifications;
  String get chatNotifications;
  String get matchNotifications;
  String get marketingNotifications;
  String get account;
  String get accountSettings;
  String get blockList;
  String get blockedUsers;
  String get reportUser;
  String get deleteAccount;

  // Support
  String get support;
  String get faq;
  String get contactUs;
  String get inquiry;
  String get notice;
  String get announcements;
  String get version;
  String get aboutApp;

  // Validation Messages
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get passwordTooShort;
  String get passwordMismatch;
  String get phoneRequired;
  String get phoneInvalid;
  String get nameRequired;
  String get ageRequired;
  String get locationRequired;

  // Error Messages
  String get networkError;
  String get serverError;
  String get unknownError;
  String get timeoutError;
  String get unauthorizedError;
  String get forbiddenError;
  String get notFoundError;

  // Success Messages
  String get loginSuccess;
  String get signupSuccess;
  String get profileUpdateSuccess;
  String get likeSuccess;
  String get superChatSuccess;
  String get messageSuccess;

  // Action Messages
  String get confirmDelete;
  String get confirmLogout;
  String get confirmBlock;
  String get confirmReport;
  String get areYouSure;
  String get cannotUndo;

  // Date & Time
  String get today;
  String get yesterday;
  String get thisWeek;
  String get thisMonth;
  String get ago;
  String get justNow;
  String get minutesAgo;
  String get hoursAgo;
  String get daysAgo;

  // Units
  String get km;
  String get years;
  String get yearsOld;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'ko': return SKo();
  }
  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}