import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/profile_provider.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provider khusus halaman ini (dummy state awal di provider)
      create: (_) => ProfileProvider(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _usernameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _birthC = TextEditingController();

  String? _gender; // Laki-laki / Perempuan
  String? _status; // Aktif / Nonaktif / Lainnya
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    // ambil nilai awal dari provider setelah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>();
      _usernameC.text = p.username;
      _phoneC.text = p.phone;
      _gender = p.gender;
      _birthday = p.birthday;
      _birthC.text = _fmtDate(p.birthday);
      _status = p.status;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _phoneC.dispose();
    _birthC.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const mons = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${mons[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final init = _birthday ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      builder: (context, child) {
        // seragam dengan tema
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.purple,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
        _birthC.text = _fmtDate(picked);
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final p = context.read<ProfileProvider>();
    await p.updateProfile(
      username: _usernameC.text.trim(),
      phone: _phoneC.text.trim(),
      gender: _gender!,
      birthday: _birthday!,
      status: _status!,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui.')),
    );
    Navigator.pop(context); // opsional: kembali setelah simpan
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ProfileProvider>().loading;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final avatarSize = math.min(w * 0.28, 120.0); // responsif
        final sidePad = math.max(16.0, w * 0.05);     // padding proporsional

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.greySurface,
          appBar: AppBar(
            backgroundColor: AppColors.greySurface,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Edit Profil',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sidePad, 16, sidePad,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // ===== Foto profil + tombol kamera =====
                  _AvatarWithCamera(size: avatarSize),

                  const SizedBox(height: 16),

                  // ===== Kartu form (shadow hijau muda) =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(.12),
                          blurRadius: 22,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username
                          _Labeled('Username'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameC,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(hintText: 'Masukkan username'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                              if (v.trim().length < 3) return 'Minimal 3 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Phone
                          _Labeled('Nomor Telepon'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneC,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nomor telepon',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                              if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                                return 'Hanya boleh angka';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Gender
                          _Labeled('Jenis Kelamin'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            items: const [
                              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                            ],
                            onChanged: (v) => setState(() => _gender = v),
                            decoration: const InputDecoration(hintText: 'Pilih jenis kelamin'),
                            validator: (v) => v == null ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),

                          // Birthday
                          _Labeled('Tanggal Lahir'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _birthC,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: const InputDecoration(
                              hintText: 'Pilih tanggal lahir',
                              suffixIcon: Icon(Icons.date_range_rounded),
                            ),
                            validator: (_) => _birthday == null ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),

                          // Status
                          _Labeled('Status'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _status,
                            items: const [
                              DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                              DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
                              DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                            ],
                            onChanged: (v) => setState(() => _status = v),
                            decoration: const InputDecoration(hintText: 'Pilih status'),
                            validator: (v) => v == null ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 20),

                          // Tombol simpan
                          CustomButton(
                            label: 'Simpan Perubahan',
                            loading: loading,
                            onPressed: loading ? null : _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Labeled extends StatelessWidget {
  final String text;
  const _Labeled(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
      ),
    );
  }
}

class _AvatarWithCamera extends StatelessWidget {
  final double size;
  const _AvatarWithCamera({required this.size});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              image: p.photoUrl != null
                  ? DecorationImage(image: NetworkImage(p.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: p.photoUrl == null
                ? Center(
                    child: Text(
                      _initials(p.username),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                  )
                : null,
          ),

          // tombol kamera
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await context.read<ProfileProvider>().changePhotoDummy();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ganti foto (dummy)')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  width: math.min(44, size * 0.36),
                  height: math.min(44, size * 0.36),
                  decoration: const BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
