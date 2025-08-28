import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/VipProduct.dart';
import '../providers/vip_products_provider.dart';

class VipProductEditDialog extends ConsumerStatefulWidget {
  final VipProduct? product;

  const VipProductEditDialog({
    super.key,
    this.product,
  });

  @override
  ConsumerState<VipProductEditDialog> createState() => _VipProductEditDialogState();
}

class _VipProductEditDialogState extends ConsumerState<VipProductEditDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  File? _selectedImage;
  String _selectedTier = 'BRONZE';
  String _selectedIconColor = '#CD7F32';
  
  // 가격 테이블 데이터 (기간, 정가, 할인가, 할인율)
  late List<VipPriceTableRow> _priceTableData;

  @override
  void initState() {
    super.initState();
    
    // 초기 가격 테이블 데이터
    _priceTableData = [
      VipPriceTableRow(period: 1, originalPrice: 9900, discountPrice: 7900, discountRate: 20),
      VipPriceTableRow(period: 3, originalPrice: 24900, discountPrice: 19900, discountRate: 20),
      VipPriceTableRow(period: 6, originalPrice: 49900, discountPrice: 39900, discountRate: 20),
      VipPriceTableRow(period: 12, originalPrice: 99900, discountPrice: 69900, discountRate: 30),
    ];
    
    if (widget.product != null) {
      _titleController.text = widget.product!.title ?? '';
      _subtitleController.text = widget.product!.subtitle ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _featuresController.text = widget.product!.features?.join('\n') ?? '';
      _selectedTier = widget.product!.tier ?? 'BRONZE';
      _selectedIconColor = widget.product!.iconColor ?? '#CD7F32';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 입력 폼
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 업로드
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'VIP 상품 이미지 업로드',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // VIP 등급 선택
                    const Text(
                      'VIP 등급',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTier,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'GOLD', child: Text('VIP GOLD')),
                        DropdownMenuItem(value: 'SILVER', child: Text('VIP SILVER')),
                        DropdownMenuItem(value: 'BRONZE', child: Text('VIP BRONZE')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTier = value!;
                          // 등급에 따른 기본 색상 설정
                          switch (value) {
                            case 'GOLD':
                              _selectedIconColor = '#FFD700';
                              break;
                            case 'SILVER':
                              _selectedIconColor = '#C0C0C0';
                              break;
                            case 'BRONZE':
                              _selectedIconColor = '#CD7F32';
                              break;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 상품명
                    const Text(
                      '상품명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'VIP GOLD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 부제목
                    const Text(
                      '부제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subtitleController,
                      decoration: InputDecoration(
                        hintText: '최고급 VIP 서비스를 경험하세요!',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 상품 설명
                    const Text(
                      '상품 설명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '상품에 대한 자세한 설명을 입력하세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 기능 목록
                    const Text(
                      '기능 목록 (한 줄씩 입력)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _featuresController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '무제한 하트\n무제한 슈퍼챗\n프로필 열람권\n추천카드\nVIP 매칭\n우선 고객지원',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 가격 테이블
                    _buildPriceTable(),
                    const SizedBox(height: 32),
                    
                    // 액션 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(widget.product == null ? 'VIP 상품 등록' : 'VIP 상품 수정'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 32),
            
            // 오른쪽: 앱 화면 Preview
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Text(
                    '앱 화면 Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildAppPreview(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                _buildTableHeader('기간(개월)'),
                _buildTableHeader('정가(원)'),
                _buildTableHeader('할인가(원)'),
                _buildTableHeader('할인율(%)'),
                const SizedBox(width: 40), // 삭제 버튼 공간
              ],
            ),
          ),
          
          // 테이블 행들
          ..._priceTableData.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return _buildEditableTableRow(row, index);
          }),
          
          // 행 추가 버튼
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _addTableRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('행 추가'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTableRow(VipPriceTableRow row, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 기간 입력
          Expanded(
            child: TextFormField(
              initialValue: row.period.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final period = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].period = period;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 정가 입력
          Expanded(
            child: TextFormField(
              initialValue: row.originalPrice.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final originalPrice = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].originalPrice = originalPrice;
                  // 할인율 자동 계산
                  if (originalPrice > 0 && _priceTableData[index].discountPrice > 0) {
                    _priceTableData[index].discountRate = 
                      ((originalPrice - _priceTableData[index].discountPrice) / originalPrice * 100).round();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 할인가 입력
          Expanded(
            child: TextFormField(
              initialValue: row.discountPrice.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final discountPrice = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].discountPrice = discountPrice;
                  // 할인율 자동 계산
                  if (_priceTableData[index].originalPrice > 0 && discountPrice > 0) {
                    _priceTableData[index].discountRate = 
                      ((_priceTableData[index].originalPrice - discountPrice) / _priceTableData[index].originalPrice * 100).round();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 할인율 입력
          Expanded(
            child: TextFormField(
              initialValue: row.discountRate.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              onChanged: (value) {
                final discountRate = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].discountRate = discountRate;
                  // 할인가 자동 계산
                  if (_priceTableData[index].originalPrice > 0 && discountRate > 0) {
                    _priceTableData[index].discountPrice = 
                      (_priceTableData[index].originalPrice * (1 - discountRate / 100)).round();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 삭제 버튼
          SizedBox(
            width: 32,
            child: IconButton(
              onPressed: _priceTableData.length > 1 ? () => _removeTableRow(index) : null,
              icon: Icon(
                Icons.delete_outline,
                size: 16,
                color: _priceTableData.length > 1 ? Colors.red[400] : Colors.grey[300],
              ),
              tooltip: '행 삭제',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }

  void _addTableRow() {
    setState(() {
      _priceTableData.add(VipPriceTableRow(
        period: 1,
        originalPrice: 9900,
        discountPrice: 9900,
        discountRate: 0,
      ));
    });
  }

  void _removeTableRow(int index) {
    if (_priceTableData.length > 1) {
      setState(() {
        _priceTableData.removeAt(index);
      });
    }
  }

  Widget _buildAppPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 상단 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios, size: 20),
                const SizedBox(width: 8),
                Text(
                  _titleController.text.isEmpty ? 'VIP 상품' : _titleController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // VIP 아이콘
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getColorFromString(_selectedIconColor),
                          _getColorFromString(_selectedIconColor).withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getColorFromString(_selectedIconColor).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _buildVipIcon(_selectedTier),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _titleController.text.isEmpty ? 'VIP $_selectedTier' : _titleController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitleController.text.isEmpty 
                      ? 'VIP 혜택을 누려보세요!' 
                      : _subtitleController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // 기능 목록
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VIP 혜택',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._getFeaturesFromText().map((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: _getColorFromString(_selectedIconColor),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 가격 옵션들
                  ..._priceTableData.map((row) {
                    final hasDiscount = row.discountRate > 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${row.period}개월',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  '${row.discountRate}% 할인',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount)
                                Text(
                                  '${_formatPrice(row.originalPrice)}원',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                '${_formatPrice(row.discountPrice)}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipIcon(String tier) {
    switch (tier) {
      case 'GOLD':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 60, color: Colors.white),
            Icon(Icons.star, size: 30, color: Color(0xFFFFD700)),
          ],
        );
      case 'SILVER':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 60, color: Colors.white),
            Icon(Icons.star_half, size: 30, color: Color(0xFFC0C0C0)),
          ],
        );
      case 'BRONZE':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.diamond, size: 60, color: Colors.white),
            Icon(Icons.star_border, size: 30, color: Color(0xFFCD7F32)),
          ],
        );
      default:
        return const Icon(Icons.diamond, size: 60, color: Colors.white);
    }
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return const Color(0xFFFFD700);
    }
  }

  List<String> _getFeaturesFromText() {
    if (_featuresController.text.isEmpty) {
      return ['무제한 하트', '무제한 슈퍼챗', 'VIP 전용 혜택'];
    }
    return _featuresController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _saveProduct() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품명을 입력해주세요')),
      );
      return;
    }

    Navigator.of(context).pop();
    
    final features = _getFeaturesFromText();
    
    if (widget.product == null) {
      // 새 상품 추가
      await ref.read(vipProductsProvider.notifier).createProduct(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        description: _descriptionController.text,
        tier: _selectedTier,
        iconColor: _selectedIconColor,
        features: features,
      );
    } else {
      // 기존 상품 수정
      final updatedProduct = widget.product!.copyWith(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        description: _descriptionController.text,
        tier: _selectedTier,
        iconColor: _selectedIconColor,
        features: features,
      );
      await ref.read(vipProductsProvider.notifier).updateProduct(updatedProduct);
    }
  }
}

class VipPriceTableRow {
  int period; // 기간(개월)
  int originalPrice; // 정가
  int discountPrice; // 할인가
  int discountRate; // 할인율

  VipPriceTableRow({
    required this.period,
    required this.originalPrice,
    required this.discountPrice,
    required this.discountRate,
  });
}