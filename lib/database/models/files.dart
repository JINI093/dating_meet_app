class FileInfo {
  final String id;
  final String userId;
  final String fileName;
  final String filePath;
  final int uploaded; // 0: 미업로드, 1: 업로드됨
  final String? awsUrl;
  final int? updatedAt;

  FileInfo({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.filePath,
    required this.uploaded,
    this.awsUrl,
    this.updatedAt,
  });

  factory FileInfo.fromMap(Map<String, dynamic> map) => FileInfo(
        id: map['id'],
        userId: map['userId'],
        fileName: map['fileName'],
        filePath: map['filePath'],
        uploaded: map['uploaded'],
        awsUrl: map['awsUrl'],
        updatedAt: map['updatedAt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'fileName': fileName,
        'filePath': filePath,
        'uploaded': uploaded,
        'awsUrl': awsUrl,
        'updatedAt': updatedAt,
      };

  FileInfo copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? filePath,
    int? uploaded,
    String? awsUrl,
    int? updatedAt,
  }) => FileInfo(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        uploaded: uploaded ?? this.uploaded,
        awsUrl: awsUrl ?? this.awsUrl,
        updatedAt: updatedAt ?? this.updatedAt,
      );
} 