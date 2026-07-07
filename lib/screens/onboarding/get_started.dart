import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/onboarding_button.dart';
import 'package:animations/animations.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/onboarding/verification.dart';
import 'package:quest/screens/onboarding/login.dart';
import 'package:quest/screens/navigation_screen.dart';

class CountryModel {
  final String name;
  final String code;
  final String flag;

  const CountryModel({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Fully comprehensive global country list matching ISO specifications
  final List<CountryModel> _allCountries = const [
    CountryModel(name: 'Afghanistan', code: '+93', flag: '🇦🇫'),
    CountryModel(name: 'Albania', code: '+355', flag: '🇦🇱'),
    CountryModel(name: 'Algeria', code: '+213', flag: '🇩🇿'),
    CountryModel(name: 'Andorra', code: '+376', flag: '🇦🇩'),
    CountryModel(name: 'Angola', code: '+244', flag: '🇦🇴'),
    CountryModel(name: 'Antigua and Barbuda', code: '+1-268', flag: '🇦🇬'),
    CountryModel(name: 'Argentina', code: '+54', flag: '🇦🇷'),
    CountryModel(name: 'Armenia', code: '+374', flag: '🇦🇲'),
    CountryModel(name: 'Australia', code: '+61', flag: '🇦🇺'),
    CountryModel(name: 'Austria', code: '+43', flag: '🇦🇹'),
    CountryModel(name: 'Azerbaijan', code: '+994', flag: '🇦🇿'),
    CountryModel(name: 'Bahamas', code: '+1-242', flag: '🇧🇸'),
    CountryModel(name: 'Bahrain', code: '+973', flag: '🇧🇭'),
    CountryModel(name: 'Bangladesh', code: '+880', flag: '🇧🇩'),
    CountryModel(name: 'Barbados', code: '+1-246', flag: '🇧🇧'),
    CountryModel(name: 'Belarus', code: '+375', flag: '🇧🇾'),
    CountryModel(name: 'Belgium', code: '+32', flag: '🇧🇪'),
    CountryModel(name: 'Belize', code: '+501', flag: '🇧🇿'),
    CountryModel(name: 'Benin', code: '+229', flag: '🇧🇯'),
    CountryModel(name: 'Bhutan', code: '+975', flag: '🇧🇹'),
    CountryModel(name: 'Bolivia', code: '+591', flag: '🇧🇴'),
    CountryModel(name: 'Bosnia and Herzegovina', code: '+387', flag: '🇧🇦'),
    CountryModel(name: 'Botswana', code: '+267', flag: '🇧🇼'),
    CountryModel(name: 'Brazil', code: '+55', flag: '🇧🇷'),
    CountryModel(name: 'Brunei', code: '+673', flag: '🇧🇳'),
    CountryModel(name: 'Bulgaria', code: '+359', flag: '🇧🇬'),
    CountryModel(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
    CountryModel(name: 'Burundi', code: '+257', flag: '🇧🇮'),
    CountryModel(name: 'Cabo Verde', code: '+238', flag: '🇨🇻'),
    CountryModel(name: 'Cambodia', code: '+855', flag: '🇰🇭'),
    CountryModel(name: 'Cameroon', code: '+237', flag: '🇨🇲'),
    CountryModel(name: 'Canada', code: '+1', flag: '🇨🇦'),
    CountryModel(name: 'Central African Republic', code: '+236', flag: '🇨🇫'),
    CountryModel(name: 'Chad', code: '+235', flag: '🇹🇩'),
    CountryModel(name: 'Chile', code: '+56', flag: '🇨🇱'),
    CountryModel(name: 'China', code: '+86', flag: '🇨🇳'),
    CountryModel(name: 'Colombia', code: '+57', flag: '🇨🇴'),
    CountryModel(name: 'Comoros', code: '+269', flag: '🇰🇲'),
    CountryModel(name: 'Congo (Congo-Brazzaville)', code: '+242', flag: '🇨🇬'),
    CountryModel(name: 'Costa Rica', code: '+506', flag: '🇨🇷'),
    CountryModel(name: 'Croatia', code: '+385', flag: '🇭🇷'),
    CountryModel(name: 'Cuba', code: '+53', flag: '🇨🇺'),
    CountryModel(name: 'Cyprus', code: '+357', flag: '🇨🇾'),
    CountryModel(name: 'Czechia (Czech Republic)', code: '+420', flag: '🇨🇿'),
    CountryModel(
      name: 'Democratic Republic of the Congo',
      code: '+243',
      flag: '🇨🇩',
    ),
    CountryModel(name: 'Denmark', code: '+45', flag: '🇩🇰'),
    CountryModel(name: 'Djibouti', code: '+253', flag: '🇩🇯'),
    CountryModel(name: 'Dominica', code: '+1-767', flag: '🇩🇲'),
    CountryModel(name: 'Dominican Republic', code: '+1-809', flag: '🇩🇴'),
    CountryModel(name: 'Ecuador', code: '+593', flag: '🇪🇨'),
    CountryModel(name: 'Egypt', code: '+20', flag: '🇪🇬'),
    CountryModel(name: 'El Salvador', code: '+503', flag: '🇸🇻'),
    CountryModel(name: 'Equatorial Guinea', code: '+240', flag: '🇬🇶'),
    CountryModel(name: 'Eritrea', code: '+291', flag: '🇪🇷'),
    CountryModel(name: 'Estonia', code: '+372', flag: '🇪🇪'),
    CountryModel(name: 'Eswatini', code: '+268', flag: '🇸🇿'),
    CountryModel(name: 'Ethiopia', code: '+251', flag: '🇪🇹'),
    CountryModel(name: 'Fiji', code: '+679', flag: '🇫🇯'),
    CountryModel(name: 'Finland', code: '+358', flag: '🇫🇮'),
    CountryModel(name: 'France', code: '+33', flag: '🇫🇷'),
    CountryModel(name: 'Gabon', code: '+241', flag: '🇬🇦'),
    CountryModel(name: 'Gambia', code: '+220', flag: '🇬🇲'),
    CountryModel(name: 'Georgia', code: '+995', flag: '🇬🇪'),
    CountryModel(name: 'Germany', code: '+49', flag: '🇩🇪'),
    CountryModel(name: 'Ghana', code: '+233', flag: '🇬🇭'),
    CountryModel(name: 'Greece', code: '+30', flag: '🇬🇷'),
    CountryModel(name: 'Grenada', code: '+1-473', flag: '🇬🇩'),
    CountryModel(name: 'Guatemala', code: '+502', flag: '🇬🇹'),
    CountryModel(name: 'Guinea', code: '+224', flag: '🇬🇳'),
    CountryModel(name: 'Guinea-Bissau', code: '+245', flag: '🇬🇼'),
    CountryModel(name: 'Guyana', code: '+592', flag: '🇬🇾'),
    CountryModel(name: 'Haiti', code: '+509', flag: '🇭🇹'),
    CountryModel(name: 'Holy See', code: '+39', flag: '🇻🇦'),
    CountryModel(name: 'Honduras', code: '+504', flag: '🇭🇳'),
    CountryModel(name: 'Hungary', code: '+36', flag: '🇭🇺'),
    CountryModel(name: 'Iceland', code: '+354', flag: '🇮🇸'),
    CountryModel(name: 'India', code: '+91', flag: '🇮🇳'),
    CountryModel(name: 'Indonesia', code: '+62', flag: '🇮🇩'),
    CountryModel(name: 'Iran', code: '+98', flag: '🇮🇷'),
    CountryModel(name: 'Iraq', code: '+964', flag: '🇮🇶'),
    CountryModel(name: 'Ireland', code: '+353', flag: '🇮🇪'),
    CountryModel(name: 'Israel', code: '+972', flag: '🇮🇱'),
    CountryModel(name: 'Italy', code: '+39', flag: '🇮🇹'),
    CountryModel(name: 'Ivory Coast', code: '+225', flag: '🇨🇮'),
    CountryModel(name: 'Jamaica', code: '+1-876', flag: '🇯🇲'),
    CountryModel(name: 'Japan', code: '+81', flag: '🇯🇵'),
    CountryModel(name: 'Jordan', code: '+962', flag: '🇯🇴'),
    CountryModel(name: 'Kazakhstan', code: '+7', flag: '🇰🇿'),
    CountryModel(name: 'Kenya', code: '+254', flag: '🇰🇪'),
    CountryModel(name: 'Kiribati', code: '+686', flag: '🇰🇮'),
    CountryModel(name: 'Kuwait', code: '+965', flag: '🇰🇼'),
    CountryModel(name: 'Kyrgyzstan', code: '+996', flag: '🇰🇬'),
    CountryModel(name: 'Laos', code: '+856', flag: '🇱🇦'),
    CountryModel(name: 'Latvia', code: '+371', flag: '🇱🇻'),
    CountryModel(name: 'Lebanon', code: '+961', flag: '🇱🇧'),
    CountryModel(name: 'Lesotho', code: '+266', flag: '🇱🇸'),
    CountryModel(name: 'Liberia', code: '+231', flag: '🇱🇷'),
    CountryModel(name: 'Libya', code: '+218', flag: '🇱🇾'),
    CountryModel(name: 'Liechtenstein', code: '+423', flag: '🇱🇮'),
    CountryModel(name: 'Lithuania', code: '+370', flag: '🇱🇹'),
    CountryModel(name: 'Luxembourg', code: '+352', flag: '🇱🇺'),
    CountryModel(name: 'Madagascar', code: '+261', flag: '🇲🇬'),
    CountryModel(name: 'Malawi', code: '+265', flag: '🇲🇼'),
    CountryModel(name: 'Malaysia', code: '+60', flag: '🇲🇾'),
    CountryModel(name: 'Maldives', code: '+960', flag: '🇲🇻'),
    CountryModel(name: 'Mali', code: '+223', flag: '🇲🇱'),
    CountryModel(name: 'Malta', code: '+356', flag: '🇲🇹'),
    CountryModel(name: 'Marshall Islands', code: '+692', flag: '🇲🇭'),
    CountryModel(name: 'Mauritania', code: '+222', flag: '🇲🇷'),
    CountryModel(name: 'Mauritius', code: '+230', flag: '🇲🇺'),
    CountryModel(name: 'Mexico', code: '+52', flag: '🇲🇽'),
    CountryModel(name: 'Micronesia', code: '+691', flag: '🇫🇲'),
    CountryModel(name: 'Moldova', code: '+373', flag: '🇲🇩'),
    CountryModel(name: 'Monaco', code: '+377', flag: '🇲🇨'),
    CountryModel(name: 'Mongolia', code: '+976', flag: '🇲🇳'),
    CountryModel(name: 'Montenegro', code: '+382', flag: '🇲🇪'),
    CountryModel(name: 'Morocco', code: '+212', flag: '🇲🇦'),
    CountryModel(name: 'Mozambique', code: '+258', flag: '🇲🇿'),
    CountryModel(name: 'Myanmar (Burma)', code: '+95', flag: '🇲🇲'),
    CountryModel(name: 'Namibia', code: '+264', flag: '🇳🇦'),
    CountryModel(name: 'Nauru', code: '+674', flag: '🇳🇷'),
    CountryModel(name: 'Nepal', code: '+977', flag: '🇳🇵'),
    CountryModel(name: 'Netherlands', code: '+31', flag: '🇳🇱'),
    CountryModel(name: 'New Zealand', code: '+64', flag: '🇳🇿'),
    CountryModel(name: 'Nicaragua', code: '+505', flag: '🇳🇮'),
    CountryModel(name: 'Niger', code: '+227', flag: '🇳🇪'),
    CountryModel(name: 'Nigeria', code: '+234', flag: '🇳🇬'),
    CountryModel(name: 'North Korea', code: '+850', flag: '🇰🇵'),
    CountryModel(name: 'North Macedonia', code: '+389', flag: '🇲🇰'),
    CountryModel(name: 'Norway', code: '+47', flag: '🇳🇴'),
    CountryModel(name: 'Oman', code: '+968', flag: '🇴🇲'),
    CountryModel(name: 'Pakistan', code: '+92', flag: '🇵🇰'),
    CountryModel(name: 'Palau', code: '+680', flag: '🇵🇼'),
    CountryModel(name: 'Palestine State', code: '+970', flag: '🇵🇸'),
    CountryModel(name: 'Panama', code: '+507', flag: '🇵🇦'),
    CountryModel(name: 'Papua New Guinea', code: '+675', flag: '🇵🇬'),
    CountryModel(name: 'Paraguay', code: '+595', flag: '🇵🇾'),
    CountryModel(name: 'Peru', code: '+51', flag: '🇵🇪'),
    CountryModel(name: 'Philippines', code: '+63', flag: '🇵🇭'),
    CountryModel(name: 'Poland', code: '+48', flag: '🇵🇱'),
    CountryModel(name: 'Portugal', code: '+351', flag: '🇵🇹'),
    CountryModel(name: 'Qatar', code: '+974', flag: '🇶🇦'),
    CountryModel(name: 'Romania', code: '+40', flag: '🇷🇴'),
    CountryModel(name: 'Russia', code: '+7', flag: '🇷🇺'),
    CountryModel(name: 'Rwanda', code: '+250', flag: '🇷🇼'),
    CountryModel(name: 'Saint Kitts and Nevis', code: '+1-869', flag: '🇰🇳'),
    CountryModel(name: 'Saint Lucia', code: '+1-758', flag: '🇱🇨'),
    CountryModel(
      name: 'Saint Vincent and the Grenadines',
      code: '+1-784',
      flag: '🇻🇨',
    ),
    CountryModel(name: 'Samoa', code: '+685', flag: '🇼🇸'),
    CountryModel(name: 'San Marino', code: '+378', flag: '🇸🇲'),
    CountryModel(name: 'Sao Tome and Principe', code: '+239', flag: '🇸🇹'),
    CountryModel(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦'),
    CountryModel(name: 'Senegal', code: '+221', flag: '🇸🇳'),
    CountryModel(name: 'Serbia', code: '+381', flag: '🇷🇸'),
    CountryModel(name: 'Seychelles', code: '+248', flag: '🇸🇨'),
    CountryModel(name: 'Sierra Leone', code: '+232', flag: '🇸🇱'),
    CountryModel(name: 'Singapore', code: '+65', flag: '🇸🇬'),
    CountryModel(name: 'Slovakia', code: '+421', flag: '🇸🇰'),
    CountryModel(name: 'Slovenia', code: '+386', flag: '🇸🇮'),
    CountryModel(name: 'Solomon Islands', code: '+677', flag: '🇸🇧'),
    CountryModel(name: 'Somalia', code: '+252', flag: '🇸🇴'),
    CountryModel(name: 'South Africa', code: '+27', flag: '🇿🇦'),
    CountryModel(name: 'South Korea', code: '+82', flag: '🇰🇷'),
    CountryModel(name: 'South Sudan', code: '+211', flag: '🇸🇸'),
    CountryModel(name: 'Spain', code: '+34', flag: '🇪🇸'),
    CountryModel(name: 'Sri Lanka', code: '+94', flag: '🇱🇰'),
    CountryModel(name: 'Sudan', code: '+249', flag: '🇸🇩'),
    CountryModel(name: 'Suriname', code: '+597', flag: '🇸🇷'),
    CountryModel(name: 'Sweden', code: '+46', flag: '🇸🇪'),
    CountryModel(name: 'Switzerland', code: '+41', flag: '🇨🇭'),
    CountryModel(name: 'Syria', code: '+963', flag: '🇸🇾'),
    CountryModel(name: 'Tajikistan', code: '+992', flag: '🇹🇯'),
    CountryModel(name: 'Tanzania', code: '+255', flag: '🇹🇿'),
    CountryModel(name: 'Thailand', code: '+66', flag: '🇹🇭'),
    CountryModel(name: 'Timor-Leste', code: '+670', flag: '🇹🇱'),
    CountryModel(name: 'Togo', code: '+228', flag: '🇹🇬'),
    CountryModel(name: 'Tonga', code: '+676', flag: '🇹🇴'),
    CountryModel(name: 'Trinidad and Tobago', code: '+1-868', flag: '🇹🇹'),
    CountryModel(name: 'Tunisia', code: '+216', flag: '🇹🇳'),
    CountryModel(name: 'Turkey', code: '+90', flag: '🇹🇷'),
    CountryModel(name: 'Turkmenistan', code: '+993', flag: '🇹🇲'),
    CountryModel(name: 'Tuvalu', code: '+688', flag: '🇹🇻'),
    CountryModel(name: 'Uganda', code: '+256', flag: '🇺🇬'),
    CountryModel(name: 'Ukraine', code: '+380', flag: '🇺🇦'),
    CountryModel(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪'),
    CountryModel(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    CountryModel(name: 'United States', code: '+1', flag: '🇺🇸'),
    CountryModel(name: 'Uruguay', code: '+598', flag: '🇺🇾'),
    CountryModel(name: 'Uzbekistan', code: '+998', flag: '🇺🇿'),
    CountryModel(name: 'Vanuatu', code: '+678', flag: '🇻🇺'),
    CountryModel(name: 'Venezuela', code: '+58', flag: '🇻🇪'),
    CountryModel(name: 'Vietnam', code: '+84', flag: '🇻🇳'),
    CountryModel(name: 'Yemen', code: '+967', flag: '🇾🇪'),
    CountryModel(name: 'Zambia', code: '+260', flag: '🇿🇲'),
    CountryModel(name: 'Zimbabwe', code: '+263', flag: '🇿🇼'),
  ];

  late CountryModel _selectedCountry;
  List<CountryModel> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _selectedCountry = _allCountries.firstWhere(
      (c) => c.name == 'Nigeria',
      orElse: () => _allCountries.first,
    );
    _filteredCountries = List.from(_allCountries);
  }

  void _navigateToVerificationScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (context, animation, secondaryAnimation) => const Verification(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _handleContinue() async {
    final phoneText = _phoneController.text.trim();
    if (phoneText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final fullPhoneNumber = '${_selectedCountry.code}$phoneText';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(fullPhoneNumber);

    if (mounted) {
      if (success) {
        _navigateToVerificationScreen(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP.'),
          ),
        );
      }
    }
  }

  void _showCountryPicker() {
    // Reset search when opening
    _searchController.clear();
    _filteredCountries = List.from(_allCountries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar and Close Button Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setModalState(() {
                                _filteredCountries =
                                    _allCountries
                                        .where(
                                          (country) =>
                                              country.name
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  ) ||
                                              country.code.contains(value),
                                        )
                                        .toList();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search country',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Country List
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredCountries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Text(
                                country.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  country.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                country.code,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/binoculars.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Login or create account to enjoy\nbetter experience on Quest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: _showCountryPicker,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+ ${_selectedCountry.code.replaceAll('+', '')}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: '000-000-0000',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OnboardingButton(
                        title: 'Continue',
                        isLoading: authProvider.isLoading,
                        ontap: _handleContinue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SocialButton(
                      label: 'Continue with Google',
                      iconAsset: 'assets/images/google_o.png',
                      onPressed: () async {
                        final success =
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).signInWithGoogle();
                        if (mounted && success) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const NavigationScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _SocialButton(
                      label: 'Continue with Apple',
                      iconAsset: 'assets/images/apple_o.png',
                      onPressed: () async {
                        final success =
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).signInWithApple();
                        if (mounted && success) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const NavigationScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'By signing up, you agree that the information you provide is accurate and complete. You acknowledge that your account is personal to you and should not be shared with others. We are not responsible for any loss, damages, or misuse of your account resulting from failure to keep your login details secure.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.iconAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade100, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(iconAsset, width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}
