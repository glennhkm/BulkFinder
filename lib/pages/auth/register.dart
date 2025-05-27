import 'package:bulk_finder/components/buttons/button.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int currentStep = 0; // 0: Pilihan, 1: Form Toko, 2: Form Data Diri
  bool isStoreOwner = false;

  // Controllers for store form
  final TextEditingController businessLicenseController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final TextEditingController idCardPhotoController = TextEditingController();
  final TextEditingController storeContactController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();
  final TextEditingController addressDetailsController = TextEditingController();
  final TextEditingController storeFrontPhotoController = TextEditingController();
  final TextEditingController operationalHoursController = TextEditingController();

  // Controllers for personal form
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: currentStep == 0
          ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0)
          : EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: currentStep == 0
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            if (currentStep == 0) _buildRoleSelection(),
            if (currentStep == 1 && isStoreOwner) _buildStoreForm(),
            if (currentStep == 2) _buildPersonalForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        const Text(
          "Ingin Mendaftar Sebagai Apa?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppTheme.brand_01,
          ),
        ),
        const SizedBox(height: 80),
        _buildOptionButton(
          icon: Icons.store,
          label: "Pemilik Toko",
          onPressed: () {
            setState(() {
              isStoreOwner = true;
              currentStep = 1;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildOptionButton(
          icon: Icons.shopping_cart,
          label: "Pembeli",
          onPressed: () {
            setState(() {
              isStoreOwner = false;
              currentStep = 2;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 21),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppTheme.brand_01, width: 2.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreForm() {
    // Daftar field dengan indikator apakah field adalah file input
    final fields = [
      {
        "label": "Nomor Izin Usaha (NIB/SIUP)",
        "controller": businessLicenseController,
        "isFile": true,
      },
      {
        "label": "NPWP Badan Usaha/Pribadi",
        "controller": taxIdController,
        "isFile": true,
      },
      {
        "label": "Foto KTP",
        "controller": idCardPhotoController,
        "isFile": true,
      },
      {
        "label": "Kontak Toko",
        "controller": storeContactController,
        "isFile": false,
      },
      {
        "label": "Alamat Toko",
        "controller": storeAddressController,
        "isFile": false,
      },
      {
        "label": "Detail Alamat",
        "controller": addressDetailsController,
        "isFile": false,
      },
      {
        "label": "Foto Tampak Depan Toko",
        "controller": storeFrontPhotoController,
        "isFile": true,
      },
      {
        "label": "Jam Operasional",
        "controller": operationalHoursController,
        "isFile": false,
      },
    ];

    bool hasEmptyField() => fields.any((f) => (f["controller"] as TextEditingController).text.trim().isEmpty);

    void handleSubmit() {
      if (hasEmptyField()) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Semua syarat harus diisi."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        for (var field in fields) {
          print("${field['label']}: ${(field['controller'] as TextEditingController).text}");
        }
        setState(() {
          currentStep = 2;
        });
      }
    }

    Future<void> pickFile(TextEditingController controller) async {
      // Gunakan package file_picker atau image_picker
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.name.isNotEmpty) {
        controller.text = result.files.single.name;
      }
    }

    Widget buildField(Map<String, dynamic> field) {
      final label = field["label"] as String;
      final controller = field["controller"] as TextEditingController;
      final isFile = field["isFile"] as bool;

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: AppTheme.brand_01,
                ),
                children: [
                  TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              readOnly: isFile,
              controller: controller,
              onTap: isFile ? () => pickFile(controller) : null,
              decoration: InputDecoration(
                hintText: isFile ? "Pilih File" : "Masukkan $label",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
                suffixIcon: isFile
                    ? const Icon(Icons.upload_file, color: AppTheme.brand_01)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => setState(() => currentStep = 0),
                    icon:
                        const Icon(Icons.arrow_back, color: AppTheme.brand_01),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Daftarkan Tokomu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand_01,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields.map(buildField).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Button(
              text: "Lanjutkan",
              onPressed: handleSubmit,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPersonalForm() {
    return Column(
      children: [
        const Text(
          "Form Data Diri",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.brand_01,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(label: "Nama Lengkap", controller: fullNameController),
        const SizedBox(height: 20),
        _buildTextField(label: "Email", controller: emailController),
        const SizedBox(height: 20),
        _buildTextField(
            label: "Nomor Telepon", controller: phoneNumberController),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Save personal form data
            print("Full Name: ${fullNameController.text}");
            print("Email: ${emailController.text}");
            print("Phone Number: ${phoneNumberController.text}");
          },
          child: const Text("Daftar"),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              currentStep = isStoreOwner ? 1 : 0;
            });
          },
          child: const Text("Kembali"),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
              color: AppTheme.brand_01,
            ),
            children: [
              TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red[800]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ],
    );
  }
}
