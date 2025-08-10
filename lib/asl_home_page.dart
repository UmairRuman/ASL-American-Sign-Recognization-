import 'dart:developer';
import 'dart:io';

import 'package:asl_alphabet_recognition/widgets/action_buttons.dart';
import 'package:asl_alphabet_recognition/widgets/build_header.dart';
import 'package:asl_alphabet_recognition/widgets/build_image_section.dart';
import 'package:asl_alphabet_recognition/widgets/prediction_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ASLHomePage extends StatefulWidget {
  const ASLHomePage({super.key});

  @override
  State<ASLHomePage> createState() => _ASLHomePageState();
}

class _ASLHomePageState extends State<ASLHomePage>
    with TickerProviderStateMixin {
  Interpreter? _interpreter;
  String _prediction = "";
  File? _selectedImage;
  bool _isLoading = false;
  bool _isModelLoaded = false;
  late int _inputSize;
  final ImagePicker _picker = ImagePicker();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _classNames = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'del',
    'nothing',
    'space',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadModel();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  Future<void> _loadModel() async {
    try {
      setState(() => _isLoading = true);

      _interpreter = await Interpreter.fromAsset(
        'assets/asl_model_simple.tflite',
      );

      var inputShape = _interpreter!.getInputTensor(0).shape;
      _inputSize = inputShape[1];

      setState(() {
        _isModelLoaded = true;
        _isLoading = false;
      });

      _slideController.forward();
      _fadeController.forward();

      log("Model loaded successfully with input size $_inputSize");
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to load model: $e");
      log("Error loading model: $e");
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
    File imageFile,
  ) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) throw Exception("Could not decode image");

    image = img.copyResize(image, width: 100, height: 100);

    List<List<List<List<double>>>> input = [
      List.generate(100, (y) {
        return List.generate(100, (x) {
          final pixel = image!.getPixel(x, y);
          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        });
      }),
    ];

    return input;
  }

  Future<void> _pickImageFromGallery() async {
    HapticFeedback.lightImpact();
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorDialog("Failed to pick image: $e");
    }
  }

  Future<void> _pickImageFromCamera() async {
    HapticFeedback.lightImpact();
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorDialog("Failed to capture image: $e");
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _isLoading = true;
      _prediction = "";
    });

    try {
      await _runInference(imageFile);
    } catch (e) {
      _showErrorDialog("Failed to process image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runInference(File imageFile) async {
    if (_interpreter == null) return;

    final input = await _preprocessImage(imageFile);
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    var outputBuffer = List.filled(
      outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape([1, outputShape[1]]);

    _interpreter!.run(input, outputBuffer);

    List<double> firstOutput = List<double>.from(outputBuffer[0]);
    int predictedIndex = 0;
    double maxConfidence = firstOutput[0];

    for (int i = 1; i < firstOutput.length; i++) {
      if (firstOutput[i] > maxConfidence) {
        maxConfidence = firstOutput[i];
        predictedIndex = i;
      }
    }

    setState(() {
      if (predictedIndex < _classNames.length) {
        _prediction = _classNames[predictedIndex];
      } else {
        _prediction = "Unknown";
      }
    });

    // Trigger success animation
    HapticFeedback.selectionClick();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1D1E33),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF00D4AA)),
                ),
              ),
            ],
          ),
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onPressed: _isModelLoaded ? _pickImageFromGallery : null,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onPressed: _isModelLoaded ? _pickImageFromCamera : null,
                gradient: const LinearGradient(
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_selectedImage != null)
          buildActionButton(
            icon: Icons.refresh,
            label: 'Clear Image',
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _prediction = "";
              });
              HapticFeedback.lightImpact();
            },
            gradient: const LinearGradient(
              colors: [Color(0xFF434343), Color(0xFF000000)],
            ),
            isFullWidth: true,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E21), Color(0xFF1D1E33), Color(0xFF2A2D3A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildHeader(_isModelLoaded),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        buildImageSection(
                          _slideAnimation,
                          _fadeAnimation,
                          _selectedImage,
                          _isLoading,
                          _pulseAnimation,
                        ),
                        const SizedBox(height: 30),
                        buildPredictionSection(_prediction),
                        const SizedBox(height: 40),
                        buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
