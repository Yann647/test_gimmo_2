import 'package:flutter/material.dart';
import 'package:test_gimmo_2/loginscreen.dart';
import 'package:test_gimmo_2/signupscreen.dart';
import 'package:test_gimmo_2/storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isScrolled = false;
  bool _isLoggedIn = false; // À remplacer par votre gestion d'authentification

  Future<void> logout() async {
    await Storage.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildNavbar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels > 50 && !_isScrolled) {
            setState(() => _isScrolled = true);
          } else if (scrollNotification.metrics.pixels <= 50 && _isScrolled) {
            setState(() => _isScrolled = false);
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              _buildFeaturesSection(),
              if (!_isLoggedIn) _buildCtaSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNavbar() {
    return AppBar(
      elevation: _isScrolled ? 4 : 0,
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      title: Text(
        'Gimmo',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _isScrolled ? Colors.black87 : Colors.white,
        ),
      ),
      iconTheme: IconThemeData(
        color: _isScrolled ? Colors.black87 : Colors.white,
      ),
      actions: [
        if (!_isLoggedIn) ...[
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: TextButton.styleFrom(
              foregroundColor: _isScrolled ? Colors.black87 : Colors.white,
            ),
            child: const Text('Connexion'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()));
            },
            style: TextButton.styleFrom(
              foregroundColor: _isScrolled ? Colors.black87 : Colors.white,
            ),
            child: const Text(
              "S'inscrire",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ] else
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: _isScrolled ? Colors.black87 : Colors.white,
            ),
            child: const Text('Tableau de bord'),
          ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.8
          : MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
        child: isMobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Gérez votre patrimoine immobilier en toute simplicité',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'La plateforme complète pour les agences immobilières et propriétaires',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoggedIn ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text(
                            _isLoggedIn
                                ? 'Accéder au tableau de bord'
                                : 'Commencer gratuitement',
                            style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: const BorderSide(color: Colors.white)),
                        ),
                        child: const Text('Découvrir',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&fit=crop',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gérez votre patrimoine immobilier en toute simplicité',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'La plateforme complète pour les agences immobilières et propriétaires',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isLoggedIn ? () {} : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              child: Text(
                                  _isLoggedIn
                                      ? 'Accéder au tableau de bord'
                                      : 'Commencer gratuitement',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    side:
                                        const BorderSide(color: Colors.white)),
                              ),
                              child: const Text('Découvrir',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      color: Colors.grey[50],
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 80.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        children: [
          Text(
            'Fonctionnalités principales',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tout ce dont vous avez besoin pour gérer votre activité',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Boutons d'action rapide (si connecté)
          if (_isLoggedIn)
            isMobile
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                          icon: '📄', label: 'Contrats', color: Colors.blue),
                      _ActionButton(
                          icon: '🏠', label: 'Propriétés', color: Colors.green),
                      _ActionButton(
                          icon: '📅',
                          label: 'Réservations',
                          color: Colors.cyan),
                      _ActionButton(
                          icon: '👤',
                          label: 'Utilisateurs',
                          color: Colors.orange),
                    ],
                  )
                : const Row(
                    children: [
                      Expanded(
                          child: _ActionButton(
                              icon: '📄',
                              label: 'Contrats',
                              color: Colors.blue)),
                      SizedBox(width: 10),
                      Expanded(
                          child: _ActionButton(
                              icon: '🏠',
                              label: 'Propriétés',
                              color: Colors.green)),
                      SizedBox(width: 10),
                      Expanded(
                          child: _ActionButton(
                              icon: '📅',
                              label: 'Réservations',
                              color: Colors.cyan)),
                      SizedBox(width: 10),
                      Expanded(
                          child: _ActionButton(
                              icon: '👤',
                              label: 'Utilisateurs',
                              color: Colors.orange)),
                    ],
                  ),

          const SizedBox(height: 40),

          // Cartes de fonctionnalités
          if (isMobile)
            Column(
              children: [
                _FeatureCard(
                  icon: '🏢',
                  title: 'Gestion des propriétés',
                  description:
                      'Gérez facilement l\'ensemble de votre portefeuille immobilier en un seul endroit',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: '📋',
                  title: 'Contrats & Réservations',
                  description:
                      'Créez, suivez et gérez tous vos contrats et réservations efficacement',
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  icon: '👥',
                  title: 'Gestion d\'équipe',
                  description:
                      'Collaborez avec votre équipe et gérez les accès selon les rôles',
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: '🏢',
                    title: 'Gestion des propriétés',
                    description:
                        'Gérez facilement l\'ensemble de votre portefeuille immobilier en un seul endroit',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _FeatureCard(
                    icon: '📋',
                    title: 'Contrats & Réservations',
                    description:
                        'Créez, suivez et gérez tous vos contrats et réservations efficacement',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _FeatureCard(
                    icon: '👥',
                    title: 'Gestion d\'équipe',
                    description:
                        'Collaborez avec votre équipe et gérez les accès selon les rôles',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 80.0,
        vertical: isMobile ? 40.0 : 80.0,
      ),
      child: Column(
        children: [
          Text(
            'Prêt à commencer ?',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Rejoignez les agences immobilières qui font confiance à Gimmo',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              minimumSize: Size(isMobile ? double.infinity : 300, 50),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('Créer un compte gratuitement',
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Text('© 2024 Gimmo - Designed and Developed by Yann',
            style: TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('$icon $label'),
    );
  }
}
