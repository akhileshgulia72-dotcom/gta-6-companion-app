import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
# Privacy Policy

**Effective Date:** July 21, 2026

Welcome to **GTA 6 Companion** ("the App"). We value your privacy and are committed to protecting your personal information. This Privacy Policy explains what information we collect, how we use it, and the choices available to you when using the App.

By using GTA 6 Companion, you agree to the practices described in this Privacy Policy.

---

# 1. Information We Collect

## Information You Provide

Certain features of the App, such as Lucky Draw participation, may require you to provide:

* Full Name
* Phone Number

This information is collected solely for managing Lucky Draw participation, verifying winners, and contacting prize winners when necessary.

## Information Collected Automatically

When you use the App, certain information may be collected automatically by the App or trusted third-party services, including:

* Device information
* Operating system and device model
* App usage information
* Crash diagnostics
* Advertising identifiers
* IP address (through third-party services)

---

# 2. Coins and Local App Data

The App stores certain information on your device to provide its features, including:

* Coin balance
* Quiz progress
* Daily quiz availability
* Lucky Draw entries
* Watch & Earn progress
* Reward history
* App preferences

Most of this information is stored locally on your device to improve your experience.

---

# 3. Watch & Earn Feature

The App includes a **Watch & Earn** feature that allows users to voluntarily watch rewarded advertisements in exchange for virtual in-app coins.

Coins earned through this feature:

* Have no real-world cash value.
* Can only be used for eligible in-app features such as Lucky Draw participation, where available.
* Cannot be exchanged for money unless explicitly stated by the App.

Rewarded advertisements are provided by trusted advertising partners.

---

# 4. Advertising

The App displays advertisements using **Google AdMob**, including:

* Banner Ads
* Rewarded Ads
* Interstitial Ads (where applicable)

Google AdMob may collect certain information, including advertising identifiers and device information, to provide and improve advertising services.

For more information, please review Google's Privacy Policy:

https://policies.google.com/privacy

---

# 5. News Content

The App provides GTA VI-related news from third-party news providers.

We do not claim ownership of any news articles, headlines, images, or other content supplied by these providers. All trademarks, copyrights, and content belong to their respective owners.

---

# 6. External Links

Some content within the App may contain links to external websites.

We are not responsible for the privacy practices, content, or policies of third-party websites. We encourage users to review the privacy policies of those websites before providing any personal information.

---

# 7. Lucky Draw

Participation in Lucky Draw events is optional.

When participating, users may be asked to provide their name and phone number for prize administration purposes.

Providing inaccurate or misleading information may result in disqualification.

---

# 8. Children's Privacy

The App is not intended for children under the age of 13.

We do not knowingly collect personal information from children under 13. If we become aware that such information has been collected, appropriate steps will be taken to remove it.

---

# 9. Data Security

We use reasonable administrative and technical measures to help protect information collected through the App.

However, no method of electronic storage or internet transmission can be guaranteed to be completely secure.

---

# 10. Third-Party Services

The App may use trusted third-party services, including:

* Google AdMob
* Google Play Services
* News API providers

These services operate under their own privacy policies.

---

# 11. Changes to This Privacy Policy

We may update this Privacy Policy periodically to reflect changes to the App or legal requirements.

The updated version will be published with a revised Effective Date. Continued use of the App after updates constitutes acceptance of the revised Privacy Policy.

---

# 12. Contact Us

If you have any questions or concerns regarding this Privacy Policy, please contact us at:

**Email:** [akhileshgulia2311@gmail.com](mailto:akhileshgulia2311@gmail.com)

---

By downloading or using GTA 6 Companion, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.



          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}