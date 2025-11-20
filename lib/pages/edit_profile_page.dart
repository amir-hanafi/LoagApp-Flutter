import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();

  bool loading = false;

  List provinces = [];
  List cities = [];
  List districts = [];
  List villages = [];

  int? selectedProvince;
  int? selectedCity;
  int? selectedDistrict;
  int? selectedVillage;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchProvinces();
    await _fetchUserFromApi();
  }

  // ------------------ FETCH USER PROFILE ------------------
  Future<void> _fetchUserFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    final response = await http.get(
      Uri.parse("http://192.168.1.6:8000/api/profile"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['data'];

      setState(() {
        nameC.text = user['name'] ?? "";
        phoneC.text = user['phone'] ?? "";

        selectedProvince = user['province_id'];
        selectedCity = user['city_id'];
        selectedDistrict = user['district_id'];
        selectedVillage = user['village_id'];
      });

      // Fetch dependent dropdowns
      if (selectedProvince != null) await _fetchCities(selectedProvince!);
      if (selectedCity != null) await _fetchDistricts(selectedCity!);
      if (selectedDistrict != null) await _fetchVillages(selectedDistrict!);
    }
  }

  // ------------------ FETCH PROVINCES ------------------
  // ------------------ FETCH PROVINCES ------------------
Future<void> _fetchProvinces() async {
  final response = await http.get(
    Uri.parse("http://192.168.1.6:8000/api/provinces"),
    headers: {"Accept": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      provinces = data['provinces'];
    });
  }
}

// ------------------ FETCH CITIES ------------------
Future<void> _fetchCities(int provinceId) async {
  final response = await http.get(
    Uri.parse("http://192.168.1.6:8000/api/cities/$provinceId"),
    headers: {"Accept": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      cities = data['cities'];
    });
  }
}

// ------------------ FETCH DISTRICTS ------------------
Future<void> _fetchDistricts(int cityId) async {
  final response = await http.get(
    Uri.parse("http://192.168.1.6:8000/api/districts/$cityId"),
    headers: {"Accept": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      districts = data['districts'];
    });
  }
}

// ------------------ FETCH VILLAGES ------------------
Future<void> _fetchVillages(int districtId) async {
  final response = await http.get(
    Uri.parse("http://192.168.1.6:8000/api/villages/$districtId"),
    headers: {"Accept": "application/json"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      villages = data['villages'];
    });
  }
}


  // ------------------ UPDATE PROFILE ------------------
  Future<void> _updateProfile() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return;

    final response = await http.post(
      Uri.parse("http://192.168.1.6:8000/api/profile/update"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "name": nameC.text,
        "phone": phoneC.text,
        if (passwordC.text.isNotEmpty) "password": passwordC.text,
        if (selectedProvince != null) "province_id": selectedProvince.toString(),
        if (selectedCity != null) "city_id": selectedCity.toString(),
        if (selectedDistrict != null) "district_id": selectedDistrict.toString(),
        if (selectedVillage != null) "village_id": selectedVillage.toString(),
      },
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update profil: ${response.body}")),
      );
    }
  }

  // ------------------ BUILD UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Nama
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Nama"),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passwordC,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password Baru (Opsional)"),
              ),

              const SizedBox(height: 16),

              // Nomor Telepon
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Nomor Telepon",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------- DROPDOWN PROVINSI --------------------
DropdownButtonFormField<int>(
  value: selectedProvince,
  decoration: const InputDecoration(labelText: "Provinsi"),
  items: provinces
      .map<DropdownMenuItem<int>>(
        (item) => DropdownMenuItem(
          value: item['id'],
          child: Text(item['name']),
        ),
      )
      .toList(),
  onChanged: (value) async {
    setState(() {
      selectedProvince = value;
      // Reset dropdown di bawahnya
      selectedCity = null;
      selectedDistrict = null;
      selectedVillage = null;
      cities = [];
      districts = [];
      villages = [];
    });
    if (value != null) await _fetchCities(value);
  },
),

// -------------------- DROPDOWN KOTA --------------------
DropdownButtonFormField<int>(
  value: selectedCity,
  decoration: const InputDecoration(labelText: "Kota / Kabupaten"),
  items: cities
      .map<DropdownMenuItem<int>>(
        (item) => DropdownMenuItem(
          value: item['id'],
          child: Text(item['name']),
        ),
      )
      .toList(),
  onChanged: (value) async {
    setState(() {
      selectedCity = value;
      // Reset dropdown di bawahnya
      selectedDistrict = null;
      selectedVillage = null;
      districts = [];
      villages = [];
    });
    if (value != null) await _fetchDistricts(value);
  },
),

// -------------------- DROPDOWN KECAMATAN --------------------
DropdownButtonFormField<int>(
  value: selectedDistrict,
  decoration: const InputDecoration(labelText: "Kecamatan"),
  items: districts
      .map<DropdownMenuItem<int>>(
        (item) => DropdownMenuItem(
          value: item['id'],
          child: Text(item['name']),
        ),
      )
      .toList(),
  onChanged: (value) async {
    setState(() {
      selectedDistrict = value;
      // Reset desa
      selectedVillage = null;
      villages = [];
    });
    if (value != null) await _fetchVillages(value);
  },
),

// -------------------- DROPDOWN DESA --------------------
DropdownButtonFormField<int>(
  value: selectedVillage,
  decoration: const InputDecoration(labelText: "Desa / Kelurahan"),
  items: villages
      .map<DropdownMenuItem<int>>(
        (item) => DropdownMenuItem(
          value: item['id'],
          child: Text(item['name']),
        ),
      )
      .toList(),
  onChanged: (value) {
    setState(() {
      selectedVillage = value;
    });
  },
),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text("Simpan Perubahan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
