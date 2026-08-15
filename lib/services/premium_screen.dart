import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gta_6_comapnion_app/premium_gallery_screen.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';
import 'package:gta_6_comapnion_app/premium_vehicles_screen.dart';
import 'package:gta_6_comapnion_app/premium_properties_screen.dart';
import 'package:gta_6_comapnion_app/advanced_map_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();

    premiumState.addListener(_onPremiumChanged);

    // Safe to call again.
    premiumState.initialize();
  }

  void _onPremiumChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  // ===============================================================
  // PREMIUM FEATURE NAVIGATION
  // ===============================================================

  void _openPremiumFeature({
    required String title,
    required Widget? screen,
  }) {
    // Premium not unlocked
    if (!premiumState.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🔒 Unlock GTA 6 PRO to access this feature.',
          ),
          backgroundColor: Color(0xFF1B1B1B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Feature exists → open it
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      );
      return;
    }

    // Feature not built yet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚧 $title is coming soon!',
        ),
        backgroundColor: const Color(0xFF1B1B1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final product = premiumState.premiumProduct;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: Text(
          'GTA 6 PRO',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 15),

              // =====================================================
              // PRO ICON
              // =====================================================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF006E),
                      Color(0xFF8338EC),
                      Color(0xFF3A86FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.35),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.amber,
                  size: 55,
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TITLE
              // =====================================================

              Text(
                premiumState.isPremium
                    ? 'GTA 6 PRO ACTIVE'
                    : 'UNLOCK GTA 6 PRO',
                textAlign: TextAlign.center,
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: const Color(0xFFFF4DA6),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                premiumState.isPremium
                    ? 'You have unlocked the ultimate GTA 6 Companion experience.'
                    : 'Unlock exclusive features and take your GTA 6 experience to the next level.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // =====================================================
              // PREMIUM FEATURES
              // =====================================================

              // 🏠 PROPERTY DATABASE
              _feature(
                '🏠',
                'Premium Property Database',
                onTap: () {
                  _openPremiumFeature(
                    title: 'Premium Property Database',
                    screen: const PremiumPropertiesScreen(),
                  );
                },
              ),

              // 🗺️ ADVANCED MAP
              _feature(
                '🗺️',
                'Advanced Map',
                onTap: () {
                  _openPremiumFeature(
                    title: 'Advanced Map',
                    screen: const AdvancedMapScreen(),
                  );
                },
              ),

              // 🚗 VEHICLE DATABASE
              _feature(
                '🚗',
                'Premium Vehicle Information',
                onTap: () {
                  _openPremiumFeature(
                    title: 'Premium Vehicle Information',
                    screen: const PremiumVehiclesScreen(),
                  );
                },
              ),

              // 🖼️ PREMIUM GALLERY
             _feature(
  '🖼️',
  'Premium Gallery',
  onTap: () {
    _openPremiumFeature(
      title: 'Premium Gallery',
      screen: const PremiumGalleryScreen(),
    );
  },
),

              // 🔔 PREMIUM ALERTS
              _feature(
                '🔔',
                'Premium Alerts',
                onTap: () {
                  _openPremiumFeature(
                    title: 'Premium Alerts',
                    screen: null,
                  );
                },
              ),

              // 🚫 AD-FREE EXPERIENCE
              _feature(
                '🚫',
                'Ad-Free Experience',
                onTap: () {
                  if (!premiumState.isPremium) {
                    _openPremiumFeature(
                      title: 'Ad-Free Experience',
                      screen: null,
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✅ Ad-Free Experience is active!',
                      ),
                      backgroundColor: Color(0xFF1B1B1B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // =====================================================
              // PRICE
              // =====================================================

              if (!premiumState.isPremium && product != null)
                Text(
                  product.price,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: const Color(0xFF00D4FF),
                  ),
                ),

              if (!premiumState.isPremium && product == null)
                Text(
                  premiumState.isLoading
                      ? 'Loading price...'
                      : 'Price shown by Google Play',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

              if (!premiumState.isPremium)
                Text(
                  'One-time purchase',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

              const SizedBox(height: 25),

              // =====================================================
              // PURCHASE / ACTIVE BUTTON
              // =====================================================

              if (premiumState.isPremium)
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'GTA 6 PRO ACTIVE',
                        style: GoogleFonts.bebasNeue(
                          color: Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: premiumState.isLoading
                        ? null
                        : premiumState.buyPremium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4DA6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: premiumState.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'UNLOCK PRO',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),

              const SizedBox(height: 15),

              // =====================================================
              // RESTORE PURCHASE
              // =====================================================

              if (!premiumState.isPremium)
                TextButton(
                  onPressed: premiumState.isLoading
                      ? null
                      : premiumState.restorePurchases,
                  child: Text(
                    'Restore Purchase',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                    ),
                  ),
                ),

              // =====================================================
              // ERROR
              // =====================================================

              if (premiumState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      premiumState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // =====================================================
              // GOOGLE PLAY PAYMENT
              // =====================================================

              Text(
                'Secure payment through Google Play',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PREMIUM FEATURE CARD
  // ===============================================================

  Widget _feature(
    String icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: premiumState.isPremium
                ? const Color(0xFFFF4DA6).withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 25,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              premiumState.isPremium
                  ? Icons.arrow_forward_ios
                  : Icons.lock_outline,
              color: premiumState.isPremium
                  ? const Color(0xFF00D4FF)
                  : Colors.white38,
              size: premiumState.isPremium ? 17 : 22,
            ),
          ],
        ),
      ),
    );
  }
}