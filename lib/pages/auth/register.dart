import 'package:bulk_finder/components/buttons/button.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bulk_finder/providers/auth_providers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int currentStep = 0; // 0: Role Selection, 1: Store Form, 2: Personal Form
  bool isStoreOwner = false;

  // Controllers for store form
  final TextEditingController businessLicenseController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  PlatformFile? ktpPictureFile; // Change to store actual file
  final TextEditingController storeContactController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();
  final TextEditingController addressDetailsController = TextEditingController();
  final TextEditingController storeFrontPhotoController = TextEditingController();
  final TextEditingController operationalHoursController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();

  // Controllers for personal form
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? selectedGender; // Change to dropdown selection
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  PlatformFile? profilePictureFile; // Change to store actual file

  // Store selected files
  final Map<String, PlatformFile?> selectedFiles = {};

  double? selectedLatitude;
  double? selectedLongitude;
  bool isGettingLocation = false;

  // Tambahkan controller untuk map agar bisa move ke lokasi user
  final MapController _storeMapController = MapController();

  @override
  void initState() {
    super.initState();
    // ... existing code ...
  }

  Future<void> _getUserLocation({bool moveMap = false}) async {
    setState(() { isGettingLocation = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        if (selectedLatitude == null && selectedLongitude == null) {
          selectedLatitude = position.latitude;
          selectedLongitude = position.longitude;
        }
      });
      if (moveMap || selectedLatitude == null || selectedLongitude == null) {
        _storeMapController.move(LatLng(position.latitude, position.longitude), 15.0);
      }
    } catch (e) {
      // ignore error
    } finally {
      setState(() { isGettingLocation = false; });
    }
  }

  @override
  void dispose() {
    businessLicenseController.dispose();
    taxIdController.dispose();
    storeContactController.dispose();
    storeAddressController.dispose();
    addressDetailsController.dispose();
    storeFrontPhotoController.dispose();
    operationalHoursController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
        Text(
          "Ingin Mendaftar Sebagai Apa?",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
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
          Icon(icon, size: 24, color: AppTheme.brand_01),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.brand_01,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreForm() {
    // Ambil lokasi user saat pertama kali buka form toko
    if (selectedLatitude == null && selectedLongitude == null && !isGettingLocation) {
      _getUserLocation(moveMap: true);
    }

    final fields = [
      {
        "label": "Nama Toko",
        "controller": storeNameController,
        "isFile": false,
      },
      {
        "label": "Nomor Izin Usaha (NIB/SIUP)",
        "controller": businessLicenseController,
        "isFile": false,
      },
      {
        "label": "NPWP Badan Usaha/Pribadi",
        "controller": taxIdController,
        "isFile": false,
      },
      {
        "label": "Foto KTP",
        "controller": TextEditingController(), // Dummy controller for display
        "isFile": true,
        "fileType": "ktp",
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
        "fileType": "storefront",
      },
      {
        "label": "Jam Operasional",
        "controller": operationalHoursController,
        "isFile": false,
      },
    ];

    bool hasEmptyField() {
      // Check text fields
      for (var field in fields) {
        if (!(field["isFile"] as bool)) {
          final controller = field["controller"] as TextEditingController;
          if (controller.text.trim().isEmpty) {
            return true;
          }
        }
      }
      // Check if KTP is selected
      if (ktpPictureFile == null) {
        return true;
      }
      return false;
    }

    void handleSubmit() {
      if (hasEmptyField()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua syarat harus diisi.")),
        );
      } else {
        setState(() {
          currentStep = 2;
        });
      }
    }

    Future<void> pickFile(TextEditingController controller, String fieldType) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          controller.text = result.files.single.name;
          
          // Store the actual file based on field type
          if (fieldType == 'ktp') {
            ktpPictureFile = result.files.single;
          } else if (fieldType == 'profile') {
            profilePictureFile = result.files.single;
          } else {
            selectedFiles[fieldType] = result.files.single;
          }
        });
      }
    }

    Widget buildField(Map<String, dynamic> field) {
      final label = field["label"] as String;
      final controller = field["controller"] as TextEditingController;
      final isFile = field["isFile"] as bool;
      final fileType = field["fileType"] as String?;

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
              onTap: isFile ? () => pickFile(controller, fileType ?? label.toLowerCase()) : null,
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
                    icon: const Icon(Icons.arrow_back, color: AppTheme.brand_01),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Daftarkan Tokomu",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand_01,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tandai Lokasi Toko di Peta',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.brand_01, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _storeMapController,
                        options: MapOptions(
                          initialCenter: selectedLatitude != null && selectedLongitude != null
                              ? LatLng(selectedLatitude!, selectedLongitude!)
                              : const LatLng(-6.200000, 106.816666),
                          initialZoom: 15.0,
                          onTap: (tapPosition, latlng) {
                            setState(() {
                              selectedLatitude = latlng.latitude;
                              selectedLongitude = latlng.longitude;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.bulk_finder',
                          ),
                          if (selectedLatitude != null && selectedLongitude != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(selectedLatitude!, selectedLongitude!),
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Tombol center ke lokasi user
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            icon: const Icon(Icons.my_location, color: AppTheme.brand_01),
                            tooltip: 'Center ke Lokasi Saya',
                            onPressed: () async {
                              await _getUserLocation(moveMap: true);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedLatitude != null && selectedLongitude != null)
                  Text(
                    'Lokasi: (${selectedLatitude!.toStringAsFixed(6)}, ${selectedLongitude!.toStringAsFixed(6)})',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                if (selectedLatitude == null || selectedLongitude == null)
                  Text(
                    'Klik pada peta untuk menandai lokasi toko Anda.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalForm() {
    final fields = [
      {
        "label": "Nama Lengkap",
        "controller": fullNameController,
        "isFile": false,
        "isPassword": false,
        "isGender": false,
      },
      {
        "label": "Email",
        "controller": emailController,
        "isFile": false,
        "isPassword": false,
        "isGender": false,
      },
      {
        "label": "Nomor Telepon",
        "controller": phoneNumberController,
        "isFile": false,
        "isPassword": false,
        "isGender": false,
      },
      {
        "label": "Jenis Kelamin",
        "controller": null,
        "isFile": false,
        "isPassword": false,
        "isGender": true,
      },
      {
        "label": "Kata Sandi",
        "controller": passwordController,
        "isFile": false,
        "isPassword": true,
        "isGender": false,
      },
      {
        "label": "Konfirmasi Kata Sandi",
        "controller": confirmPasswordController,
        "isFile": false,
        "isPassword": true,
        "isGender": false,
      },
      {
        "label": "Foto Profil",
        "controller": TextEditingController(), // Dummy controller for file display
        "isFile": true,
        "isPassword": false,
        "isGender": false,
        "fileType": "profile", // Add fileType for profile picture
      },
    ];

    bool hasEmptyField() {
      // Check text fields
      for (var field in fields) {
        if (!(field["isFile"] as bool) && !(field["isGender"] as bool)) {
          final controller = field["controller"] as TextEditingController?;
          if (controller != null && controller.text.trim().isEmpty) {
            return true;
          }
        }
      }
      // Check gender selection
      if (selectedGender == null || selectedGender!.isEmpty) {
        return true;
      }
      return false;
    }

    bool isValidEmail(String email) {
      // Trim whitespace dan konversi ke lowercase
      email = email.trim().toLowerCase();
      
      // More robust email validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      );
      
      bool isValid = emailRegex.hasMatch(email);
      print('Email validation: "$email" -> $isValid');
      
      return isValid;
    }

    bool isValidPassword() {
      return passwordController.text == confirmPasswordController.text &&
          passwordController.text.length >= 6;
    }

    Future<void> pickFile(TextEditingController controller, String fieldType) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          controller.text = result.files.single.name;
          
          // Store the actual file based on field type
          if (fieldType == 'ktp') {
            ktpPictureFile = result.files.single;
          } else if (fieldType == 'profile') {
            profilePictureFile = result.files.single;
          } else {
            selectedFiles[fieldType] = result.files.single;
          }
        });
      }
    }

    Future<void> handleSubmit() async {
      if (hasEmptyField()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua field harus diisi.")),
        );
        return;
      }
      
      if (!isValidEmail(emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email tidak valid.")),
        );
        return;
      }
      
      if (!isValidPassword()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Kata sandi tidak cocok atau kurang dari 6 karakter.")),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final authProvider = context.read<AuthProvider>();
        bool success = false;

        if (isStoreOwner) {
          // Register as seller
          if (ktpPictureFile == null) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Foto KTP harus dipilih.")),
            );
            return;
          }
          if (selectedLatitude == null || selectedLongitude == null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tandai lokasi toko di peta.")),
            );
            return;
          }
          success = await authProvider.registerSeller(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            phoneNumber: phoneNumberController.text.trim(),
            gender: selectedGender ?? '',
            password: passwordController.text,
            profilePicture: profilePictureFile,
            businessLicenseNumber: businessLicenseController.text.trim(),
            npwp: taxIdController.text.trim(),
            ktpPicture: ktpPictureFile!,
            storeName: storeNameController.text.trim(),
            storeContact: storeContactController.text.trim(),
            storeAddress: storeAddressController.text.trim(),
            addressDetails: addressDetailsController.text.trim(),
            storefrontPicture: selectedFiles['storefront'],
            operatingHours: operationalHoursController.text.trim(),
            latitude: selectedLatitude,
            longitude: selectedLongitude,
          );
        } else {
          // Register as customer
          success = await authProvider.registerCustomer(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            phoneNumber: phoneNumberController.text.trim(),
            gender: selectedGender ?? '',
            password: passwordController.text,
            profilePicture: profilePictureFile,
          );
        }

        Navigator.pop(context); // Close loading dialog

        if (success) {
          // Navigate to success screen
          Navigator.pushNamed(
            context,
            '/registration_success',
            arguments: {'isStoreOwner': isStoreOwner},
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registrasi gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    Widget buildField(Map<String, dynamic> field) {
      final label = field["label"] as String;
      final controller = field["controller"] as TextEditingController?;
      final isFile = field["isFile"] as bool;
      final isPassword = field["isPassword"] as bool;
      final isGender = field["isGender"] as bool;
      final fileType = field["fileType"] as String?;

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
            if (isGender)
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Pilih Jenis Kelamin",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "male", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "female", child: Text("Perempuan")),
                  DropdownMenuItem(value: "other", child: Text("Lainnya")),
                ],
              )
            else
              TextField(
                readOnly: isFile,
                controller: controller,
                obscureText: isPassword,
                onTap: isFile ? () => pickFile(controller!, fileType ?? "profile") : null,
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
                    onPressed: () => setState(() => currentStep = isStoreOwner ? 1 : 0),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.brand_01),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Data Diri",
                    style: GoogleFonts.poppins(
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
              text: "Daftar",
              onPressed: handleSubmit,
            ),
          ),
        ],
      ),
    );
  }
}