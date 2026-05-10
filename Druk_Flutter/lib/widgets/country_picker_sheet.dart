import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/country_law.dart';

void showCountryPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CountryPickerSheet(),
  );
}

class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key});

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    
    final filteredCountries = CountryLaw.allCountries.where((c) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || 
             c.enName.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDim,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择法律管辖区',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ivoryWarm,
                      ),
                    ),
                    Text(
                      'SELECT JURISDICTION',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: AppColors.silverGray.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.silverGray.withOpacity(0.5), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => searchQuery = v),
                              style: GoogleFonts.notoSerifSc(color: AppColors.ivoryWarm, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: '搜索国家 / Search Country',
                                hintStyle: GoogleFonts.notoSerifSc(
                                  color: AppColors.silverGray.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              
              // Scrollable Country List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredCountries.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected = brain.country == country;
                    
                    return InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        brain.updateCountry(country);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.amberGold.withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(country.flag, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.displayBilingualName,
                                    style: GoogleFonts.notoSerifSc(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.amberGold : AppColors.ivoryWarm,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    country.isProhibition ? '禁酒 / Prohibited' : 'DUI ${country.duiLimitString}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: country.isProhibition 
                                          ? AppColors.error 
                                          : AppColors.silverGray.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColors.amberGold, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        );
      },
    );
  }
}
