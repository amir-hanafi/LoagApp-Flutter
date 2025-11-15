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
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  bool loading = false;

  // Dropdown data
  List provinces = [];
  List cities = [];

  int? selectedProvince;
  int? selectedCity;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProvinces();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    nameC.text = prefs.getString("name") ?? "";
    emailC.text = prefs.getString("email") ?? "";
    selectedProvince = prefs.getInt("province_id");
    selectedCity = prefs.getInt("city_id");

    // jika sudah punya province_id, otomatis load kota
    if (selectedProvince != null) {
      _fetchCities(selectedProvince!);
    }
  }

  Future<void> _fetchProvinces() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('http://192.168.1.6:8000/api/provinces'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Provinsi Response: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      provinces = data['provinces'];   // ← Ambil list provinsi
    });
  } else {
    print("Gagal memuat provinsi: ${response.body}");
  }
}




  Future<void> _fetchCities(int provinceId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('http://192.168.1.6:8000/api/cities/$provinceId'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Cities Response: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      cities = data['cities'];   // ← Ambil list kota
    });
  } else {
    print("Gagal memuat kota: ${response.body}");
  }
}



  Future<void> _updateProfile() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://192.168.1.6:8000/api/profile/update'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': nameC.text,
        'email': emailC.text,
        if (passwordC.text.isNotEmpty) 'password': passwordC.text,
        if (selectedProvince != null) 'province_id': selectedProvince.toString(),
        if (selectedCity != null) 'city_id': selectedCity.toString(),
      },
      
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      // Simpan kembali ke SharedPreferences
      prefs.setInt("province_id", selectedProvince ?? 0);
      prefs.setInt("city_id", selectedCity ?? 0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Nama"),
              ),

              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: passwordC,
                decoration: const InputDecoration(labelText: "Password Baru (Opsional)"),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Dropdown Provinsi
              DropdownButtonFormField<int>(
                value: selectedProvince,
                decoration: const InputDecoration(labelText: "Provinsi"),
                items: provinces.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem(
                    value: item["id"],
                    child: Text(item["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                    selectedCity = null;
                    cities = [];
                  });
                  _fetchCities(value!);
                },
              ),

              const SizedBox(height: 20),

              // Dropdown Kota
              DropdownButtonFormField<int>(
                value: selectedCity,
                decoration: const InputDecoration(labelText: "Kota"),
                items: cities.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem(
                    value: item["id"],
                    child: Text(item["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
              ),

              const SizedBox(height: 30),

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
