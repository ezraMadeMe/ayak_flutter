import 'package:flutter/material.dart';


class BasicInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 정보 등록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      '한번 등록하면 계속 사용되는 정보들',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 기본 정보 버튼들
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 상단 3개 버튼
                  Row(
                    children: [
                      Expanded(
                        child: _buildBasicInfoTile(
                          context,
                          '병원 등록',
                          '자주 가는 병원 정보',
                          Icons.local_hospital,
                          Color(0xFF4CAF50),
                          () => Navigator.pushNamed(context, '/register-hospital'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildBasicInfoTile(
                          context,
                          '질병/증상 등록',
                          '진단명/나타나는 증상',
                          Icons.account_tree_outlined,
                          Color(0xFFE91E63),
                          () => Navigator.pushNamed(context, '/register-illness'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildBasicInfoTile(
                          context,
                          '처방전 등록',
                          '처방전 정보',
                          Icons.description_outlined,
                          Color(0xFF2196F3),
                          () => Navigator.pushNamed(context, '/register-prescription'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // 하단 2개 버튼
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBasicInfoTile(
                          context,
                          '의료 정보 등록',
                          '병원 + 질병/증상 + 처방전까지 연관 정보 원터치 등록',
                          Icons.psychology,
                          Color(0xFFFF9800),
                          () => Navigator.pushNamed(context, '/register-medical-info'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildBasicInfoTile(
                          context,
                          '복약 그룹 등록',
                          '복약 단위 설정',
                          Icons.medical_information_outlined,
                          Color(0xFF9C27B0),
                          () => Navigator.pushNamed(context, '/register-medication-group'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF666666),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '기본 정보는 한 번 등록하면 복약 관리에서 계속 사용됩니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTile(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // 바텀시트 닫기
        onTap(); // 해당 페이지로 이동
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF666666),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}