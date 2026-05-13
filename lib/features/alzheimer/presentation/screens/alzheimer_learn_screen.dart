// ─────────────────────────────────────────────
//  alzheimer_learn_screen.dart  –  Memomate
//  Educational hub with cards for Alzheimer's info.
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/alzheimer/presentation/screens/alzheimer_learn_detail_screen.dart';

class AlzheimerLearnScreen extends StatefulWidget {
  const AlzheimerLearnScreen({super.key});

  @override
  State<AlzheimerLearnScreen> createState() => _AlzheimerLearnScreenState();
}

class _AlzheimerLearnScreenState extends State<AlzheimerLearnScreen> {
  final List<Map<String, String>> _topics = [
    {
      'title': 'What is Alzheimer\'s Disease?',
      'subtitle': 'Comprehensive explanation of Alzheimer\'s disease',
      'detail':
          'Alzheimer\'s disease is a progressive brain disorder that slowly destroys memory and thinking skills and, eventually, the ability to carry out the simplest tasks. It is the most common cause of dementia among older adults. The disease is named after Dr. Alois Alzheimer, who in 1906 noticed changes in the brain tissue of a woman who had died of an unusual mental illness.',
    },
    {
      'title': 'Signs and Symptoms',
      'subtitle': 'Recognizing potential Alzheimer\'s symptoms',
      'detail':
          'Memory loss that disrupts daily life is one of the most common signs of Alzheimer\'s. Other signs include:\n\n• Challenges in planning or solving problems\n• Difficulty completing familiar tasks\n• Confusion with time or place\n• Trouble understanding visual images and spatial relationships\n• New problems with words in speaking or writing\n• Misplacing things and losing the ability to retrace steps',
    },
    {
      'title': 'What are the Causes of Alzheimer\'s Disease?',
      'subtitle': 'Linked to genetics, lifestyle, and brain changes',
      'detail':
          'Scientists believe that for most people, Alzheimer\'s disease is caused by a combination of genetic, lifestyle and environmental factors that affect the brain over time. The causes include the abnormal build-up of proteins in and around brain cells. One of the proteins involved is amyloid, deposits of which form plaques around brain cells. The other protein is tau, deposits of which form tangles within brain cells.',
    },
    {
      'title': 'Stages of Alzheimer\'s Disease',
      'subtitle': 'Understanding the progression of the disease',
      'detail':
          'Alzheimer\'s disease typically progresses slowly in three general stages:\n\n1. Early-stage (mild): A person may function independently but have memory lapses, such as forgetting familiar words or the location of everyday objects.\n\n2. Middle-stage (moderate): Typically the longest stage. Damage to nerve cells makes it difficult to express thoughts and perform routine tasks. You may notice the person confusing words, getting frustrated or acting in unexpected ways.\n\n3. Late-stage (severe): In the final stage, individuals lose the ability to respond to their environment, to carry on a conversation and, eventually, to control movement.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Match app background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learn About Alzheimer\'s',
          style: GoogleFonts.poppins(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // ── Topic Cards ────────────────────────────────
            Expanded(
              child: ListView.separated(
                itemCount: _topics.length,
                separatorBuilder: (_, _) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  return _TopicCard(
                    title: topic['title']!,
                    subtitle: topic['subtitle']!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlzheimerLearnDetailScreen(
                            title: topic['title']!,
                            content: topic['detail']!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.05,
        ), // Light purple background
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Subtle shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.grey),
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Use purple theme
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Learn More',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
