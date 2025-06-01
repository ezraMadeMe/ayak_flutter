// screens/illness_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/constants/app_styles.dart';
import 'package:yakunstructuretest/data/models/illness_model.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/illness_provider.dart';

class IllnessSearchScreen extends StatefulWidget {
  const IllnessSearchScreen({Key? key}) : super(key: key);

  @override
  State<IllnessSearchScreen> createState() => _IllnessSearchScreenState();
}

class _IllnessSearchScreenState extends State<IllnessSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _illnessNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isChronic = false;

  @override
  void initState() {
    super.initState();
    // 현재 사용자의 등록된 질병/증상 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<IllnessProvider>().loadMyIllnesses(
          authProvider.currentUser!.userId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('질병/증상 등록', style: AppTextStyles.titleBold),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              SizedBox(height: 24),
              _buildSearchSection(),
              SizedBox(height: 24),
              _buildSearchResults(),
              SizedBox(height: 24),
              _buildIllnessInfoSection(),
              SizedBox(height: 32),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setInputType(IllnessInputType.disease),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: provider.isDiseaseMode
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital,
                          color: provider.isDiseaseMode
                              ? Colors.white
                              : Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '질병',
                          style: TextStyle(
                            color: provider.isDiseaseMode
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setInputType(IllnessInputType.symptom),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: provider.isSymptomMode
                          ? AppColors.secondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.healing,
                          color: provider.isSymptomMode
                              ? Colors.white
                              : Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '증상',
                          style: TextStyle(
                            color: provider.isSymptomMode
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        if (provider.isSymptomMode) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  //
                  AppColors.secondary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20), //
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
              ), //
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8), //
                  decoration: BoxDecoration(
                    color: AppColors.secondary, //
                    borderRadius: BorderRadius.circular(12), //
                  ),
                  child: Icon(Icons.healing, color: Colors.white, size: 20), //
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //
                    children: [
                      Text(
                        '질병명 직접 입력', //
                        style: TextStyle(
                          //
                          fontWeight: FontWeight.bold,
                          color: AppColors
                              .secondary, // Corrected: Was 'isSelected ? AppColors.secondary : Colors.black' [cite: 38]
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        //
                        '검색 결과에 원하는 질병이 없는 경우', //
                        style: TextStyle(
                          color: Colors.grey[600], //
                          fontSize: 12, //
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildIllnessInfoSection() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        final isManualInputEnabled =
            provider.isManualInput || provider.isSymptomMode;
        final hasSelectedIllness = provider.selectedIllness != null;

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${provider.isSymptomMode ? "증상" : "질병"} 정보 입력',
                style: AppTextStyles.titleBold,
              ),
              SizedBox(height: 16),

              // 질병/증상명 입력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isSymptomMode ? "증상명" : "질병명",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _illnessNameController,
                    readOnly: !isManualInputEnabled && hasSelectedIllness,
                    decoration: InputDecoration(
                      hintText: provider.isSymptomMode
                          ? '겪고 계신 증상을 입력하세요'
                          : isManualInputEnabled
                          ? '질병명을 입력하세요'
                          : '질병을 선택하거나 직접 입력을 선택하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: (!isManualInputEnabled && hasSelectedIllness)
                          ? Colors.grey[100]
                          : Colors.white,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 시작일 입력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.isSymptomMode ? '증상 시작일' : '진단일/발병일',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectStartDate(),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDateController.text.isEmpty
                                ? '날짜를 선택하세요'
                                : _startDateController.text,
                            style: TextStyle(
                              color: _startDateController.text.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 완치일 입력 (선택사항)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        provider.isSymptomMode ? '증상 종료일' : '완치일',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(선택사항)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectEndDate(),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDateController.text.isEmpty
                                ? '완치된 경우 날짜를 선택하세요'
                                : _endDateController.text,
                            style: TextStyle(
                              color: _endDateController.text.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              if (_endDateController.text.isNotEmpty) ...[
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _endDateController.clear();
                                      _isChronic = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                SizedBox(width: 8),
                              ],
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 만성 질환 여부
              if (!provider.isSymptomMode) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _isChronic,
                      onChanged: (value) {
                        setState(() {
                          _isChronic = value ?? false;
                          if (_isChronic) {
                            _endDateController.clear(); // 만성 질환이면 완치일 제거
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        '만성 질환입니다',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isChronic) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 32),
                    child: Text(
                      '지속적인 관리가 필요한 질환입니다',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _registerIllness,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: provider.isSymptomMode
                  ? AppColors.secondary
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '등록 중...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '${provider.isSymptomMode ? "증상" : "질병"} 등록',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '시작일을 선택하세요',
    );

    if (picked != null) {
      setState(() {
        _startDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? initialDate = DateTime.now();
    DateTime? firstDate = DateTime(1900);

    // 시작일이 설정되어 있으면 그 이후부터 선택 가능
    if (_startDateController.text.isNotEmpty) {
      try {
        final startDate = DateTime.parse(_startDateController.text);
        firstDate = startDate;
        if (initialDate.isBefore(startDate)) {
          initialDate = startDate;
        }
      } catch (e) {
        // 파싱 실패시 기본값 사용
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate!,
      lastDate: DateTime.now(),
      helpText: '완치일을 선택하세요',
    );

    if (picked != null) {
      setState(() {
        _endDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _isChronic = false; // 완치일이 설정되면 만성 질환 해제
      });
    }
  }

  Future<void> _registerIllness() async {
    final illnessName = _illnessNameController.text.trim();
    final startDateText = _startDateController.text.trim();

    if (illnessName.isEmpty) {
      final provider = context.read<IllnessProvider>();
      _showSnackBar(
        provider.isSymptomMode ? '증상명을 입력해주세요' : '질병명을 입력해주세요',
        isError: true,
      );
      return;
    }

    if (startDateText.isEmpty) {
      final provider = context.read<IllnessProvider>();
      _showSnackBar(
        provider.isSymptomMode ? '증상 시작일을 선택해주세요' : '진단일/발병일을 선택해주세요',
        isError: true,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showSnackBar('사용자 정보를 찾을 수 없습니다', isError: true);
      return;
    }

    try {
      final startDate = DateTime.parse(startDateText);
      DateTime? endDate;

      if (_endDateController.text.isNotEmpty) {
        endDate = DateTime.parse(_endDateController.text);
      }

      final illnessProvider = context.read<IllnessProvider>();
      final success = await illnessProvider.registerIllness(
        userId: authProvider.currentUser!.userId,
        illnessName: illnessName,
        startDate: startDate,
        endDate: endDate,
        isChronic: _isChronic,
      );

      if (success) {
        _showSnackBar(
          illnessProvider.isSymptomMode
              ? '증상이 성공적으로 등록되었습니다'
              : '질병이 성공적으로 등록되었습니다',
        );
        Navigator.of(context).pop();
      } else {
        _showSnackBar(illnessProvider.error ?? '등록에 실패했습니다', isError: true);
      }
    } catch (e) {
      _showSnackBar('날짜 형식이 올바르지 않습니다', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _illnessNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // Widget _buildQuickActionButton(

  Widget _buildSearchResults() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        if (provider.isSymptomMode) {
          return _buildMyIllnessesWidget(provider.myIllnesses);
        }

        if (provider.isLoading) {
          return _buildLoadingWidget();
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider.error!);
        }

        if (provider.searchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          return _buildNoResultsWidget();
        }

        if (provider.searchResults.isEmpty) {
          return _buildMyIllnessesWidget(provider.myIllnesses);
        }

        return _buildResultsList(provider);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('질병 정보를 검색중입니다...', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 32),
          SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.red)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<IllnessProvider>().clearError(),
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: Colors.grey[400], size: 48),
          SizedBox(height: 16),
          Text('검색 결과가 없습니다', style: AppTextStyles.subtitle),
          SizedBox(height: 8),
          Text('질병명을 정확히 입력하거나\n직접 입력을 선택해주세요', style: AppTextStyles.caption),
          SizedBox(height: 16),
          _buildManualInputOption(),
        ],
      ),
    );
  }

  Widget _buildMyIllnessesWidget(List<Illness> myIllnesses) {
    if (myIllnesses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.medical_information_outlined,
                color: Colors.grey[400],
                size: 48,
              ),
              SizedBox(height: 16),
              Text('등록된 질병/증상이 없습니다', style: AppTextStyles.subtitle),
              Text('질병을 검색하거나 증상을 입력해보세요', style: AppTextStyles.caption),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 질병/증상 목록', style: AppTextStyles.titleBold),
        SizedBox(height: 12),
        ...myIllnesses.map((illness) => _buildIllnessCard(illness, false)),
      ],
    );
  }

  Widget _buildResultsList(IllnessProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('검색 결과', style: AppTextStyles.titleBold),
        SizedBox(height: 12),
        ...provider.searchResults.map(
          (illness) => _buildIllnessCard(
            illness,
            provider.selectedIllness == illness && !provider.isManualInput,
          ),
        ),
        SizedBox(height: 12),
        _buildManualInputOption(),
      ],
    );
  }

  Widget _buildIllnessCard(Illness illness, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<IllnessProvider>();
        if (isSelected) {
          provider.selectIllness(null);
        } else {
          provider.selectIllness(illness);
          _illnessNameController.text = illness.illName;
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : illness.iconData,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    illness.illName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  if (illness.illCode != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'ICD-10: ${illness.illCode}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: illness.isDisease
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      illness.displayType,
                      style: TextStyle(
                        color: illness.isDisease ? Colors.blue : Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputOption() {
    return Consumer<IllnessProvider>(
      builder: (context, provider, child) {
        if (provider.isSymptomMode) return SizedBox.shrink();

        final isSelected = provider.isManualInput;

        return GestureDetector(
          onTap: () {
            provider.setManualInput(!isSelected);
            if (!isSelected) {
              _illnessNameController.clear();
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.edit,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '질병명 직접 입력',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.secondary
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '검색 결과에 원하는 질병이 없는 경우',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
