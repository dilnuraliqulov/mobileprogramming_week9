//Task11


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const CurrencyApp());

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Rates',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CurrencyScreen(),
    );
  }
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  List<dynamic> _currencies = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _currencies = [];
    });

    final date = _dateController.text.trim();
    final code = _currencyController.text.trim().toUpperCase();

    String url = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/';
    if (date.isNotEmpty && code.isNotEmpty) {
      if (code == 'ALL') {
        url = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/all/$date/';
      } else {
        url = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/$code/$date/';
      }
    } else if (code.isEmpty && date.isNotEmpty) {
      url = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/all/$date/';
    } else if (code.isNotEmpty && code != 'ALL' && date.isEmpty) {
      url = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/$code/';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // The API returns a list for "all" or a single object for specific currency
        setState(() {
          _currencies = data is List ? data : [data];
        });
      } else {
        setState(() {
          _error = 'Failed to fetch data (status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Exchange Rates (UZS)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'Currency Code (USD, RUB, or ALL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRates,
              child: const Text('Fetch Rates'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red))
            else if (_currencies.isEmpty)
                const Text('No data to display')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _currencies.length,
                    itemBuilder: (context, index) {
                      final c = _currencies[index];
                      return Card(
                        child: ListTile(
                          title: Text('${c['CcyNm_RU']}'),
                          subtitle: Text('Code: ${c['Ccy']}'),
                          trailing: Text('${c['Rate']} UZS'),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
