import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/banner_model.dart';
import '../providers/banner_provider.dart';
import '../utils/admin_theme.dart';

/// 배너 업로드/수정 다이얼로그
class BannerUploadDialog extends ConsumerStatefulWidget {
  final BannerModel? banner;
  final BannerType? defaultType;
  final Function(BannerCreateUpdateDto) onSave;

  const BannerUploadDialog({
    super.key,
    this.banner,
    this.defaultType,
    required this.onSave,
  });

  @override
  ConsumerState<BannerUploadDialog> createState() => _BannerUploadDialogState();
}

class _BannerUploadDialogState extends ConsumerState<BannerUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkUrlController = TextEditingController();
  final _orderController = TextEditingController();

  BannerType? _selectedType;
  bool _isActive = true;
  String? _imageUrl;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.banner != null) {
      // 수정 모드
      final banner = widget.banner!;
      _titleController.text = banner.title;
      _descriptionController.text = banner.description ?? '';
      _linkUrlController.text = banner.linkUrl ?? '';
      _orderController.text = banner.order.toString();
      _selectedType = banner.type;
      _isActive = banner.isActive;
      _imageUrl = banner.imageUrl;
    } else {
      // 생성 모드
      _selectedType = widget.defaultType;
      _orderController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.banner != null ? '배너 수정' : '배너 추가'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배너 타입
                DropdownButtonFormField<BannerType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: '배너 타입',
                    border: OutlineInputBorder(),
                  ),
                  items: BannerType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '배너 타입을 선택해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AdminTheme.spacingM),

                // 제목
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AdminTheme.spacingM),

                // 설명
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명 (선택사항)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AdminTheme.spacingM),

                // 이미지 업로드
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedFile != null
                      ? Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _imageUrl != null
                                    ? Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _getBannerIcon(_selectedType ?? BannerType.mainAd),
                                                    size: 48,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _selectedFile!.name,
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                size: 48,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _selectedFile!.name,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(1)} MB',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFile = null;
                                    _imageUrl = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            if (_imageUrl == null && !_isUploading)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: ElevatedButton(
                                  onPressed: _uploadSelectedImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('업로드', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            if (_isUploading)
                              const Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        )
                      : InkWell(
                          onTap: _isUploading ? null : _selectImage,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isUploading)
                                  const CircularProgressIndicator()
                                else ...[
                                  const Icon(
                                    Icons.cloud_upload,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '이미지 선택',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '클릭하여 이미지를 선택하세요\n(JPG, PNG, GIF 지원)',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: AdminTheme.spacingM),

                // 링크 URL
                TextFormField(
                  controller: _linkUrlController,
                  decoration: const InputDecoration(
                    labelText: '링크 URL (선택사항)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AdminTheme.spacingM),

                // 순서와 활성화 상태
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _orderController,
                        decoration: const InputDecoration(
                          labelText: '순서',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '순서를 입력해주세요';
                          }
                          if (int.tryParse(value) == null) {
                            return '숫자를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AdminTheme.spacingM),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('활성화'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.banner != null ? '수정' : '추가'),
        ),
      ],
    );
  }


  IconData _getBannerIcon(BannerType type) {
    switch (type) {
      case BannerType.mainAd:
        return Icons.ads_click;
      case BannerType.pointStore:
        return Icons.store;
      case BannerType.terms:
        return Icons.description;
    }
  }

  Future<void> _selectImage() async {
    try {
      final file = await ref.read(adminBannerProvider.notifier).pickImage();
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _imageUrl = null; // 업로드 전이므로 URL은 null
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await ref.read(adminBannerProvider.notifier).uploadImage(_selectedFile!);
      setState(() {
        _imageUrl = imageUrl;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 업로드 완료'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지를 업로드해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dto = BannerCreateUpdateDto(
      type: _selectedType!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      imageUrl: _imageUrl!,
      linkUrl: _linkUrlController.text.trim().isEmpty 
          ? null 
          : _linkUrlController.text.trim(),
      isActive: _isActive,
      order: int.parse(_orderController.text),
      startDate: null,
      endDate: null,
    );

    Navigator.of(context).pop();
    widget.onSave(dto);
  }
}