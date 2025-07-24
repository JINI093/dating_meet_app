import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointSettingsScreen extends StatefulWidget {
  const PointSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PointSettingsScreen> createState() => _PointSettingsScreenState();
}

class _PointSettingsScreenState extends State<PointSettingsScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _messageController;
  List<String> _messageTemplates = [];
  bool _notifySuccess = true;
  bool _notifyFail = true;
  bool _notifyExpire = true;
  int _dailyLimit = 30000;
  int _monthlyLimit = 100000;
  bool _autoExchange = false;
  int _autoExchangePoint = 50000;
  String _autoExchangeGoods = '';
  bool _wifiOnlySync = true;
  int _couponMaskLevel = 1;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _messageController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('point_phone') ?? '';
      _messageTemplates = prefs.getStringList('point_msg_templates') ?? [];
      _notifySuccess = prefs.getBool('point_notify_success') ?? true;
      _notifyFail = prefs.getBool('point_notify_fail') ?? true;
      _notifyExpire = prefs.getBool('point_notify_expire') ?? true;
      _dailyLimit = prefs.getInt('point_daily_limit') ?? 30000;
      _monthlyLimit = prefs.getInt('point_monthly_limit') ?? 100000;
      _autoExchange = prefs.getBool('point_auto_exchange') ?? false;
      _autoExchangePoint = prefs.getInt('point_auto_exchange_point') ?? 50000;
      _autoExchangeGoods = prefs.getString('point_auto_exchange_goods') ?? '';
      _wifiOnlySync = prefs.getBool('point_wifi_only_sync') ?? true;
      _couponMaskLevel = prefs.getInt('point_coupon_mask_level') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('point_phone', _phoneController.text);
    await prefs.setStringList('point_msg_templates', _messageTemplates);
    await prefs.setBool('point_notify_success', _notifySuccess);
    await prefs.setBool('point_notify_fail', _notifyFail);
    await prefs.setBool('point_notify_expire', _notifyExpire);
    await prefs.setInt('point_daily_limit', _dailyLimit);
    await prefs.setInt('point_monthly_limit', _monthlyLimit);
    await prefs.setBool('point_auto_exchange', _autoExchange);
    await prefs.setInt('point_auto_exchange_point', _autoExchangePoint);
    await prefs.setString('point_auto_exchange_goods', _autoExchangeGoods);
    await prefs.setBool('point_wifi_only_sync', _wifiOnlySync);
    await prefs.setInt('point_coupon_mask_level', _couponMaskLevel);
  }

  void _addTemplate() {
    final msg = _messageController.text.trim();
    if (msg.isNotEmpty && !_messageTemplates.contains(msg)) {
      setState(() {
        _messageTemplates.add(msg);
        _messageController.clear();
      });
      _saveSettings();
    }
  }

  void _removeTemplate(String msg) {
    setState(() {
      _messageTemplates.remove(msg);
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포인트 교환 설정')), 
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('기본 수신자 전화번호', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '010-0000-0000', border: OutlineInputBorder()),
            onChanged: (_) => _saveSettings(),
          ),
          const SizedBox(height: 24),
          const Text('자주 사용하는 선물 메시지', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: '메시지 입력', border: OutlineInputBorder()),
                ),
              ),
              IconButton(onPressed: _addTemplate, icon: const Icon(Icons.add)),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _messageTemplates.map((msg) => Chip(
              label: Text(msg),
              onDeleted: () => _removeTemplate(msg),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('교환 알림 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('성공 알림'),
            value: _notifySuccess,
            onChanged: (v) { setState(() => _notifySuccess = v); _saveSettings(); },
          ),
          SwitchListTile(
            title: const Text('실패 알림'),
            value: _notifyFail,
            onChanged: (v) { setState(() => _notifyFail = v); _saveSettings(); },
          ),
          SwitchListTile(
            title: const Text('쿠폰 만료 알림'),
            value: _notifyExpire,
            onChanged: (v) { setState(() => _notifyExpire = v); _saveSettings(); },
          ),
          const SizedBox(height: 24),
          const Text('포인트 사용 한도', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '일일 한도', border: OutlineInputBorder()),
                  controller: TextEditingController(text: _dailyLimit.toString()),
                  onChanged: (v) { _dailyLimit = int.tryParse(v) ?? 0; _saveSettings(); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '월간 한도', border: OutlineInputBorder()),
                  controller: TextEditingController(text: _monthlyLimit.toString()),
                  onChanged: (v) { _monthlyLimit = int.tryParse(v) ?? 0; _saveSettings(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('자동 교환 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('특정 포인트 달성 시 자동 교환'),
            value: _autoExchange,
            onChanged: (v) { setState(() => _autoExchange = v); _saveSettings(); },
          ),
          if (_autoExchange) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '포인트 기준', border: OutlineInputBorder()),
                    controller: TextEditingController(text: _autoExchangePoint.toString()),
                    onChanged: (v) { _autoExchangePoint = int.tryParse(v) ?? 0; _saveSettings(); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '상품권 ID', border: OutlineInputBorder()),
                    controller: TextEditingController(text: _autoExchangeGoods),
                    onChanged: (v) { _autoExchangeGoods = v; _saveSettings(); },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Text('데이터 동기화 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('WiFi에서만 동기화'),
            value: _wifiOnlySync,
            onChanged: (v) { setState(() => _wifiOnlySync = v); _saveSettings(); },
          ),
          const SizedBox(height: 24),
          const Text('쿠폰 보안 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButtonFormField<int>(
            value: _couponMaskLevel,
            items: const [
              DropdownMenuItem(value: 1, child: Text('낮음(일부 마스킹)')),
              DropdownMenuItem(value: 2, child: Text('보통(중간 마스킹)')),
              DropdownMenuItem(value: 3, child: Text('높음(전체 마스킹)')),
            ],
            onChanged: (v) { setState(() => _couponMaskLevel = v ?? 1); _saveSettings(); },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
} 