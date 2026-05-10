import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'glass_card.dart';

class BackfillDialog extends StatefulWidget {
  const BackfillDialog({super.key});

  @override
  State<BackfillDialog> createState() => _BackfillDialogState();
}

class _BackfillDialogState extends State<BackfillDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<Map<String, dynamic>> _drinks = [];
  
  final _nameController = TextEditingController(text: '啤酒 / BEER');
  double _abv = 0.05;
  double _volume = 330.0;

  void _addDrink() {
    setState(() {
      _drinks.add({
        'name': _nameController.text,
        'abv': _abv,
        'volume': _volume,
      });
    });
  }

  void _save(AlcoholBrain brain) {
    if (_drinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一种饮品 / PLEASE ADD AT LEAST ONE DRINK')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final List<DrinkEntryData> entries = [];
    DateTime currentDrinkTime = startDateTime;

    for (var d in _drinks) {
      entries.add(DrinkEntryData(
        timestamp: currentDrinkTime,
        abv: d['abv'],
        volumeML: d['volume'],
      ));
      // Assume drinks are 30 mins apart for backfill simulation
      currentDrinkTime = currentDrinkTime.add(const Duration(minutes: 30));
    }

    brain.backfillSession(
      startTime: startDateTime,
      entries: entries,
      occasion: "补录 / BACKFILL",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BACKFILL RECORD',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface.withOpacity(0.4),
                      ),
                    ),
                    Text(
                      '补录饮酒记录',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white24),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Time Picker ──────────────────
            Row(
              children: [
                Expanded(
                  child: _buildPickerTile(
                    label: '日期 / DATE',
                    value: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    icon: Icons.calendar_today,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerTile(
                    label: '时间 / TIME',
                    value: _selectedTime.format(context),
                    icon: Icons.access_time,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) setState(() => _selectedTime = time);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Drink Input Section ──────────
            Text(
              'ADD DRINKS / 添加饮品',
              style: GoogleFonts.robotoMono(
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '酒名 / DRINK NAME',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumericInput(
                    label: 'ABV (%)',
                    value: (_abv * 100).toStringAsFixed(1),
                    onChanged: (v) => setState(() => _abv = (double.tryParse(v) ?? 0) / 100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumericInput(
                    label: 'VOLUME (ML)',
                    value: _volume.toInt().toString(),
                    onChanged: (v) => setState(() => _volume = double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _addDrink,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '+ ADD TO SESSION  加入场次',
                    style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Drink List ───────────────────
            if (_drinks.isNotEmpty) ...[
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              ..._drinks.asMap().entries.map((entry) {
                final d = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🥃', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['name'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('${(d['abv'] * 100).toStringAsFixed(1)}% | ${d['volume'].toInt()}ml', 
                                 style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _drinks.removeAt(entry.key)),
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 40),

            // ── Save Button ──────────────────
            GestureDetector(
              onTap: () => _save(brain),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'SAVE SESSION  保存场次',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white38)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.amberGold),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericInput({required String label, required String value, required ValueChanged<String> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white38)),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          ),
        ],
      ),
    );
  }
}
