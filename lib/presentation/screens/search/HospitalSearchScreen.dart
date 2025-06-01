// screens/hospital_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yakunstructuretest/constants/app_styles.dart';
import 'package:yakunstructuretest/data/models/hospital_model.dart';
import 'package:yakunstructuretest/presentation/providers/auth_provider.dart';
import 'package:yakunstructuretest/presentation/providers/hospital_provider.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({Key? key}) : super(key: key);

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 현재 사용자의 등록된 병원 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<HospitalProvider>().loadMyHospitals(authProvider.currentUser!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('병원 등록', style: AppTextStyles.titleBold),
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
              _buildSearchSection(),
              SizedBox(height: 24),
              _buildSearchResults(),
              SizedBox(height: 24),
              _buildHospitalInfoSection(),
              SizedBox(height: 32),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_hospital, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('병원 검색', style: AppTextStyles.titleBold),
                  Text('내원하실 병원을 검색하세요', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
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
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '병원명을 입력하세요',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<HospitalProvider>().searchHospitals(value.trim());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<HospitalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingWidget();
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider.error!);
        }

        if (provider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
          return _buildNoResultsWidget();
        }

        if (provider.searchResults.isEmpty) {
          return _buildMyHospitalsWidget(provider.myHospitals);
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
            Text('병원 정보를 검색중입니다...', style: AppTextStyles.caption),
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
            onPressed: () => context.read<HospitalProvider>().clearError(),
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
          Text('병원명을 정확히 입력하거나\n직접 입력을 선택해주세요', style: AppTextStyles.caption),
          SizedBox(height: 16),
          _buildManualInputOption(),
        ],
      ),
    );
  }

  Widget _buildMyHospitalsWidget(List<Hospital> myHospitals) {
    if (myHospitals.isEmpty) {
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
              Icon(Icons.local_hospital_outlined, color: Colors.grey[400], size: 48),
              SizedBox(height: 16),
              Text('등록된 병원이 없습니다', style: AppTextStyles.subtitle),
              Text('병원명을 검색하여 등록해보세요', style: AppTextStyles.caption),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 병원 목록', style: AppTextStyles.titleBold),
        SizedBox(height: 12),
        ...myHospitals.map((hospital) => _buildHospitalCard(hospital, false)),
      ],
    );
  }

  Widget _buildResultsList(HospitalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('검색 결과', style: AppTextStyles.titleBold),
        SizedBox(height: 12),
        ...provider.searchResults.map((hospital) => _buildHospitalCard(
          hospital,
          provider.selectedHospital == hospital && !provider.isManualInput,
        )),
        SizedBox(height: 12),
        _buildManualInputOption(),
      ],
    );
  }

  Widget _buildHospitalCard(Hospital hospital, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<HospitalProvider>();
        if (isSelected) {
          provider.selectHospital(null);
        } else {
          provider.selectHospital(hospital);
          _hospitalNameController.text = hospital.hospName;
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
                isSelected ? Icons.check_circle : Icons.local_hospital,
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
                    hospital.hospName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  if (hospital.hospType != null) ...[
                    SizedBox(height: 4),
                    Text(
                      hospital.hospType!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (hospital.address != null) ...[
                    SizedBox(height: 4),
                    Text(
                      hospital.address!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hospital.phoneNumber != null) ...[
                    SizedBox(height: 4),
                    Text(
                      hospital.phoneNumber!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputOption() {
    return Consumer<HospitalProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.isManualInput;

        return GestureDetector(
          onTap: () {
            provider.setManualInput(!isSelected);
            if (!isSelected) {
              _hospitalNameController.clear();
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
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
                        '병원명 직접 입력',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.secondary : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '검색 결과에 원하는 병원이 없는 경우',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
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

  Widget _buildHospitalInfoSection() {
    return Consumer<HospitalProvider>(
      builder: (context, provider, child) {
        final isManualInputEnabled = provider.isManualInput;
        final hasSelectedHospital = provider.selectedHospital != null;

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
              Text('병원 정보 입력', style: AppTextStyles.titleBold),
              SizedBox(height: 16),

              // 병원명 입력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '병원명',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _hospitalNameController,
                    readOnly: !isManualInputEnabled && hasSelectedHospital,
                    decoration: InputDecoration(
                      hintText: isManualInputEnabled ? '병원명을 입력하세요' : '병원을 선택하거나 직접 입력을 선택하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: (!isManualInputEnabled && hasSelectedHospital)
                          ? Colors.grey[100]
                          : Colors.white,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 담당의 입력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '담당의',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _doctorNameController,
                    decoration: InputDecoration(
                      hintText: '담당의 이름을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<HospitalProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _registerHospital,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
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
              '병원 등록',
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

  Future<void> _registerHospital() async {
    final hospitalName = _hospitalNameController.text.trim();
    final doctorName = _doctorNameController.text.trim();

    if (hospitalName.isEmpty) {
      _showSnackBar('병원명을 입력해주세요', isError: true);
      return;
    }

    if (doctorName.isEmpty) {
      _showSnackBar('담당의 이름을 입력해주세요', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showSnackBar('사용자 정보를 찾을 수 없습니다', isError: true);
      return;
    }

    final hospitalProvider = context.read<HospitalProvider>();
    final success = await hospitalProvider.registerHospital(
      "2502157085",
      hospitalName,
      doctorName,
    );

    if (success) {
      _showSnackBar('병원이 성공적으로 등록되었습니다');
      Navigator.of(context).pop();
    } else {
      _showSnackBar(
        hospitalProvider.error ?? '병원 등록에 실패했습니다',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hospitalNameController.dispose();
    _doctorNameController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
