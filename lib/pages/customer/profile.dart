import 'package:flutter/material.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bulk_finder/providers/auth_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bulk_finder/services/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = Supabase.instance.client.auth.currentUser;
    
    if (currentUser != null && authProvider.user == null) {
      authProvider.loadUser(currentUser.id);
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context, user) async {
    final _nameController = TextEditingController(text: user.fullName);
    final _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    String gender = user.gender ?? '';
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text('Edit Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: gender.isEmpty ? null : gender,
                      items: [
                        DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                        DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                      ],
                      onChanged: (val) => setStateDialog(() => gender = val ?? ''),
                      decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setStateDialog(() => isLoading = true);
                        try {
                          await AuthService().updateProfile(
                            userId: user.id,
                            fullName: _nameController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            gender: gender,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil berhasil diperbarui')),
                            );
                            // Refresh profil
                            context.read<AuthProvider>().loadUser(user.id);
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal update profil: $e')),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, user) async {
    final _oldPassController = TextEditingController();
    final _newPassController = TextEditingController();
    final _confirmPassController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _oldPassController,
                      decoration: const InputDecoration(labelText: 'Password Lama'),
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPassController,
                      decoration: const InputDecoration(labelText: 'Password Baru'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPassController,
                      decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                      obscureText: true,
                      validator: (v) => v != _newPassController.text ? 'Password tidak sama' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setStateDialog(() => isLoading = true);
                        try {
                          // Verifikasi password lama dengan login ulang
                          await AuthService().login(user.email, _oldPassController.text);
                          // Update password
                          await AuthService().changePassword(_newPassController.text);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password berhasil diubah')),
                            );
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal ubah password: $e')),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGenderDisplay(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      case 'other':
        return 'Lainnya';
      default:
        return 'Tidak diset';
    }
  }

  Widget _buildProfilePicture(String? profilePicturePath) {
    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      // Get public URL for profile picture
      final imageUrl = Supabase.instance.client.storage
          .from('profilepictures')
          .getPublicUrl(profilePicturePath);
      
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(
              color: AppTheme.brand_01,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.person, 
              size: 60, 
              color: AppTheme.brand_01
            ),
          ),
        ),
      );
    }
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, size: 60, color: AppTheme.brand_01),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isLoading = authProvider.isLoading;

        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Data user tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Login Ulang'),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 44),
                // Avatar with edit button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppTheme.brand_01.withOpacity(0.1),
                      child: _buildProfilePicture(user.profilePicture),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.brand_01, size: 20),
                          onPressed: () {
                            _showEditProfileDialog(context, user);
                          },
                          tooltip: 'Edit Foto',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Profile Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileField('Nama Lengkap', user.fullName),
                          const SizedBox(height: 16),
                          _buildProfileField('Email', user.email),
                          const SizedBox(height: 16),
                          _buildProfileField('Nomor Telepon', user.phoneNumber ?? 'Tidak diset'),
                          const SizedBox(height: 16),
                          _buildProfileField('Jenis Kelamin', _getGenderDisplay(user.gender)),
                          const SizedBox(height: 16),
                          _buildProfileField('Role', user.role == 'seller' ? 'Penjual' : 'Pembeli'),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showChangePasswordDialog(context, user);
                                  },
                                  icon: const Icon(Icons.lock_outline, size: 18),
                                  label: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppTheme.brand_01,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showEditProfileDialog(context, user);
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppTheme.brand_01,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Menu Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuButton(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Kebijakan Aplikasi',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        icon: Icons.settings_outlined,
                        label: 'Pengaturan',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildLogoutButton(
                        onTap: () async {
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.brand_01, size: 26),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600], size: 26),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Log Out',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.red[400], size: 28),
            ],
          ),
        ),
      ),
    );
  }
}