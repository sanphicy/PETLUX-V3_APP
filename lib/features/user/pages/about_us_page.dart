import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlux/common/config/app_constants.dart';
import 'package:petlux/common/theme/app_theme.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 5 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 5 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = AppTheme.primaryPurple;
    const Color titleBgColor = Color(0xFFE8E2F0);
    const Color pageBgColor = Color(0xFFFEF7FF);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: _isScrolled ? titleBgColor : pageBgColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              "We are an innovative company specializing in intelligent pet care products, committed to elevating the quality of life for pets and their companions through cutting-edge technology. Our product line includes pet health monitoring systems, smart feeders, automated litter boxes, and wearable devices, all engineered to bring convenience, comfort, and peace of mind to pet families worldwide.",
            ),
            _buildSectionTitle("Our Mission"),
            _buildParagraph(
              "We believe advanced AI technology can create a more harmonious living space for pets and their owners. Our devices analyze pet behavior and wellness metrics in real time, helping owners detect anomalies early and take prompt action. From climate-adaptive shelters to personalized care insights, we strive to make technology the ultimate bridge connecting pets with their families.",
            ),
            _buildSectionTitle("Why Choose Us?"),
            _buildBulletPoint(
              "Comprehensive Ecosystem",
              "Our product ecosystem covers every aspect of pet life—nutrition, health, hygiene, and recreation. For instance, our smart feeders track eating patterns alongside scheduled feeding, while our automatic litter boxes log visit data to offer proactive wellness insights.",
            ),
            _buildBulletPoint(
              "Global Reach, Local Adaptation",
              "Serving users across more than 40 countries and regions, we tailor products to meet diverse global needs. Whether it's high-aesthetic industrial design or groundbreaking mobile pet companions, we ensure our solutions resonate with families everywhere.",
            ),
            _buildBulletPoint(
              "Continuous Innovation",
              "We integrate artificial intelligence, IoT, and cloud computing to redefine standards in pet care, making pet parenting smarter, effortless, and more rewarding.",
            ),
            _buildSectionTitle("Shape the Future with Us"),
            _buildParagraph(
              "With the pet tech market expanding rapidly, we are dedicated to leading this transformative journey. Let's work together to create a brighter, healthier future for pets and their homes.",
            ),
            const SizedBox(height: 10),
            _buildParagraph("If you have any questions or feedback, please feel free to contact us:"),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.email_outlined, size: 18, color: primaryPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                            children: const [
                              TextSpan(
                                text: "Email: ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              TextSpan(text: AppConstants.officialEmail),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.language_outlined, size: 18, color: primaryPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                            children: const [
                              TextSpan(
                                text: "Website: ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              TextSpan(text: AppConstants.officialWebsite),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, softWrap: true, style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Text(
        title,
        softWrap: true,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      ),
    );
  }

  Widget _buildBulletPoint(String boldTitle, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6),
          children: [
            const TextSpan(text: "• "),
            TextSpan(
              text: "$boldTitle: ",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
