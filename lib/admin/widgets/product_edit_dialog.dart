import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/GeneralProduct.dart';
import '../providers/general_products_provider.dart';

class ProductEditDialog extends ConsumerStatefulWidget {
  final GeneralProduct? product;

  const ProductEditDialog({
    super.key,
    this.product,
  });

  @override
  ConsumerState<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends ConsumerState<ProductEditDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  String _selectedIconType = 'heart';
  String _selectedIconColor = '#FF6B9D';
  
  // 가격 테이블 데이터
  late List<PriceTableRow> _priceTableData;

  @override
  void initState() {
    super.initState();
    
    // 초기 가격 테이블 데이터
    _priceTableData = [
      PriceTableRow(quantity: 1, unitPrice: 10, bonus: 2),
      PriceTableRow(quantity: 3, unitPrice: 30, bonus: 5),
      PriceTableRow(quantity: 5, unitPrice: 50, bonus: 10),
      PriceTableRow(quantity: 10, unitPrice: 100, bonus: 25),
      PriceTableRow(quantity: 15, unitPrice: 150, bonus: 40),
    ];
    
    if (widget.product != null) {
      _titleController.text = widget.product!.title ?? '';
      _subtitleController.text = widget.product!.subtitle ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _selectedIconType = widget.product!.iconType ?? 'heart';
      _selectedIconColor = widget.product!.iconColor ?? '#FF6B9D';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
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
                                    '아이템 사진 업로드',
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
                    
                    // 아이템 이름
                    const Text(
                      '아이템 이름',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '아이템 홍보 문구',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 아이템 간단한 설명
                    const Text(
                      '아이템 간단한 설명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _subtitleController,
                      decoration: InputDecoration(
                        hintText: '• 아이템에 대한 간단 설명을 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '상세 설명 입력',
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
                          child: Text(widget.product == null ? '일반 상품 등록' : '일반 상품 수정'),
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
                _buildTableHeader('갯수'),
                _buildTableHeader('단가'),
                _buildTableHeader('보너스'),
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

  Widget _buildEditableTableRow(PriceTableRow row, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 갯수 입력
          Expanded(
            child: TextFormField(
              initialValue: row.quantity.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final quantity = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].quantity = quantity;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 단가 입력
          Expanded(
            child: TextFormField(
              initialValue: row.unitPrice.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
                suffixText: 'p',
              ),
              onChanged: (value) {
                final unitPrice = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].unitPrice = unitPrice;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // 보너스 입력
          Expanded(
            child: TextFormField(
              initialValue: row.bonus.toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final bonus = int.tryParse(value) ?? 0;
                setState(() {
                  _priceTableData[index].bonus = bonus;
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
      _priceTableData.add(PriceTableRow(
        quantity: 1,
        unitPrice: 10,
        bonus: 0,
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
                  _titleController.text.isEmpty ? '아이템 이름' : _titleController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 탭바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab('하트', true),
                _buildTab('슈퍼챗', false),
                _buildTab('프로필 열람권', false),
                _buildTab('추천카드 더 보기', false),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 아이콘
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _getColorFromString(_selectedIconColor).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(_selectedIconType),
                      size: 60,
                      color: _getColorFromString(_selectedIconColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _titleController.text.isEmpty ? '하트' : _titleController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitleController.text.isEmpty 
                      ? '더욱 많은 이성에게 하트를 보내보세요!' 
                      : _subtitleController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _descriptionController.text.isEmpty
                        ? '하트로 더욱 많은 이성에게 관심을 표현할 수 있습니다!\n\n• 이성 회원에게 보내는 하트로 수는 제한이 없습니다.\n• 하트는 모양 어떤이 없으로 관심있는 이성에게 나를 어필해보세요!\n• 이벤트는 사전 고지 없이 조기 종료 또는 변경 될 수 있습니다.'
                        : _descriptionController.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '보유 하트 수                                           0개',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // 동적 구매 버튼들
                  ..._priceTableData.map((row) {
                    final hasBonus = row.bonus > 0;
                    return Column(
                      children: [
                        _buildPurchaseButton(
                          '${row.quantity}개',
                          '${row.unitPrice}P',
                          bonus: hasBonus ? '+${row.bonus}개 더' : null,
                        ),
                        const SizedBox(height: 8),
                      ],
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

  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(String quantity, String price, {String? bonus}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(quantity, style: const TextStyle(fontSize: 14)),
              if (bonus != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1493),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        bonus,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getIconData(String iconType) {
    switch (iconType) {
      case 'heart':
        return Icons.favorite;
      case 'chat':
        return Icons.chat_bubble;
      case 'profile':
        return Icons.person;
      case 'stack':
        return Icons.layers;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return const Color(0xFFFF6B9D);
    }
  }

  void _saveProduct() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이템 이름을 입력해주세요')),
      );
      return;
    }

    Navigator.of(context).pop();
    
    if (widget.product == null) {
      // 새 상품 추가
      await ref.read(generalProductsProvider.notifier).createProduct(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        description: _descriptionController.text,
        iconType: _selectedIconType,
        iconColor: _selectedIconColor,
      );
    } else {
      // 기존 상품 수정
      final updatedProduct = widget.product!.copyWith(
        title: _titleController.text,
        subtitle: _subtitleController.text,
        description: _descriptionController.text,
        iconType: _selectedIconType,
        iconColor: _selectedIconColor,
      );
      await ref.read(generalProductsProvider.notifier).updateProduct(updatedProduct);
    }
  }
}

class PriceTableRow {
  int quantity;
  int unitPrice;
  int bonus;

  PriceTableRow({
    required this.quantity,
    required this.unitPrice,
    required this.bonus,
  });
}