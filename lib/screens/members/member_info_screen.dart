import 'package:firebase_auth/firebase_auth.dart'; // <-- THÊM
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // <-- Sửa đường dẫn
import '/services/firestore_service.dart'; // <-- THÊM
import '/models/user_model.dart'; // <-- THÊM
import '../../config/theme.dart';

class MemberInfoScreen extends StatefulWidget {
  const MemberInfoScreen({super.key});

  @override
  State<MemberInfoScreen> createState() => _MemberInfoScreenState();
}

class _MemberInfoScreenState extends State<MemberInfoScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _userModel;
  User? _authUser;
  bool _isLoading = true;
  bool _isEditing = false; // Trạng thái chỉnh sửa

  // THÊM: Controllers cho các trường cần sửa
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Không cần setState isLoading ở đây vì build() đã xử lý
    // setState(() => _isLoading = true);
    _authUser = _authService.currentUser;

    if (_authUser != null) {
      _userModel = await _firestoreService.getUserDocument(_authUser!.uid);
      // Cập nhật giá trị ban đầu cho controllers chỉ khi widget còn tồn tại
      if (mounted) {
        _nameController.text =
            _userModel?.displayName ?? _authUser?.displayName ?? '';
        _phoneController.text = _userModel?.phoneNumber ?? '';
      }
    }

    // Chỉ setState khi widget còn tồn tại
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // THÊM: Hàm xử lý khi nhấn nút Lưu
  Future<void> _saveChanges() async {
    if (_authUser == null) return; // Chưa đăng nhập thì không lưu

    // Ẩn bàn phím nếu đang mở
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true); // Bắt đầu lưu

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    Map<String, dynamic> dataToUpdate = {};
    bool authNameChanged = false;

    // Chỉ thêm vào map nếu giá trị thực sự thay đổi
    // Ưu tiên lấy tên từ Firestore model nếu có, sau đó mới đến Auth
    final currentDisplayName =
        _userModel?.displayName ?? _authUser?.displayName ?? '';
    if (newName != currentDisplayName) {
      dataToUpdate['displayName'] = newName;
      authNameChanged = true; // Cần cập nhật cả trên Auth nếu tên thay đổi
    }
    // Ưu tiên lấy SĐT từ Firestore model
    final currentPhoneNumber = _userModel?.phoneNumber ?? '';
    if (newPhone != currentPhoneNumber) {
      // Lưu null vào Firestore nếu người dùng xóa trắng SĐT
      dataToUpdate['phoneNumber'] = newPhone.isEmpty ? null : newPhone;
    }

    try {
      if (dataToUpdate.isNotEmpty) {
        // Gọi service để cập nhật Firestore
        await _firestoreService.updateUserData(_authUser!.uid, dataToUpdate);

        // Cập nhật displayName trên FirebaseAuth nếu nó thay đổi
        if (authNameChanged) {
          await _authUser?.updateDisplayName(newName);
          // Load lại _authUser để AppBar cập nhật tên mới ngay lập tức (nếu AppBar dùng tên này)
          // Quan trọng: Phải gọi lại instance từ FirebaseAuth để lấy thông tin mới nhất
          await FirebaseAuth.instance.currentUser?.reload();
          _authUser = FirebaseAuth.instance.currentUser;
        }

        // Load lại dữ liệu từ Firestore để cập nhật model
        _userModel = await _firestoreService.getUserDocument(_authUser!.uid);

        // Cập nhật lại controllers với dữ liệu mới nhất (để hiển thị đúng sau khi lưu)
        _nameController.text =
            _userModel?.displayName ?? _authUser?.displayName ?? '';
        _phoneController.text = _userModel?.phoneNumber ?? '';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cập nhật thành công!'),
                backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không có thay đổi nào để lưu.')),
          );
        }
      }
      // Chỉ setState khi widget còn tồn tại
      if (mounted) {
        setState(() {
          _isEditing = false; // Tắt chế độ chỉnh sửa
          _isLoading = false; // Kết thúc lưu
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false); // Kết thúc lưu nếu lỗi
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin thành viên'),
        actions: [
          // Chỉ hiển thị nút Sửa/Hủy khi đã đăng nhập và không loading
          if (_authUser != null && !_isLoading)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  // Nếu hủy edit, reset controllers về giá trị cũ
                  if (!_isEditing) {
                    _nameController.text =
                        _userModel?.displayName ?? _authUser?.displayName ?? '';
                    _phoneController.text = _userModel?.phoneNumber ?? '';
                  }
                });
              },
              child: Text(
                _isEditing ? 'Hủy' : 'Sửa',
                style: TextStyle(
                    color: _isEditing
                        ? Colors.redAccent
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black), // Màu chữ tùy theme
              ),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _authUser == null
              ? const Center(
                  child: Text('Vui lòng đăng nhập để xem thông tin.'))
              : GestureDetector(
                  // Thêm GestureDetector để ẩn bàn phím khi chạm ra ngoài
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _authUser?.photoURL != null
                                ? NetworkImage(_authUser!.photoURL!)
                                : null,
                            child: _authUser?.photoURL == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Các trường thông tin
                        _buildEditableInfoItem(
                          controller: _nameController,
                          icon: Icons.person,
                          label: 'Họ và tên',
                          hintText: 'Nhập họ tên',
                          keyboardType: TextInputType.name,
                          enabled:
                              _isEditing, // Chỉ cho phép nhập khi đang edit
                        ),
                        const Divider(),
                        InfoItem(
                          // Email không cho sửa
                          icon: Icons.email,
                          label: 'Email',
                          value: _authUser?.email ?? 'Không có',
                        ),
                        const Divider(),
                        _buildEditableInfoItem(
                          controller: _phoneController,
                          icon: Icons.phone,
                          label: 'Số điện thoại',
                          hintText: 'Nhập số điện thoại',
                          keyboardType: TextInputType.phone,
                          enabled:
                              _isEditing, // Chỉ cho phép nhập khi đang edit
                        ),
                        const Divider(),
                        InfoItem(
                          // Hạng thành viên (ví dụ không cho sửa trực tiếp)
                          icon: Icons.card_membership,
                          label: 'Hạng thành viên',
                          value: _userModel?.membershipLevel ?? 'Đồng',
                        ),
                        const Divider(),
                        InfoItem(
                          // Điểm (ví dụ không cho sửa trực tiếp)
                          icon: Icons.stars,
                          label: 'Điểm tích lũy',
                          value: (_userModel?.points ?? 0).toString(),
                        ),
                        const SizedBox(height: 30),

                        // Nút Lưu chỉ hiển thị khi đang edit
                        if (_isEditing)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _saveChanges, // Disable khi đang loading
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.save,
                                      size: 20), // Icon nhỏ hơn chút
                              label: Text(
                                  _isLoading ? 'Đang lưu...' : 'Lưu thay đổi'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme
                                      .primaryColor, // Hoặc màu theme của bạn
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 12),
                                  textStyle: const TextStyle(
                                      fontSize: 16) // Cỡ chữ cho nút
                                  ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
    );
  }

  // Sửa đổi widget này để có thể disable TextFormField
  Widget _buildEditableInfoItem({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = false, // Thêm tham số enabled
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // Sử dụng TextFormField nhưng disable/enable dựa trên `enabled`
                TextFormField(
                  controller: controller,
                  enabled: enabled, // <<<< SỬ DỤNG THAM SỐ ENABLED Ở ĐÂY
                  keyboardType: keyboardType,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Làm mờ chữ đi nếu bị disable
                      color: enabled
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          : Colors.grey[500]),
                  decoration: InputDecoration(
                      hintText: enabled
                          ? hintText
                          : '', // Chỉ hiển thị hint khi enable
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget InfoItem giữ nguyên
class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value.isEmpty ? 'Chưa cập nhật' : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
