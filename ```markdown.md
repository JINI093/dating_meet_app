```markdown
. 📂 lib
└── 📂 core/
│  └── 📂 constants/
│    ├── 📄 api_constants.dart
│    ├── 📄 app_constants.dart(완료)
│  └── 📂 network/
│    ├── 📄 api_client.dart
│    ├── 📄 api_endpoints.dart
│    ├── 📄 interceptors.dart
└── 📂 generated/
└── 📂 l10n/
│  ├── 📄 app_localizations.dart(완료)
│  ├── 📄 app_localizations_en.dart(완료)
│  ├── 📄 app_localizations_ko.dart(완료)
├── 📄 main.dart
└── 📂 models/
│  ├── 📄 chat_model.dart
│  ├── 📄 match_model.dart
│  ├── 📄 notification_model.dart
│  ├── 📄 profile_model.dart(완료)
│  ├── 📄 profile_model.g.dart(완료)
│  ├── 📄 user_model.dart
│  ├── 📄 vip_model.dart
└── 📂 providers/
│  ├── 📄 chat_provider.dart
│  ├── 📄 match_provider.dart
│  ├── 📄 notification_provider.dart
│  ├── 📄 user_provider.dart
│  ├── 📄 vip_provider.dart
└── 📂 routes/
│  ├── 📄 app_router.dart
│  ├── 📄 route_names.dart
└── 📂 screens/
│  └── 📂 auth/
│    ├── 📄 login_screen.dart
│    ├── 📄 phone_verification_screen.dart
│    ├── 📄 signup_complete_screen.dart
│    ├── 📄 signup_screen.dart
│    ├── 📄 terms_screen.dart
│  └── 📂 bottom_navigation/
│    ├── 📄 bottom_navigation_screen.dart
│    ├── 📄 bottom_navigation_widget.dart
│  └── 📂 chat/
│    ├── 📄 chat_list_screen.dart
│    ├── 📄 chat_room_screen.dart
│    └── 📂 widgets/
│      ├── 📄 chat_bubble.dart
│      ├── 📄 chat_input.dart
│  └── 📂 common/
│    ├── 📄 maintenance_screen.dart
│  └── 📂 error/
│    ├── 📄 not_found_screen.dart
│  └── 📂 faq/
│    ├── 📄 faq_list_screen.dart
│  └── 📂 home/
│    ├── 📄 main_screen.dart
│    ├── 📄 matching_screen.dart
│    └── 📂 widgets/
│      ├── 📄 filter_bar.dart
│      ├── 📄 match_actions.dart
│      ├── 📄 profile_card.dart
│  └── 📂 likes/
│    ├── 📄 likes_screen.dart
│    ├── 📄 received_likes_screen.dart
│    ├── 📄 sent_likes_screen.dart
│    ├── 📄 super_chat_screen.dart
│  └── 📂 notice/
│    ├── 📄 notice_detail_screen.dart
│    ├── 📄 notice_edit_screen.dart
│    ├── 📄 notice_list_screen.dart
│  └── 📂 onboarding/
│    ├── 📄 intro_screen.dart
│    ├── 📄 profile_complete_screen.dart
│    ├── 📄 profile_setup_screen.dart
│  └── 📂 point/
│    ├── 📄 point_history_screen.dart
│    ├── 📄 point_settings_screen.dart
│    ├── 📄 point_shop_screen.dart
│    ├── 📄 purchase_screen.dart
│    ├── 📄 withdrawal_screen.dart
│  └── 📂 privacy/
│    ├── 📄 privacy_list_screen.dart
│  └── 📂 profile/
│    ├── 📄 edit_profile_screen.dart
│    ├── 📄 my_profile_screen.dart
│    ├── 📄 other_profile_screen.dart
│    ├── 📄 profile_verification_screen.dart
│  └── 📂 settings/
│    ├── 📄 account_settings_screen.dart
│    ├── 📄 block_list_screen.dart
│    ├── 📄 notification_settings_screen.dart
│    ├── 📄 settings_screen.dart
│  └── 📂 splash/
│    ├── 📄 splash_screen.dart
│  └── 📂 support/
│    ├── 📄 inquiry_screen.dart
│  └── 📂 ticket/
│    ├── 📄 ticket_settings_screen.dart
│  └── 📂 users/
│    ├── 📄 user_detail_screen.dart
│    ├── 📄 user_list_screen.dart
│  └── 📂 vip/
│    ├── 📄 vip_plans_screen.dart
│    ├── 📄 vip_screen.dart
│    ├── 📄 vip_today_screen.dart
└── 📂 services/
│  ├── 📄 auth_service.dart
│  ├── 📄 chat_service.dart
│  ├── 📄 location_service.dart
│  ├── 📄 match_service.dart
│  ├── 📄 notification_service.dart
│  ├── 📄 payment_service.dart
│  ├── 📄 storage_service.dart
│  ├── 📄 user_service.dart
└── 📂 utils/
│  ├── 📄 app_colors.dart
│  ├── 📄 app_dimensions.dart
│  ├── 📄 app_text_styles.dart
│  ├── 📄 extensions.dart
│  ├── 📄 formatters.dart
│  ├── 📄 helpers.dart
│  ├── 📄 theme.dart
│  ├── 📄 validators.dart
└── 📂 viewmodels/
│  ├── 📄 auth_viewmodel.dart
│  ├── 📄 chat_viewmodel.dart
│  ├── 📄 match_viewmodel.dart
│  ├── 📄 notification_viewmodel.dart
│  ├── 📄 permission_viewmodel.dart
│  ├── 📄 theme_viewmodel.dart
│  ├── 📄 user_viewmodel.dart
│  ├── 📄 vip_viewmodel.dart
└── 📂 widgets/
│  └── 📂 cards/
│    ├── 📄 chat_card.dart
│    ├── 📄 match_card.dart
│    ├── 📄 profile_card.dart
│  └── 📂 common/
│    ├── 📄 custom_app_bar.dart
│    ├── 📄 custom_button.dart
│    ├── 📄 custom_text_field.dart
│    ├── 📄 empty_state_widget.dart
│    ├── 📄 error_widget.dart
│    ├── 📄 loading_widget.dart
│  └── 📂 dialogs/
│    ├── 📄 confirm_dialog.dart
│    ├── 📄 info_dialog.dart
│    ├── 📄 payment_dialog.dart
│  └── 📂 layout/
│    ├── 📄 app_layout.dart
│    ├── 📄 header.dart
│    ├── 📄 sidebar.dart
│  └── 📂 sheets/
│    ├── 📄 filter_bottom_sheet.dart
│    ├── 📄 region_bottom_sheet.dart
│    └── 📄 super_chat_bottom_sheet.dart
```