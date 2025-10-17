import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme.dart';
import '../providers/transaction_form_provider.dart';

class TransactionFormScreen extends StatelessWidget {
  const TransactionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionFormProvider(),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView({Key? key}) : super(key: key);

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _formKey = GlobalKey<FormState>();

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionFormProvider>();
    // provide a context for provider to read AuthProvider token when needed
    p.globalFormContext = context;

    return Scaffold(
      backgroundColor: AppColors.greySurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.greySurface,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Catat Keuangan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Kategori'),
                DropdownButtonFormField<TxCategory>(
                  value: p.kategori,
                  items: TxCategory.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                      )
                      .toList(),
                  decoration: _dec(''),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  onChanged: p.setKategori,
                  validator: (_) =>
                      p.kategori == null ? 'Pilih kategori' : null,
                ),
                const SizedBox(height: 18),

                _label('Nama Kategori'),
                TextFormField(
                  controller: p.namaKategoriC,
                  decoration: _dec(''),
                  validator: p.validateRequired,
                ),
                const SizedBox(height: 18),

                _label('Jenis'),
                TextFormField(
                  controller: p.jenisC,
                  decoration: _dec(''),
                  validator: p.validateRequired,
                ),
                const SizedBox(height: 18),

                _label('Jumlah Pemasukan'),
                TextFormField(
                  controller: p.jumlahC,
                  keyboardType: TextInputType.number,
                  decoration: _dec(''),
                  validator: p.validateJumlah,
                ),
                const SizedBox(height: 18),

                _label('Metode Pembayaran'),
                TextFormField(controller: p.metodeC, decoration: _dec('')),
                const SizedBox(height: 18),

                _label('Keterangan'),
                TextFormField(
                  controller: p.keteranganC,
                  decoration: _dec(''),
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: p.loading
                        ? null
                        : () async {
                            final ok = await context
                                .read<TransactionFormProvider>()
                                .submit(_formKey);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok ? 'Tersimpan' : 'Gagal menyimpan',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: p.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
