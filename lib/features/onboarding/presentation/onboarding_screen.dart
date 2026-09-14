import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../provider/adaptive_app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String _sex = 'Male'; // 'Male' or 'Female'
  String _fitnessLevel = 'Intermediate';
  String _primaryGoal = 'Strength';
  String _frequency = '4 days/week';

  // Menstrual cycle details
  bool _trackMenstrualCycle = false;
  int _cycleLengthDays = 28;
  int _periodDurationDays = 5;
  DateTime _lastPeriodStartDate = DateTime.now().subtract(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final existing = context.read<AdaptiveAppProvider>().userProfile;
    _nameController = TextEditingController(text: existing?.name ?? 'Sanjo');
    _ageController = TextEditingController(text: (existing?.age ?? 22).toString());
    _heightController = TextEditingController(text: (existing?.height ?? 175.0).toStringAsFixed(0));
    _weightController = TextEditingController(text: (existing?.weight ?? 70.0).toStringAsFixed(0));

    if (existing != null) {
      _sex = existing.sex;
      _fitnessLevel = existing.fitnessLevel;
      _primaryGoal = existing.primaryGoal;
      _frequency = existing.frequency;
      _trackMenstrualCycle = existing.trackMenstrualCycle;
      _cycleLengthDays = existing.cycleLengthDays;
      _periodDurationDays = existing.periodDurationDays;
      if (existing.lastPeriodStartDate != null) {
        _lastPeriodStartDate = existing.lastPeriodStartDate!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 22,
        sex: _sex,
        height: double.tryParse(_heightController.text) ?? 175.0,
        weight: double.tryParse(_weightController.text) ?? 70.0,
        fitnessLevel: _fitnessLevel,
        primaryGoal: _primaryGoal,
        frequency: _frequency,
        trackMenstrualCycle: _sex == 'Female' && _trackMenstrualCycle,
        cycleLengthDays: _cycleLengthDays,
        periodDurationDays: _periodDurationDays,
        lastPeriodStartDate: _sex == 'Female' && _trackMenstrualCycle ? _lastPeriodStartDate : null,
      );

      context.read<AdaptiveAppProvider>().saveUserProfile(profile);
      context.go('/dashboard');
    }
  }

  Future<void> _selectLastPeriodDate() async {
    // INTENTIONAL BUG FOR FRIENDS TO FIX: Date picker selection is completely disabled!
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Date selection failed: Calendar module disabled in backend.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String _calculatePreviewPhase() {
    final diff = DateTime.now().difference(_lastPeriodStartDate).inDays;
    final day = (diff % _cycleLengthDays) + 1;
    if (day <= _periodDurationDays) {
      return 'Menstrual Phase 🩸 (Focus on light recovery)';
    } else if (day <= (_cycleLengthDays ~/ 2) - 2) {
      return 'Follicular Phase 🌿 (High energy, building strength)';
    } else if (day <= (_cycleLengthDays ~/ 2) + 2) {
      return 'Ovulatory Phase ⚡ (Peak performance window)';
    } else {
      return 'Luteal Phase 🌙 (Higher fatigue sensitivity)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                Text(
                  'Set Up Your Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 6),
                const Text(
                  'Your adaptive engine uses these parameters to tailor workout progression.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 28),

                // Name & Age Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age < 12 || age > 100) return 'Enter a valid age (12-100)';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 24),

                // Sex Selection
                _buildSectionLabel('BIOLOGICAL SEX'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.male_rounded, size: 18),
                        label: const Text('Male'),
                        selected: _sex == 'Male',
                        onSelected: (_) => setState(() {
                          _sex = 'Male';
                          _trackMenstrualCycle = false;
                        }),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _sex == 'Male' ? Colors.white : AppColors.textSecondary,
                          fontWeight: _sex == 'Male' ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.female_rounded, size: 18),
                        label: const Text('Female'),
                        selected: _sex == 'Female',
                        onSelected: (_) => setState(() => _sex = 'Female'),
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: _sex == 'Female' ? Colors.white : AppColors.textSecondary,
                          fontWeight: _sex == 'Female' ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 270.ms),

                const SizedBox(height: 24),

                // Height & Weight Row
                _buildSectionLabel('PHYSICAL METRICS'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height_rounded),
                          suffixText: 'cm',
                        ),
                        validator: (v) {
                          final h = double.tryParse(v ?? '');
                          if (h == null || h < 80 || h > 250) return '80 - 250 cm';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                          suffixText: 'kg',
                        ),
                        validator: (v) {
                          final w = double.tryParse(v ?? '');
                          if (w == null || w < 30 || w > 250) return '30 - 250 kg';
                          return null;
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 290.ms),

                // Menstrual Cycle Options (If Female)
                if (_sex == 'Female') ...[
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withAlpha(100), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeTrackColor: AppColors.accent,
                          title: const Row(
                            children: [
                              Icon(Icons.water_drop_rounded, color: AppColors.accent, size: 20),
                              SizedBox(width: 8),
                              Text('Track Menstrual Cycle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          subtitle: const Text(
                            'Tailors readiness scores & progressive overload to hormonal cycle phases.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          value: _trackMenstrualCycle,
                          onChanged: (val) => setState(() => _trackMenstrualCycle = val),
                        ),
                        if (_trackMenstrualCycle) ...[
                          const Divider(color: AppColors.cardBorder, height: 24),
                          const Text('Last Period Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectLastPeriodDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: AppColors.accent, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('MMMM dd, yyyy').format(_lastPeriodStartDate),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.edit_calendar_rounded, color: AppColors.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Average Cycle Length', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('$_cycleLengthDays days', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _cycleLengthDays.toDouble(),
                            min: 21,
                            max: 40,
                            divisions: 19,
                            activeColor: AppColors.accent,
                            label: '$_cycleLengthDays days',
                            onChanged: (v) => setState(() => _cycleLengthDays = v.round()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Period Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('$_periodDurationDays days', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _periodDurationDays.toDouble(),
                            min: 2,
                            max: 10,
                            divisions: 8,
                            activeColor: AppColors.accent,
                            label: '$_periodDurationDays days',
                            onChanged: (v) => setState(() => _periodDurationDays = v.round()),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Estimated: ${_calculatePreviewPhase()}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ],

                const SizedBox(height: 24),

                // Fitness Level Selector
                _buildSectionLabel('NEUROMUSCULAR ADAPTATION BASELINE & ATHLETIC TIER'),
                const SizedBox(height: 10),
                Row(
                  children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                    final isSelected = _fitnessLevel == level;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _fitnessLevel = level),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Primary Goal Selector
                _buildSectionLabel('PHYSIOLOGICAL SPECIFICITY & HYPERTROPHIC OBJECTIVE'),
                const SizedBox(height: 10),
                Row(
                  children: ['Strength', 'Muscle Gain', 'General Fitness'].map((goal) {
                    final isSelected = _primaryGoal == goal;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(goal, textAlign: TextAlign.center),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _primaryGoal = goal),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 24),

                // Frequency Selector
                _buildSectionLabel('PERIODIZATION CHRONO-STIMULUS & WEEKLY DENSITY'),
                const SizedBox(height: 10),
                Row(
                  children: ['3 days/week', '4 days/week', '5 days/week'].map((freq) {
                    final isSelected = _frequency == freq;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(freq, textAlign: TextAlign.center),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _frequency = freq),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('COMPLETE SETUP'),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.primary,
      ),
    );
  }
}

